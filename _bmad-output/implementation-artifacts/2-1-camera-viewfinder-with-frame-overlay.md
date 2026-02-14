# Story 2.1: Camera Viewfinder with Frame Overlay

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to see a camera viewfinder with a card-shaped frame when I open the Scan tab**,
So that **I know where to position my card for scanning**.

## Acceptance Criteria

1. **Given** I tap the Scan tab
   **When** the scan screen loads
   **Then** a full-screen camera viewfinder displays

2. **Given** the scan screen is loading
   **When** the camera initializes
   **Then** a card frame overlay (63:88 aspect ratio) guides card positioning

3. **Given** the camera viewfinder is active
   **When** I look at the card frame
   **Then** the frame is visible but not obtrusive (white outline)

4. **Given** I have not granted camera permission
   **When** the scan screen loads
   **Then** camera permission is requested via system dialog

5. **Given** I denied camera permission
   **When** the scan screen loads
   **Then** a helpful message appears explaining why camera access is needed
   **And** a button to open app settings is provided

## Tasks / Subtasks

- [x] Task 1: Add camera and permission_handler dependencies (AC: #1, #4)
  - [x] Add `camera: ^0.11.3+1` to pubspec.yaml dependencies
  - [x] Add `permission_handler: ^12.0.1` to pubspec.yaml dependencies
  - [x] Run `flutter pub get` to install packages
  - [x] Add `NSCameraUsageDescription` to `ios/Runner/Info.plist` with message: "This app needs camera access to scan Magic: The Gathering cards"
  - [x] Verify `android.permission.CAMERA` in `android/app/src/main/AndroidManifest.xml`
  - [x] Set Android `minSdkVersion` to at least 24 (should already be 26, verify)

- [x] Task 2: Create camera permission handler (AC: #4, #5)
  - [x] Create `lib/feature/scanning/providers/camera_permission_provider.dart`
  - [x] Create a `cameraPermissionProvider` (Riverpod AsyncNotifier) that:
    - Checks current camera permission status
    - Requests permission if not granted
    - Returns permission state (granted, denied, permanentlyDenied)
  - [x] Use `permission_handler` package for permission management
  - [x] Handle `permanentlyDenied` state with `openAppSettings()` action

- [x] Task 3: Create camera controller provider (AC: #1)
  - [x] Create `lib/feature/scanning/providers/camera_controller_provider.dart`
  - [x] Create a `cameraControllerProvider` (Riverpod AsyncNotifier) that:
    - Calls `availableCameras()` to get device cameras
    - Selects the back camera (CameraLensDirection.back)
    - Creates `CameraController` with `ResolutionPreset.medium` (balance between quality and performance for OCR)
    - Initializes the controller
    - Disposes properly on provider disposal
  - [x] Handle `CameraException` errors gracefully
  - [x] Provider should depend on camera permission being granted

- [x] Task 4: Create CardFrameOverlay widget (AC: #2, #3)
  - [x] Create `lib/feature/scanning/widgets/card_frame_overlay.dart`
  - [x] Implement `CustomPainter` that draws:
    - Semi-transparent dark overlay covering the full screen
    - Clear cut-out rectangle with 63:88 aspect ratio (MTG card dimensions)
    - White outline border (2-3px stroke) around the cut-out
    - Rounded corners on the cut-out rectangle (8px radius)
  - [x] Size the cut-out to ~80% of screen width, centered vertically
  - [x] Add subtle instruction text below the frame: "Position card within frame"
  - [x] Use `shouldRepaint` returning false (static overlay, no animation yet)

- [x] Task 5: Create CameraViewfinder widget (AC: #1, #2, #3)
  - [x] Create `lib/feature/scanning/widgets/camera_viewfinder.dart`
  - [x] Use `Stack` to layer:
    1. `CameraPreview` from camera controller (full-screen)
    2. `CardFrameOverlay` on top
  - [x] Handle camera controller loading state (show loading indicator)
  - [x] Handle camera controller error state (show error message)
  - [x] Make the camera preview fill the entire available space (use `SizedBox.expand` + `FittedBox` or `AspectRatio` to avoid letterboxing)

- [x] Task 6: Create permission denied view (AC: #5)
  - [x] Create `lib/feature/scanning/widgets/camera_permission_denied.dart`
  - [x] Show centered message: "Camera access is needed to scan your MTG cards"
  - [x] Show secondary text: "Enable camera permission in your device settings"
  - [x] Include an `ElevatedButton` labeled "Open Settings" that calls `openAppSettings()`
  - [x] Use theme colors (dark background, white text, primary accent for button)
  - [x] Include camera icon for visual context

- [x] Task 7: Update ScanScreen to compose all components (AC: #1, #2, #3, #4, #5)
  - [x] Rewrite `lib/feature/scanning/screens/scan_screen.dart`
  - [x] Convert to `ConsumerStatefulWidget` (Riverpod + lifecycle)
  - [x] Watch `cameraPermissionProvider` to check permission state
  - [x] Show `CameraPermissionDenied` widget when permission is denied
  - [x] Show `CameraViewfinder` when permission is granted
  - [x] Show loading state while permission is being checked
  - [x] Implement `WidgetsBindingObserver` to handle app lifecycle:
    - `resumed`: Re-check permission, reinitialize camera
    - `inactive`/`paused`: Dispose camera controller to release hardware
  - [x] The ScanScreen sits within the existing `ScaffoldWithBottomNav` (no separate Scaffold)

- [x] Task 8: Write unit tests (AC: #2, #3, #4, #5)
  - [x] Create `test/feature/scanning/widgets/card_frame_overlay_test.dart`
    - Test: CardFrameOverlay renders without errors
    - Test: CustomPainter uses correct aspect ratio (63:88)
    - Test: Overlay displays instruction text
  - [x] Create `test/feature/scanning/widgets/camera_permission_denied_test.dart`
    - Test: Shows camera denied message
    - Test: Shows "Open Settings" button
    - Test: Button callback is triggered on tap
  - [x] Create `test/feature/scanning/screens/scan_screen_test.dart`
    - Test: Shows loading indicator while permission is being checked
    - Test: Shows permission denied view when permission is denied
    - Test: Shows camera viewfinder when permission is granted (mock camera controller)

## Dev Notes

### Critical Architecture Context

**This is the FIRST story of Epic 2 (Card Scanning) - the core "magic moment" of the app.** This story lays the camera infrastructure that ALL subsequent scanning stories (2.2-2.9) will build upon. Getting the camera lifecycle, permissions, and overlay right here prevents cascading issues downstream.

**Feature folder convention:** `lib/feature/` (SINGULAR, not `lib/features/`). This is the convention established by the starter template and used consistently in Stories 1.1-1.4. Architecture doc shows `lib/features/` (plural) but the actual project uses `lib/feature/` - **follow the actual project convention**.

**Camera package version:** `camera: ^0.11.3+1` (latest as of Feb 2026). Since v0.11.0, Android uses CameraX backend (`camera_android_camerax`) which provides better device compatibility. Minimum Android API 24 required (project targets API 26, which is fine).

**Permission handler:** `permission_handler: ^12.0.1`. Handles runtime camera permissions on both iOS and Android. Required for iOS (always asks at runtime) and Android 6+ (runtime permission model).

**Why `ResolutionPreset.medium` for camera:**
- OCR (Story 2.2) needs readable text, not maximum resolution
- Lower resolution = faster frame processing = better battery life
- Can be upgraded to `high` later if OCR accuracy requires it
- Medium is sufficient for card name extraction at 6-12 inch distance

### Key Technical Patterns

**Riverpod Provider Architecture:**
```dart
// Permission provider - checks and requests camera permission
final cameraPermissionProvider = AsyncNotifierProvider<CameraPermissionNotifier, PermissionStatus>(
  CameraPermissionNotifier.new,
);

// Camera controller provider - manages CameraController lifecycle
final cameraControllerProvider = AsyncNotifierProvider<CameraControllerNotifier, CameraController>(
  CameraControllerNotifier.new,
);
```

**Camera Lifecycle Management (CRITICAL):**
The camera hardware MUST be properly managed across app lifecycle states:
- `resumed` -> initialize/reinitialize camera
- `inactive` -> camera may be taken by another app
- `paused` -> dispose camera to release hardware
- `detached` -> camera already gone

Use `WidgetsBindingObserver` mixin on the ScanScreen's state or use a Riverpod provider that watches app lifecycle.

**Camera Preview Full-Screen Pattern:**
```dart
Stack(
  children: [
    SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    ),
    const CardFrameOverlay(),
  ],
)
```
Note: `previewSize` width/height are swapped because camera reports in landscape.

**Card Frame Overlay with CustomPainter:**
```dart
// MTG card ratio: 63:88 (width:height) = ~0.7159
// Use saveLayer + BlendMode.clear for transparent cut-out
canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
canvas.drawRect(fullRect, overlayPaint); // semi-transparent overlay
canvas.drawRRect(cardRRect, clearPaint); // transparent cut-out
canvas.restore();
canvas.drawRRect(cardRRect, borderPaint); // white border
```

**ScanScreen within ScaffoldWithBottomNav:**
The ScanScreen is rendered INSIDE the existing `ScaffoldWithBottomNav` body (via `StatefulShellRoute.indexedStack`). Do NOT add a Scaffold inside ScanScreen - the outer scaffold already provides the navigation bar. The ScanScreen body should be the camera preview directly.

### Platform-Specific Configuration

**iOS (ios/Runner/Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan Magic: The Gathering cards</string>
```

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```
Note: `android:required="false"` so the app can still be installed on devices without cameras (e.g., tablets) - it just won't scan.

**Xcode is NOT installed** (per Story 1.1 intelligence). Test on Android emulator or physical Android device. The camera emulator in Android Studio provides a virtual camera for testing.

### Previous Story Intelligence

**From Story 1.4 (Dark Theme):**
- `AppTheme.darkTheme` is the active theme with Material 3 enabled
- `MtgColors` ThemeExtension is available via `Theme.of(context).extension<MtgColors>()!`
- Use theme colors for all UI elements (don't hardcode colors)
- Background: `#121212`, Surface: `#1E1E1E`, Primary: `#6750A4`

**From Story 1.3 (Navigation):**
- `ScaffoldWithBottomNav` wraps both tabs in a `StatefulShellRoute.indexedStack`
- ScanScreen is at `/scan` route (initial location)
- The navigation bar uses `NavigationBar` (Material 3)
- ScanScreen is a `StatelessWidget` currently - will need to become `ConsumerStatefulWidget` for Riverpod + lifecycle

**From Story 1.2 (Database):**
- `build_runner` does NOT work with Homebrew Flutter SDK - manually write generated files
- No Freezed code-gen available - write state classes manually (standard Dart immutable classes)
- Riverpod providers should use manual provider declarations (not `@riverpod` annotation) since code gen is unreliable

**From Story 1.1 (Project Setup):**
- SDK constraint: `>=3.0.0 <4.0.0`
- Very Good Analysis lint rules (6.0.0) are active - follow ALL lint rules strictly
- Use `const` constructors wherever possible
- Add trailing commas per lint rules

**Git patterns established:**
- Conventional commits: `feat(scanning): implement camera viewfinder with frame overlay`
- Branch naming: `feature/story-2.1-camera-viewfinder`

### File Structure

**Files to CREATE:**
- `lib/feature/scanning/providers/camera_permission_provider.dart`
- `lib/feature/scanning/providers/camera_controller_provider.dart`
- `lib/feature/scanning/widgets/card_frame_overlay.dart`
- `lib/feature/scanning/widgets/camera_viewfinder.dart`
- `lib/feature/scanning/widgets/camera_permission_denied.dart`
- `test/feature/scanning/widgets/card_frame_overlay_test.dart`
- `test/feature/scanning/widgets/camera_permission_denied_test.dart`
- `test/feature/scanning/screens/scan_screen_test.dart`

**Files to MODIFY:**
- `lib/feature/scanning/screens/scan_screen.dart` - Replace placeholder with camera viewfinder
- `pubspec.yaml` - Add camera and permission_handler dependencies
- `ios/Runner/Info.plist` - Add NSCameraUsageDescription
- `android/app/src/main/AndroidManifest.xml` - Verify CAMERA permission

**Files NOT to touch:**
- `lib/shared/route/app_router.dart` - No routing changes needed
- `lib/shared/widget/scaffold_with_bottom_nav.dart` - No changes needed
- `lib/data/` - No database changes needed

### Project Structure Notes

- All new scanning files go in `lib/feature/scanning/` (existing directory)
- New subdirectories needed: `lib/feature/scanning/providers/`, `lib/feature/scanning/widgets/`
- Test structure mirrors source: `test/feature/scanning/providers/`, `test/feature/scanning/widgets/`
- The `lib/feature/scanning/models/` directory will be created in Story 2.4 when scan state is needed

### Testing Strategy

**Unit tests for widgets:**
- CardFrameOverlay: Verify renders, correct aspect ratio in painter, instruction text present
- CameraPermissionDenied: Verify message display, settings button exists and calls callback

**Widget tests for ScanScreen:**
- Mock the camera permission provider to test all states (loading, granted, denied)
- Mock the camera controller provider to test viewfinder rendering
- Use `ProviderScope.overrides` to inject mock providers

**Testing camera on emulator:**
- Android emulator provides a virtual camera (configurable in AVD settings)
- Widget tests should mock `CameraController` since camera hardware isn't available in test environment
- Consider creating a test helper for mocking camera providers

**What we CANNOT test in unit tests:**
- Actual camera hardware initialization
- Real permission dialogs
- Camera preview rendering (requires platform channels)
- These require manual testing on physical devices or integration tests

### References

- [Source: epics.md#Story 2.1 - Camera Viewfinder with Frame Overlay]
- [Source: architecture.md#Frontend Architecture - Camera: camera (official)]
- [Source: architecture.md#API & Communication Patterns - Scryfall Integration Flow Step 1]
- [Source: architecture.md#Structure Patterns - Feature-First Organization]
- [Source: architecture.md#State Management Patterns - Riverpod]
- [Source: ux-design-specification.md#Custom Components - CameraViewfinder]
- [Source: ux-design-specification.md#Custom Components - CardFrameOverlay]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Error]
- [Source: ux-design-specification.md#Defining Experience - Experience Mechanics]
- [Source: prd.md#Device Permissions - Camera required]
- [Source: prd.md#Non-Functional Requirements - Scan Recognition < 2 seconds]
- [Flutter camera package ^0.11.3+1](https://pub.dev/packages/camera)
- [Flutter permission_handler ^12.0.1](https://pub.dev/packages/permission_handler)
- [Flutter CustomPainter API](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- Fixed ElevatedButton.icon not rendering in Flutter test environment — replaced with standard ElevatedButton with Row child
- Fixed CustomPaint finder in CardFrameOverlay test — used descendant finder to avoid matching framework CustomPaint widgets
- Updated minSdkVersion from 20 to 26 (was expected to already be 26 per story notes, but was actually 20)

### Completion Notes List

- Implemented camera permission provider using Riverpod AsyncNotifier with check/request/recheck lifecycle
- Implemented camera controller provider that depends on permission being granted, selects back camera, uses ResolutionPreset.medium
- Created CardFrameOverlay with CustomPainter using saveLayer + BlendMode.clear for transparent cut-out with 63:88 MTG card aspect ratio
- Created CameraViewfinder composing CameraPreview with CardFrameOverlay in a Stack, with full-screen FittedBox.cover layout
- Created CameraPermissionDenied view with explanation message, settings icon, and "Open Settings" button
- Rewrote ScanScreen as ConsumerStatefulWidget with WidgetsBindingObserver for app lifecycle management
- Updated existing tests (scaffold_with_bottom_nav_test, app_router_test, app_theme_integration_test) to provide ProviderScope with mocked camera permission provider
- All 74 tests pass (10 new + 64 existing, zero regressions)

### File List

**New files:**
- lib/feature/scanning/providers/camera_permission_provider.dart
- lib/feature/scanning/providers/camera_controller_provider.dart
- lib/feature/scanning/widgets/card_frame_overlay.dart
- lib/feature/scanning/widgets/camera_viewfinder.dart
- lib/feature/scanning/widgets/camera_permission_denied.dart
- test/feature/scanning/widgets/card_frame_overlay_test.dart
- test/feature/scanning/widgets/camera_permission_denied_test.dart
- test/feature/scanning/screens/scan_screen_test.dart

**Modified files:**
- lib/feature/scanning/screens/scan_screen.dart
- pubspec.yaml
- pubspec.lock
- ios/Runner/Info.plist
- android/app/src/main/AndroidManifest.xml
- android/app/build.gradle
- test/shared/widget/scaffold_with_bottom_nav_test.dart
- test/shared/route/app_router_test.dart
- test/app/widget/app_theme_integration_test.dart
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Senior Developer Review (AI)

**Reviewer:** Claude Opus 4.6 (Adversarial Code Review)
**Date:** 2026-02-14
**Outcome:** Approved (after fixes)

**Issues Found:** 3 High, 4 Medium, 3 Low
**Issues Fixed:** 3 High, 4 Medium (all auto-fixed)
**Issues Remaining:** 3 Low (accepted as-is)

**HIGH fixes applied:**
1. AC #4 was not implemented - camera permission was only checked, never requested. Fixed `CameraPermissionNotifier.build()` to auto-request permission when not yet granted or permanently denied.
2. Task 2 subtask "Request permission if not granted" was marked [x] but not done - fixed by #1 above.
3. Double-dispose camera controller bug - `disposeCamera()` + `ref.onDispose()` would dispose the same CameraController twice on background/foreground cycle. Fixed `ref.onDispose` to use `_controller` field with null check.

**MEDIUM fixes applied:**
4. No distinction between denied/permanentlyDenied - addressed by auto-requesting in build(); permanently denied skips request and shows settings view.
5. Force unwrap of `previewSize` in CameraViewfinder - added null check with loading fallback.
6. Hardcoded `TextStyle(color: Colors.white70)` in error states - replaced with `Theme.of(context)` colors in CameraViewfinder and ScanScreen.
7. Tautological aspect ratio test - exported `cardAspectRatio` constant with `@visibleForTesting` and rewrote test to verify the actual constant.

**LOW issues accepted:**
8. Missing `Semantics` widgets for screen reader accessibility - deferred to a UX polish pass.
9. sprint-status.yaml not in File List - added to File List above.
10. Magic number for instruction text positioning - minor, acceptable for now.

**All 74 tests pass after fixes.**

## Change Log

- 2026-02-14: Implemented Story 2.1 - Camera Viewfinder with Frame Overlay. Added camera and permission_handler dependencies, created permission and controller providers, built CardFrameOverlay with 63:88 aspect ratio CustomPainter, CameraViewfinder with full-screen preview, CameraPermissionDenied view, and rewrote ScanScreen with lifecycle management. All 74 tests pass.
- 2026-02-14: Code review completed. Fixed 7 issues (3 HIGH, 4 MEDIUM): permission auto-request flow (AC #4), double-dispose camera controller bug, previewSize null safety, hardcoded styles, tautological test. Status → done.
