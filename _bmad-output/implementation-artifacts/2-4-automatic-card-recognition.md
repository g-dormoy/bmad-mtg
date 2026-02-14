# Story 2.4: Automatic Card Recognition

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **my card to be recognized automatically when I point my camera at it**,
So that **I don't have to tap a button to start scanning**.

**Epic Context:** Epic 2 - Card Scanning. This is the 4th of 9 stories - the critical "magic moment" where the app comes alive. Stories 2.1 (Camera Viewfinder), 2.2 (OCR Service), and 2.3 (Scryfall API) built the individual pipeline components. This story wires them together into a live, automatic recognition flow: camera frame streaming → OCR text extraction → Scryfall lookup → visual/haptic feedback. Story 2.5 (Scan Result Overlay) will build the card name/set display on top of the recognition result produced here.

## Acceptance Criteria

1. **Given** I am on the scan screen with a card in the frame
   **When** the card is stable and readable
   **Then** OCR extracts the card name automatically (no button tap required)

2. **Given** OCR has extracted a card name
   **When** the extracted name is sent to Scryfall
   **Then** Scryfall lookup happens automatically and returns card data

3. **Given** the full recognition pipeline is running
   **When** measured end-to-end (stable frame → result available)
   **Then** recognition completes in under 2 seconds (NFR1)

4. **Given** a card has been successfully recognized via Scryfall
   **When** recognition completes
   **Then** the card frame overlay border pulses green (animated color transition)

5. **Given** a card has been successfully recognized
   **When** the green pulse appears
   **Then** haptic feedback (50ms vibration) confirms recognition simultaneously

6. **Given** recognition fails (OCR finds no text, or Scryfall returns not-found/error)
   **When** the failure is detected
   **Then** the frame returns to idle state (white border) and retries automatically on next frame

## Tasks / Subtasks

- [x] Task 1: Create RecognitionState model (AC: #1, #2, #4, #6)
  - [x]Create `lib/feature/scanning/models/recognition_state.dart`
  - [x]Define `RecognitionStatus` enum: `idle`, `processing`, `recognized`, `error`
  - [x]Define immutable `RecognitionState` class with fields: `status`, `recognizedCard` (ScryfallCard?), `errorMessage` (String?), `lastExtractedName` (String?)
  - [x]Add `const` factory constructors: `RecognitionState.idle()`, `RecognitionState.processing()`, `RecognitionState.recognized(ScryfallCard)`, `RecognitionState.error(String)`
  - [x]Implement `operator==`, `hashCode`, `toString`, `copyWith`
  - [x]Follow the manual immutable class pattern from `Card` model (no Freezed)

- [x] Task 2: Create CardRecognitionNotifier provider (AC: #1, #2, #3, #6)
  - [x]Create `lib/feature/scanning/providers/card_recognition_provider.dart`
  - [x]Create `CardRecognitionNotifier` extending `Notifier<RecognitionState>`
  - [x]Inject dependencies via `ref.read`: `ocrServiceProvider`, `scryfallServiceProvider`
  - [x]Implement `processFrame(InputImage image)` method:
    - If already `processing`, skip frame (throttle - prevent concurrent OCR calls)
    - Set state to `processing`
    - Call `ocrService.extractCardName(image)`
    - If null or same as `lastExtractedName` when already recognized, skip
    - Call `scryfallService.searchByName(extractedName)`
    - On success: set state to `recognized(card)`, store `lastExtractedName`
    - On `ScryfallNotFoundException`/`ScryfallAmbiguousException`: set state to `idle` (silent retry)
    - On `ScryfallNetworkException`/`ScryfallServerException`: set state to `error(message)`
    - On `OcrException`: set state to `idle` (silent retry on next frame)
    - After any error/no-match, clear processing flag so next frame is tried
  - [x]Implement `reset()` method to return to `idle` state (for when user navigates away or camera restarts)
  - [x]Create `cardRecognitionProvider` as `NotifierProvider<CardRecognitionNotifier, RecognitionState>`

- [x] Task 3: Update CameraController to enable image streaming (AC: #1, #3)
  - [x]Modify `lib/feature/scanning/providers/camera_controller_provider.dart`
  - [x]Add `imageFormatGroup` parameter to `CameraController` constructor:
    - Android: `ImageFormatGroup.nv21`
    - iOS: `ImageFormatGroup.bgra8888`
    - Use `defaultTargetPlatform` (not `dart:io` Platform) for testability
  - [x]Add `startImageStream(Function(CameraImage) callback)` method to notifier
  - [x]Add `stopImageStream()` method to notifier
  - [x]Ensure stream is stopped before camera dispose (prevent "stream already active" errors)
  - [x]Update `disposeCamera()` to stop image stream first if active

- [x] Task 4: Create frame processing bridge (AC: #1, #2, #3)
  - [x]Create `lib/feature/scanning/providers/frame_processor_provider.dart`
  - [x]Create `FrameProcessorNotifier` that orchestrates the frame → recognition pipeline
  - [x]On initialization:
    - Watch `cameraControllerProvider` for ready camera
    - When camera ready, start image stream
    - For each frame: convert via `CameraImageConverter.convertCameraImage()`, then call `cardRecognitionProvider.processFrame()`
  - [x]Add frame throttling: process at most 1 frame every 500ms (debounce) to prevent overwhelming OCR
  - [x]Stop image stream on dispose or when camera controller changes
  - [x]Create `frameProcessorProvider` as `NotifierProvider<FrameProcessorNotifier, bool>` (bool = isStreaming)

- [x] Task 5: Update CardFrameOverlay to support animated green pulse (AC: #4)
  - [x]Modify `lib/feature/scanning/widgets/card_frame_overlay.dart`
  - [x]Add `RecognitionStatus` parameter to control border color and animation
  - [x]Convert to `StatefulWidget` with `SingleTickerProviderStateMixin` for animation
  - [x]Implement animation: when status changes to `recognized`:
    - Animate border color from white → green (`Color(0xFF4CAF50)`) over 300ms
    - Use `AnimationController` + `ColorTween`
  - [x]When status returns to `idle` or `processing`: border returns to white (no animation, instant reset)
  - [x]`shouldRepaint` returns true when border color changes
  - [x]Keep existing overlay, cut-out, and instruction text unchanged

- [x] Task 6: Add haptic feedback on recognition (AC: #5)
  - [x]Use `HapticFeedback.lightImpact()` from `package:flutter/services.dart` (no extra package needed)
  - [x]Trigger haptic in the frame processor or recognition notifier when state transitions to `recognized`
  - [x]Ensure haptic fires exactly once per recognition (not on every frame)
  - [x]50ms vibration is approximately `HapticFeedback.lightImpact()` on both iOS and Android

- [x] Task 7: Update CameraViewfinder to integrate recognition (AC: #1, #4, #6)
  - [x]Modify `lib/feature/scanning/widgets/camera_viewfinder.dart`
  - [x]Watch `cardRecognitionProvider` for recognition state
  - [x]Watch `frameProcessorProvider` to ensure frame streaming is active
  - [x]Pass `recognitionStatus` to `CardFrameOverlay` widget
  - [x]When recognized: overlay shows green pulse (handled by CardFrameOverlay)
  - [x]When error: optionally show subtle error indicator (but frame returns to idle per AC #6)

- [x] Task 8: Update ScanScreen lifecycle to manage recognition (AC: #1, #6)
  - [x]Modify `lib/feature/scanning/screens/scan_screen.dart`
  - [x]Reset recognition state on `resumed` lifecycle (start fresh after background)
  - [x]Reset recognition state on `paused`/`inactive` lifecycle (stop processing)
  - [x]Ensure frame processor is properly disposed when navigating away

- [x] Task 9: Write unit tests for RecognitionState model (AC: #1, #6)
  - [x]Create `test/feature/scanning/models/recognition_state_test.dart`
  - [x]Test: factory constructors create correct states
  - [x]Test: equality comparison works correctly
  - [x]Test: copyWith creates modified copies
  - [x]Test: toString produces readable output

- [x] Task 10: Write unit tests for CardRecognitionNotifier (AC: #1, #2, #3, #6)
  - [x]Create `test/feature/scanning/providers/card_recognition_provider_test.dart`
  - [x]Test: initial state is idle
  - [x]Test: processFrame sets state to processing then recognized on success
  - [x]Test: processFrame skips when already processing (throttle)
  - [x]Test: OCR returning null sets state back to idle
  - [x]Test: ScryfallNotFoundException sets state to idle (silent retry)
  - [x]Test: ScryfallNetworkException sets state to error
  - [x]Test: reset() returns to idle state
  - [x]Test: same card name not re-recognized when already recognized
  - [x]Mock OcrService and ScryfallService using mocktail

- [x] Task 11: Write widget tests for updated CardFrameOverlay (AC: #4)
  - [x]Update `test/feature/scanning/widgets/card_frame_overlay_test.dart`
  - [x]Test: default state shows white border
  - [x]Test: recognized state triggers green border color
  - [x]Test: animation completes within expected duration
  - [x]Test: returning to idle resets border to white

## Dev Notes

### Critical Architecture Context

**This is Story 2.4 in Epic 2 (Card Scanning) - the orchestration story that brings the "magic moment" to life.** Stories 2.1-2.3 built isolated components (camera, OCR, Scryfall API). This story wires them into a live, automatic recognition pipeline. When the user points their camera at a card, the app automatically extracts the card name via OCR, looks it up on Scryfall, and provides visual (green pulse) and haptic feedback.

**Pipeline flow:**
```
CameraController.startImageStream()
  → CameraImage frame
  → CameraImageConverter.convertCameraImage() → InputImage
  → OcrService.extractCardName(InputImage) → String? cardName
  → ScryfallService.searchByName(cardName) → ScryfallCard
  → RecognitionState.recognized(card)
  → Green pulse + haptic feedback
```

**What this story does NOT include (handled by later stories):**
- Scan result overlay with card name/set display → Story 2.5
- "Add to collection" action → Story 2.6
- Duplicate detection display → Story 2.7
- Session counter → Story 2.8
- Session summary → Story 2.9

### Key Technical Patterns

**Recognition State Model (manual immutable class - no Freezed):**
```dart
enum RecognitionStatus { idle, processing, recognized, error }

@immutable
class RecognitionState {
  const RecognitionState._({
    required this.status,
    this.recognizedCard,
    this.errorMessage,
    this.lastExtractedName,
  });

  const RecognitionState.idle()
      : this._(status: RecognitionStatus.idle);

  const RecognitionState.processing()
      : this._(status: RecognitionStatus.processing);

  RecognitionState.recognized(ScryfallCard card, {String? extractedName})
      : this._(
          status: RecognitionStatus.recognized,
          recognizedCard: card,
          lastExtractedName: extractedName,
        );

  const RecognitionState.error(String message)
      : this._(
          status: RecognitionStatus.error,
          errorMessage: message,
        );

  final RecognitionStatus status;
  final ScryfallCard? recognizedCard;
  final String? errorMessage;
  final String? lastExtractedName;
}
```

**Frame Processing Throttle Pattern (CRITICAL for performance):**
```dart
// Process at most 1 frame every 500ms
// OCR takes ~50-200ms, Scryfall takes ~200-500ms
// Without throttling, frames pile up and crash the pipeline

bool _isProcessing = false;
DateTime? _lastProcessedAt;

void _onFrame(CameraImage image) {
  final now = DateTime.now();
  if (_isProcessing) return; // Skip if still processing previous frame
  if (_lastProcessedAt != null &&
      now.difference(_lastProcessedAt!) < const Duration(milliseconds: 500)) {
    return; // Throttle to max 2 frames/second
  }
  _lastProcessedAt = now;
  _processFrame(image);
}
```

**Camera ImageFormatGroup Configuration (CRITICAL - must match platform):**
```dart
// In camera_controller_provider.dart
final controller = CameraController(
  backCamera,
  ResolutionPreset.medium,
  imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
      ? ImageFormatGroup.nv21
      : ImageFormatGroup.bgra8888,
);
```
**NOTE:** Use `defaultTargetPlatform` (from `package:flutter/foundation.dart`), NOT `dart:io` `Platform.isAndroid`. This was established in Story 2.2 code review for testability with `debugDefaultTargetPlatformOverride`.

**Haptic Feedback (no extra package needed):**
```dart
import 'package:flutter/services.dart';

// Trigger on recognition success - approximately 50ms vibration
await HapticFeedback.lightImpact();
```

**CardFrameOverlay Animation Pattern:**
```dart
// Convert StatelessWidget → StatefulWidget with animation
class CardFrameOverlay extends StatefulWidget {
  const CardFrameOverlay({
    super.key,
    this.recognitionStatus = RecognitionStatus.idle,
  });

  final RecognitionStatus recognitionStatus;

  @override
  State<CardFrameOverlay> createState() => _CardFrameOverlayState();
}

class _CardFrameOverlayState extends State<CardFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  // Animate white → green over 300ms on recognition
  // Reset instantly on idle
}
```

**Image Stream Start/Stop Pattern:**
```dart
// In CameraControllerNotifier
bool _isStreaming = false;

Future<void> startImageStream(
  void Function(CameraImage) onImage,
) async {
  if (_controller == null || _isStreaming) return;
  await _controller!.startImageStream(onImage);
  _isStreaming = true;
}

Future<void> stopImageStream() async {
  if (_controller == null || !_isStreaming) return;
  await _controller!.stopImageStream();
  _isStreaming = false;
}
```

**Provider Architecture for this Story:**
```
cardRecognitionProvider (NotifierProvider<RecognitionState>)
  ├── reads: ocrServiceProvider
  ├── reads: scryfallServiceProvider
  └── method: processFrame(InputImage)

frameProcessorProvider (NotifierProvider<bool>)
  ├── watches: cameraControllerProvider (for camera ready)
  ├── reads: cardRecognitionProvider (to call processFrame)
  └── orchestrates: camera stream → convert → process
```

### Previous Story Intelligence

**From Story 2.3 (Scryfall API Integration) - MOST RECENT:**
- `ScryfallService.searchByName(String)` returns `Future<ScryfallCard>`
- Typed exceptions: `ScryfallNotFoundException`, `ScryfallAmbiguousException`, `ScryfallNetworkException`, `ScryfallServerException`
- Dio 5.0.1 uses `DioError`/`DioErrorType` (NOT `DioException`)
- `scryfallServiceProvider` is `Provider<ScryfallService>` with dispose
- Service validates empty/blank input and throws `ScryfallException`
- Multi-faced card handling extracts `image_uris` from `card_faces[0]`

**From Story 2.2 (OCR Text Extraction):**
- `OcrService.extractCardName(InputImage)` returns `Future<String?>`
- Returns null if no text found, uses topmost-text-block heuristic
- `CameraImageConverter.convertCameraImage(CameraImage, CameraDescription)` returns `InputImage?`
- Android needs `ImageFormatGroup.nv21`, iOS needs `ImageFormatGroup.bgra8888`
- `defaultTargetPlatform` used instead of `dart:io` Platform for testability
- `ocrServiceProvider` is `Provider<OcrService>` with dispose
- OcrException thrown on processing failure

**From Story 2.1 (Camera Viewfinder):**
- `CameraControllerNotifier` manages `CameraController` lifecycle
- Uses `ResolutionPreset.medium` - does NOT currently set `imageFormatGroup` (must add in Task 3)
- `_controller` field pattern prevents double-dispose
- `CameraViewfinder` widget: `Stack` with `CameraPreview` + `CardFrameOverlay`
- `CardFrameOverlay` is currently static `StatelessWidget` with `CustomPainter`
- ScanScreen is `ConsumerStatefulWidget` with `WidgetsBindingObserver` for lifecycle

**From Story 2.1 Code Review:**
- `ElevatedButton.icon` doesn't render in Flutter test environment - use standard `ElevatedButton` with `Row` child
- `previewSize` null check was added - apply same defensive patterns
- Hardcoded styles replaced with theme colors - use `Theme.of(context)` consistently

**From All Previous Stories:**
- `build_runner` does NOT work with Homebrew Flutter SDK - all code must be manual
- Very Good Analysis 6.0.0 lint rules: trailing commas, `const` constructors, required params before optional
- `@immutable` annotation + manual `operator==`/`hashCode`/`copyWith` for state classes
- Provider pattern: `Provider<T>((ref) => ...)` with `ref.onDispose` for cleanup
- Feature folder: `lib/feature/` (SINGULAR, not plural)
- `mocktail: ^1.0.4` available for test mocking

**Git patterns established:**
- Conventional commits: `feat(scanning): implement automatic card recognition`
- Recent commit: `ae7a074 feat(scanning): implement Story 2.3 - Scryfall API Integration`

### Architecture Compliance Notes

**CameraController `imageFormatGroup` MUST be set.**
The current camera controller (from Story 2.1) creates `CameraController(backCamera, ResolutionPreset.medium)` without `imageFormatGroup`. Story 2.2 noted this: "Camera controller does NOT currently set imageFormatGroup - Story 2.4 will need to add this when wiring OCR to the live stream." The `CameraImageConverter` expects nv21 (Android) or bgra8888 (iOS). Without `imageFormatGroup`, the camera may use yuv420 on Android which the converter handles, but nv21 is preferred for ML Kit compatibility.

**Frame throttling is non-negotiable.**
The camera streams at 30fps. OCR takes 50-200ms. Without throttling, you'll have 30+ concurrent OCR processes piling up, exhausting memory and crashing. The `_isProcessing` flag + 500ms minimum interval ensures at most 2 frames/second are processed.

**Recognition should be "sticky" - don't re-recognize the same card.**
Once a card is recognized, don't keep sending the same name to Scryfall on every frame. Track `lastExtractedName` and skip Scryfall calls if the OCR keeps returning the same name while already in `recognized` state. Reset only when the user acts (Story 2.6) or the name changes (new card placed).

**Error recovery is silent.**
Per AC #6, failures return to idle state for automatic retry. The user should NOT see error dialogs or toasts for OCR failures or Scryfall not-found. Only network errors might warrant a visible indicator. The frame overlay simply stays white/idle, and the next frame triggers another attempt.

### File Structure

**Files to CREATE:**
- `lib/feature/scanning/models/recognition_state.dart` - RecognitionState + RecognitionStatus
- `lib/feature/scanning/providers/card_recognition_provider.dart` - Recognition orchestrator
- `lib/feature/scanning/providers/frame_processor_provider.dart` - Frame streaming bridge
- `test/feature/scanning/models/recognition_state_test.dart` - State model tests
- `test/feature/scanning/providers/card_recognition_provider_test.dart` - Recognition tests

**Files to MODIFY:**
- `lib/feature/scanning/providers/camera_controller_provider.dart` - Add imageFormatGroup + stream methods
- `lib/feature/scanning/widgets/card_frame_overlay.dart` - Add animation + recognition status
- `lib/feature/scanning/widgets/camera_viewfinder.dart` - Integrate recognition state + frame processor
- `lib/feature/scanning/screens/scan_screen.dart` - Add recognition lifecycle management
- `test/feature/scanning/widgets/card_frame_overlay_test.dart` - Update for animation tests

**Files NOT to touch:**
- `lib/data/services/ocr_service.dart` - No changes needed (already complete)
- `lib/data/services/scryfall_service.dart` - No changes needed (already complete)
- `lib/data/services/scryfall_exception.dart` - No changes needed
- `lib/data/services/camera_image_converter.dart` - No changes needed (already handles conversion)
- `lib/data/models/scryfall_card.dart` - No changes needed
- `lib/data/models/card.dart` - No changes needed
- `lib/data/repositories/card_repository.dart` - No changes until Story 2.6
- `lib/feature/scanning/providers/ocr_provider.dart` - No changes needed
- `lib/feature/scanning/providers/scryfall_provider.dart` - No changes needed
- `lib/feature/scanning/providers/camera_permission_provider.dart` - No changes needed
- `lib/feature/scanning/widgets/camera_permission_denied.dart` - No changes needed
- `pubspec.yaml` - No new packages needed (`HapticFeedback` is in `flutter/services.dart`)

### Project Structure Notes

- New model file goes in `lib/feature/scanning/models/` (directory may need to be created)
- New provider files go in `lib/feature/scanning/providers/` alongside existing providers
- Test structure mirrors source: `test/feature/scanning/models/`, `test/feature/scanning/providers/`
- No `pubspec.yaml` changes needed - all required packages already installed
- No platform config changes needed

### Testing Strategy

**Unit tests for RecognitionState model:**
- Test all factory constructors produce correct status and fields
- Test equality: same state == same state, different states !=
- Test copyWith creates new instance with updated fields
- Test toString for debugging

**Unit tests for CardRecognitionNotifier:**
- Mock `OcrService` and `ScryfallService` via mocktail
- Use `ProviderContainer` for Riverpod testing
- Test state transitions: idle → processing → recognized
- Test state transitions: idle → processing → idle (OCR returns null)
- Test state transitions: idle → processing → idle (Scryfall not found)
- Test state transitions: idle → processing → error (network error)
- Test throttling: processFrame skipped when already processing
- Test sticky recognition: same name doesn't re-trigger Scryfall
- Test reset: returns to idle from any state

**Widget tests for CardFrameOverlay:**
- Test default white border color
- Test green border when `recognitionStatus == RecognitionStatus.recognized`
- Test animation controller is created/disposed properly
- Use `tester.pump(duration)` to advance animation

**Integration notes:**
- Camera image streaming cannot be tested in unit tests (requires platform channels)
- Frame throttling timing is best tested on device
- Haptic feedback cannot be verified in unit tests
- End-to-end pipeline (camera → OCR → Scryfall → UI) requires manual testing on device

### Performance Budget

| Stage | Budget | Notes |
|-------|--------|-------|
| Frame capture | ~0ms | Camera stream provides frames automatically |
| Image conversion | ~5ms | CameraImageConverter byte manipulation |
| OCR extraction | 50-200ms | ML Kit on-device, medium resolution |
| Scryfall API call | 200-800ms | Network latency dependent |
| State update + UI | ~16ms | Single frame render |
| **Total** | **~300-1000ms** | Well within 2-second NFR1 budget |

The 500ms throttle interval means a new frame is processed every 500ms. Even with worst-case OCR (200ms) + Scryfall (800ms) = 1000ms, this is within budget. The throttle prevents frame pileup while the previous recognition is still in flight.

### References

- [Source: epics.md#Story 2.4 - Automatic Card Recognition]
- [Source: architecture.md#API & Communication Patterns - Scryfall Integration Flow]
- [Source: architecture.md#State Management Patterns - Riverpod]
- [Source: architecture.md#Error Handling Patterns]
- [Source: architecture.md#Core Architectural Decisions - Camera: official camera package]
- [Source: architecture.md#Implementation Patterns - Loading State Patterns]
- [Source: prd.md#Non-Functional Requirements - NFR1: Scan Recognition < 2 seconds]
- [Source: prd.md#Non-Functional Requirements - NFR4: Scan Accuracy 99%+]
- [Source: ux-design-specification.md#Custom Components - CameraViewfinder States]
- [Source: ux-design-specification.md#Custom Components - CardFrameOverlay States]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Success: haptic 50ms]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Error: auto-retry]
- [Source: ux-design-specification.md#Defining Experience - Experience Mechanics]
- [Source: ux-design-specification.md#Desired Emotional Response - Instant Feedback principle]
- [Flutter CameraController.startImageStream](https://pub.dev/documentation/camera/latest/camera/CameraController/startImageStream.html)
- [Flutter HapticFeedback](https://api.flutter.dev/flutter/services/HapticFeedback-class.html)
- [Google ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- [Scryfall REST API - /cards/named](https://scryfall.com/docs/api/cards/named)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- CardFrameOverlay widget tests initially failed due to multiple `CustomPaint` widgets in tree (AnimatedBuilder introduces additional widget layers). Fixed by using `find.byWidgetPredicate` to target `CustomPaint` with `CardFramePainter` painter specifically.
- HapticFeedback.lightImpact() requires `TestWidgetsFlutterBinding.ensureInitialized()` in unit tests since it uses platform channels.

### Completion Notes List

- Task 1 + Task 9: Created `RecognitionState` immutable model with `RecognitionStatus` enum, factory constructors, equality, copyWith, toString. 22 unit tests pass.
- Task 2 + Task 10: Created `CardRecognitionNotifier` with `processFrame()` pipeline (OCR -> Scryfall -> state update), throttling, error handling, and `reset()`. 9 unit tests with mocked services pass.
- Task 3: Updated `CameraControllerNotifier` to add `imageFormatGroup` (nv21/bgra8888 per platform), `startImageStream()`, `stopImageStream()`, and stream-aware dispose.
- Task 4: Created `FrameProcessorNotifier` that bridges camera image stream to recognition pipeline with 500ms frame throttling.
- Task 5 + Task 11: Converted `CardFrameOverlay` from `StatelessWidget` to `StatefulWidget` with `SingleTickerProviderStateMixin`. Added `AnimationController` + `ColorTween` for white -> green (300ms) border pulse on recognition. 8 widget tests pass.
- Task 6: Added `HapticFeedback.lightImpact()` in `CardRecognitionNotifier.processFrame()` on successful recognition (fires exactly once per recognition).
- Task 7: Updated `CameraViewfinder` to watch `cardRecognitionProvider` and `frameProcessorProvider`, passing `recognitionStatus` to `CardFrameOverlay`.
- Task 8: Updated `ScanScreen` lifecycle to reset recognition on resume, stop frame processor and reset recognition on pause/inactive.

### File List

**New files:**
- `lib/feature/scanning/models/recognition_state.dart`
- `lib/feature/scanning/providers/card_recognition_provider.dart`
- `lib/feature/scanning/providers/frame_processor_provider.dart`
- `test/feature/scanning/models/recognition_state_test.dart`
- `test/feature/scanning/providers/card_recognition_provider_test.dart`

**Modified files:**
- `lib/feature/scanning/providers/camera_controller_provider.dart`
- `lib/feature/scanning/widgets/card_frame_overlay.dart`
- `lib/feature/scanning/widgets/camera_viewfinder.dart`
- `lib/feature/scanning/screens/scan_screen.dart`
- `test/feature/scanning/widgets/card_frame_overlay_test.dart`

## Change Log

- 2026-02-14: Implemented Story 2.4 - Automatic Card Recognition pipeline (camera frame streaming -> OCR extraction -> Scryfall lookup -> visual/haptic feedback). All 11 tasks complete, 148 tests pass (39 new), 0 regressions.
- 2026-02-14: **Code Review (AI)** — 7 issues found (2 CRITICAL, 2 HIGH, 3 MEDIUM). Fixed 6/7:
  - **C1** Fixed: Added 2 missing tests (throttle skip + dedup) to `card_recognition_provider_test.dart`
  - **C2** Fixed: Sticky recognition dedup was dead code — captured `previousState` before setting to processing
  - **H1** Fixed: Added catch for base `ScryfallException` (parse errors) in `processFrame`
  - **H2** Fixed: Added `catch (Exception)` safety net for unexpected errors in `processFrame`
  - **M1** Fixed: `_cleanup()` in `FrameProcessorNotifier` now stops image stream on dispose
  - **M2** Fixed: Sequenced async lifecycle operations in `ScanScreen._handleBackgrounded()` to avoid race condition
  - **M3** Noted: `copyWith` cannot reset nullable fields to null (no current callers; latent, low-risk)
  - 150 tests pass (41 in story scope), 0 regressions, 0 lint issues.
