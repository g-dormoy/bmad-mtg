# Story 2.2: OCR Text Extraction Service

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want **an OCR service that extracts text from camera frames**,
So that **card names can be identified for Scryfall lookup**.

## Acceptance Criteria

1. **Given** a camera frame containing a card
   **When** the OCR service processes the image
   **Then** text is extracted from the card (especially the title area)

2. **Given** the OCR service receives a camera frame
   **When** text extraction completes
   **Then** the extracted text is returned as a string

3. **Given** a camera frame with readable text
   **When** OCR processing runs
   **Then** processing completes in under 500ms

4. **Given** the device has no network connection
   **When** the OCR service processes an image
   **Then** ML Kit text recognition runs on-device (no network required)

5. **Given** sample card images with known text
   **When** unit tests run the OCR extraction
   **Then** the correct card names are extracted from the title area

## Tasks / Subtasks

- [x] Task 1: Add google_mlkit_text_recognition dependency (AC: #4)
  - [x] Add `google_mlkit_text_recognition: ^0.15.1` to pubspec.yaml dependencies
  - [x] Run `flutter pub get` to install package
  - [x] Verify Android `compileSdkVersion` is 35 (required by ML Kit 0.15.x)
  - [x] Verify iOS deployment target is at least 15.5 (required by ML Kit)
  - [x] Verify Android `minSdkVersion` is at least 21 (currently 26, which is fine)

- [x] Task 2: Create OcrService class (AC: #1, #2, #3, #4)
  - [x] Create `lib/data/services/ocr_service.dart`
  - [x] Create `OcrService` class with a `TextRecognizer` instance (Latin script)
  - [x] Implement `Future<String> extractText(InputImage image)` method:
    - Calls `textRecognizer.processImage(image)` to get `RecognizedText`
    - Iterates through `TextBlock`s and `TextLine`s
    - Returns the full recognized text as a string
  - [x] Implement `Future<String?> extractCardName(InputImage image)` method:
    - Calls `extractText()` to get raw text
    - Applies heuristic to identify the card title (first large text block, typically the topmost line)
    - Returns the best candidate card name string, or null if no text found
  - [x] Implement `void dispose()` method that calls `textRecognizer.close()`
  - [x] All processing runs on-device (ML Kit, no network calls)

- [x] Task 3: Create InputImage conversion utility (AC: #1)
  - [x] Create `lib/data/services/camera_image_converter.dart`
  - [x] Implement `InputImage? convertCameraImage(CameraImage image, CameraDescription camera)`:
    - Handle platform-specific image formats (nv21 for Android, bgra8888 for iOS)
    - Calculate rotation from camera sensor orientation
    - Concatenate image plane bytes into single buffer
    - Build `InputImageMetadata` with size, rotation, format, bytesPerRow
    - Return `InputImage.fromBytes(bytes: bytes, metadata: metadata)`
  - [x] Handle null/invalid format gracefully (return null)

- [x] Task 4: Create OCR Riverpod provider (AC: #1, #2)
  - [x] Create `lib/feature/scanning/providers/ocr_provider.dart`
  - [x] Create `ocrServiceProvider` as a `Provider<OcrService>` that:
    - Creates a single `OcrService` instance
    - Calls `dispose()` on provider disposal via `ref.onDispose`
  - [x] Provider pattern matches existing providers (`cameraPermissionProvider`, `cameraControllerProvider`)

- [x] Task 5: Write unit tests for OcrService (AC: #5)
  - [x] Create `test/data/services/ocr_service_test.dart`
  - [x] Test: OcrService creates without errors
  - [x] Test: extractText returns empty string for blank/empty image
  - [x] Test: extractCardName returns null when no text is found
  - [x] Test: extractCardName returns the topmost text line as card name candidate
  - [x] Test: dispose closes the text recognizer without errors
  - [x] Note: Use mock `TextRecognizer` since ML Kit requires platform channels not available in unit tests

- [x] Task 6: Write unit tests for CameraImageConverter (AC: #1)
  - [x] Create `test/data/services/camera_image_converter_test.dart`
  - [x] Test: Returns null for unsupported image format
  - [x] Test: Correctly concatenates plane bytes
  - [x] Test: Sets correct rotation for back camera
  - [x] Note: Platform-dependent logic must be tested with platform channel mocks or integration tests

## Dev Notes

### Critical Architecture Context

**This is Story 2.2 in Epic 2 (Card Scanning) - the OCR foundation.** This story creates the text extraction service that powers the entire card recognition pipeline. Story 2.3 (Scryfall API) depends on the card name extracted here. Story 2.4 (Automatic Card Recognition) wires this service into the live camera stream. Getting OCR accuracy and performance right here is critical for the 99%+ scan accuracy target (NFR4) and <2s recognition time (NFR1).

**Service placement:** `lib/data/services/ocr_service.dart` - following the architecture document's data layer placement for services. The CameraImageConverter also goes in `lib/data/services/` as it's a data transformation utility.

**Provider placement:** `lib/feature/scanning/providers/ocr_provider.dart` - the Riverpod provider lives in the scanning feature since OCR is only used by scanning.

**Feature folder convention:** `lib/feature/` (SINGULAR, not `lib/features/`). This convention was established by the starter template and confirmed in Stories 1.1-2.1. Architecture doc shows `lib/features/` (plural) but the actual project uses `lib/feature/` - **follow the actual project convention**.

### Key Technical Patterns

**Google ML Kit Text Recognition:**
```dart
// Package: google_mlkit_text_recognition ^0.15.1
// Runs 100% on-device - no network required
// Uses Latin script model by default (perfect for MTG card names)

final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

// Process an image
final RecognizedText result = await textRecognizer.processImage(inputImage);

// Result hierarchy: RecognizedText → TextBlock → TextLine → TextElement
// result.text gives the full recognized text as a string
// Each TextBlock/TextLine has: text, boundingBox, cornerPoints, confidence

// CRITICAL: Always close when done
await textRecognizer.close();
```

**CameraImage to InputImage Conversion (CRITICAL):**
```dart
// Platform-specific image format is CRITICAL:
// Android MUST use ImageFormatGroup.nv21
// iOS MUST use ImageFormatGroup.bgra8888
// Using the wrong format produces garbage or crashes

// The camera controller in Story 2.1 uses ResolutionPreset.medium
// BUT does not currently set imageFormatGroup
// Story 2.4 will need to update the camera controller to set the correct format
// For now, the converter should handle both formats

// Byte concatenation pattern:
final WriteBuffer allBytes = WriteBuffer();
for (final Plane plane in cameraImage.planes) {
  allBytes.putUint8List(plane.bytes);
}
final bytes = allBytes.done().buffer.asUint8List();
```

**Card Name Extraction Heuristic:**
MTG cards have the card name as the topmost text on the card. The extraction strategy:
1. Process the full image with ML Kit
2. Sort TextBlocks by vertical position (top of bounding box)
3. The topmost text line is most likely the card name
4. Filter out very short strings (< 2 characters) or obviously non-name text
5. Return the best candidate

**This is intentionally simple for Story 2.2.** Story 2.4 will add more sophisticated recognition logic (stability detection, confidence thresholds, frame-within-overlay cropping).

**Riverpod Provider Pattern (matching existing providers):**
```dart
// Manual provider declaration - NOT @riverpod annotation
// (build_runner doesn't work with Homebrew Flutter SDK)
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});
```

### Performance Considerations

- **500ms target (AC #3):** ML Kit Latin text recognition typically completes in 50-200ms on modern devices with medium resolution. The 500ms budget is generous.
- **Reuse TextRecognizer instance:** Create once, reuse for all frames. Do NOT create/close per frame - this is expensive.
- **Frame throttling (for Story 2.4):** The OCR service itself is stateless and re-entrant, but callers MUST throttle calls. Use an `_isProcessing` flag to skip frames while a recognition is running. This will be implemented in Story 2.4.
- **Region of interest:** For better accuracy and speed, consider cropping to the card frame overlay region before OCR. This optimization can be done in Story 2.4 when integrating with the live camera stream.

### Platform-Specific Configuration

**Android (android/app/build.gradle):**
- `compileSdkVersion` must be **35** (ML Kit 0.15.x requirement)
- `minSdkVersion` is currently **26** (exceeds the ML Kit minimum of 21) ✅
- No additional Gradle changes needed for Latin script model

**iOS (ios/Podfile):**
- Deployment target must be at least **15.5** (check and update if needed)
- Latin script model is included by default - no extra pod dependencies
- Note: ML Kit does NOT work on M1-based Mac simulators - test on real devices or Android emulator

**No additional platform manifest changes needed** (no new permissions required - camera permission was already added in Story 2.1).

### Previous Story Intelligence

**From Story 2.1 (Camera Viewfinder):**
- `CameraController` exists in `lib/feature/scanning/providers/camera_controller_provider.dart`
- Uses `ResolutionPreset.medium` - good for OCR performance
- Camera controller does NOT currently set `imageFormatGroup` - Story 2.4 will need to add this when wiring OCR to the live stream
- Camera lifecycle management is handled by `ScanScreen` with `WidgetsBindingObserver`
- The `_controller` field pattern with null check prevents double-dispose

**From Story 2.1 Code Review:**
- Permission auto-request was missing and fixed - test that assumption
- `previewSize` force-unwrap was fixed with null check - apply same defensive pattern
- Hardcoded styles were replaced with theme colors - use theme consistently

**From Story 1.2 (Database):**
- `build_runner` does NOT work with Homebrew Flutter SDK - write all code manually
- No Freezed code-gen - write state classes manually
- Riverpod providers use manual declarations (not `@riverpod` annotation)

**From Story 1.1 (Project Setup):**
- Very Good Analysis lint rules (6.0.0) are active - follow ALL lint rules strictly
- Use `const` constructors wherever possible
- Add trailing commas per lint rules

**Git patterns established:**
- Conventional commits: `feat(scanning): implement OCR text extraction service`
- Branch naming: `feature/story-2.2-ocr-text-extraction`

### Testing Strategy

**Unit tests for OcrService:**
- Mock `TextRecognizer` since ML Kit requires native platform channels
- Test the service logic: creating, processing, extracting card names, disposing
- Use mock `RecognizedText` responses to verify card name extraction heuristic
- Verify the topmost-text-block heuristic works correctly

**Unit tests for CameraImageConverter:**
- Test byte concatenation logic
- Test rotation calculation
- Test format detection and null handling for unsupported formats
- Platform-specific behavior needs integration tests on real devices

**What we CANNOT test in unit tests:**
- Actual ML Kit text recognition (requires native platform)
- Real camera frame processing
- Performance timing (< 500ms target requires device testing)
- These require manual testing on physical devices or integration tests

### File Structure

**Files to CREATE:**
- `lib/data/services/ocr_service.dart` - OCR text extraction service
- `lib/data/services/camera_image_converter.dart` - CameraImage to InputImage conversion
- `lib/feature/scanning/providers/ocr_provider.dart` - Riverpod provider for OcrService
- `test/data/services/ocr_service_test.dart` - Unit tests for OcrService
- `test/data/services/camera_image_converter_test.dart` - Unit tests for converter

**Files to MODIFY:**
- `pubspec.yaml` - Add google_mlkit_text_recognition dependency
- `android/app/build.gradle` - Update compileSdkVersion to 35 if not already

**Files NOT to touch:**
- `lib/feature/scanning/providers/camera_controller_provider.dart` - No changes until Story 2.4
- `lib/feature/scanning/screens/scan_screen.dart` - No changes until Story 2.4
- `lib/feature/scanning/widgets/*` - No UI changes in this story
- `lib/data/database/*` - No database changes needed
- `lib/data/repositories/*` - No repository changes needed

### Project Structure Notes

- New service files go in `lib/data/services/` (following architecture: data layer for services)
- New provider file goes in `lib/feature/scanning/providers/` (scanning feature owns OCR)
- Test structure mirrors source: `test/data/services/`, `test/feature/scanning/providers/`
- No new subdirectories needed - `lib/data/services/` directory may need to be created

### References

- [Source: epics.md#Story 2.2 - OCR Text Extraction Service]
- [Source: architecture.md#API & Communication Patterns - Card Recognition: Google ML Kit OCR]
- [Source: architecture.md#API & Communication Patterns - Scryfall Integration Flow Steps 1-2]
- [Source: architecture.md#Structure Patterns - Feature-First Organization]
- [Source: architecture.md#Project Structure - data/services/ocr_service.dart]
- [Source: architecture.md#State Management Patterns - Riverpod]
- [Source: architecture.md#Error Handling Patterns]
- [Source: prd.md#Non-Functional Requirements - Scan Recognition < 2 seconds]
- [Source: prd.md#Non-Functional Requirements - Scan Accuracy 99%+]
- [Source: ux-design-specification.md#Defining Experience - Experience Mechanics]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Error]
- [google_mlkit_text_recognition ^0.15.1](https://pub.dev/packages/google_mlkit_text_recognition)
- [google_mlkit_commons ^0.11.1](https://pub.dev/packages/google_mlkit_commons)
- [Flutter camera package ^0.11.3+1](https://pub.dev/packages/camera)
- [ML Kit Text Recognition v2 (Google)](https://developers.google.com/ml-kit/vision/text-recognition/v2)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- No blocking issues encountered during implementation.

### Completion Notes List

- Task 1: Added `google_mlkit_text_recognition: ^0.15.1` dependency. Updated Android `compileSdkVersion` and `targetSdkVersion` from 33 to 35. Updated iOS deployment target from 12.0 to 15.5 across Podfile and Xcode project. Added `mocktail: ^1.0.4` dev dependency for test mocking.
- Task 2: Created `OcrService` class with `extractText()` and `extractCardName()` methods. Card name extraction uses topmost-text-block heuristic (sort blocks by vertical position, return first line >= 2 chars). Includes `OcrService.withRecognizer()` constructor for testability.
- Task 3: Created `CameraImageConverter` utility with static `convertCameraImage()` method. Handles platform-specific formats (nv21 for Android, bgra8888 for iOS). Uses `WriteBuffer` from `package:flutter/foundation.dart` for byte concatenation. Returns null for unsupported formats/orientations.
- Task 4: Created `ocrServiceProvider` following existing manual provider declaration pattern. Disposes TextRecognizer via `ref.onDispose`.
- Task 5: 9 unit tests for OcrService using mocktail to mock `TextRecognizer`, `RecognizedText`, `TextBlock`, and `TextLine`. Tests cover: text extraction, empty results, card name heuristic with sorting, short text filtering, error handling (OcrException), and dispose.
- Task 6: 11 unit tests for CameraImageConverter. Tests cover: unsupported format rejection per platform, successful nv21/yuv420 conversion on Android, successful bgra8888 conversion on iOS, cross-platform format rejection, unsupported platform rejection, multi-plane byte concatenation, invalid/valid sensor orientations. Uses `debugDefaultTargetPlatformOverride` for full conversion path coverage.

### File List

**New files:**
- `lib/data/services/ocr_service.dart`
- `lib/data/services/camera_image_converter.dart`
- `lib/feature/scanning/providers/ocr_provider.dart`
- `test/data/services/ocr_service_test.dart`
- `test/data/services/camera_image_converter_test.dart`

**Modified files:**
- `pubspec.yaml` - Added google_mlkit_text_recognition and mocktail dependencies
- `pubspec.lock` - Updated with new dependencies
- `android/app/build.gradle` - compileSdkVersion 33→35, targetSdkVersion 33→35
- `ios/Podfile` - Set platform :ios, '15.5'
- `ios/Runner.xcodeproj/project.pbxproj` - IPHONEOS_DEPLOYMENT_TARGET 12.0→15.5
- `_bmad-output/implementation-artifacts/sprint-status.yaml` - Updated story status to review

**Architecture Deviation Note:**
- iOS deployment target raised from 12.0→15.5 (required by ML Kit 0.15.x). Architecture doc states "iOS 14+" but this is now effectively **iOS 15.5+**. Architecture doc should be updated to reflect this constraint.

## Change Log

- 2026-02-14: Implemented Story 2.2 - OCR Text Extraction Service. Created OcrService with ML Kit text recognition, CameraImageConverter for platform-specific image format handling, and ocrServiceProvider for Riverpod integration. Added 11 unit tests (7 OcrService + 4 CameraImageConverter). Updated platform configs for ML Kit compatibility.
- 2026-02-14: Code review fixes applied. (1) CameraImageConverter: replaced `dart:io` Platform checks with `defaultTargetPlatform` for testability. (2) Rewrote CameraImageConverter tests from 4 to 11, now covering actual conversion paths on Android/iOS via `debugDefaultTargetPlatformOverride`. (3) Added `OcrException` typed exception and error handling in `extractText`/`extractCardName`. (4) Added 2 error handling tests for OcrService. Total tests: 20 (9 OcrService + 11 CameraImageConverter).
