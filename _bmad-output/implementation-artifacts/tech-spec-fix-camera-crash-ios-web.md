---
title: 'Fix Camera Crash on iOS and Graceful Web Degradation'
slug: 'fix-camera-crash-ios-web'
created: '2026-02-15'
status: 'completed'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['Flutter', 'Riverpod (manual providers)', 'camera ^0.11.3+1', 'google_mlkit_text_recognition ^0.15.1', 'permission_handler ^12.0.1']
files_to_modify: ['lib/feature/scanning/providers/camera_controller_provider.dart', 'ios/Runner/Info.plist', 'lib/feature/scanning/screens/scan_screen.dart', 'test/feature/scanning/screens/scan_screen_test.dart']
code_patterns: ['Manual Riverpod providers with ref.onDispose', 'platformTypeProvider override at app start', 'AsyncNotifier for async state', 'CameraPermissionDenied as UI pattern for unavailable states']
test_patterns: ['Provider overrides with mock notifiers implementing interface', 'ProviderScope wrapping in tests', 'flutter_test with pumpWidget/pumpAndSettle']
---

# Tech-Spec: Fix Camera Crash on iOS and Graceful Web Degradation

**Created:** 2026-02-15

## Overview

### Problem Statement

The scanning feature crashes on iOS due to the `camera` plugin requesting microphone access without the required `NSMicrophoneUsageDescription` plist key. On web, it crashes because `google_mlkit_text_recognition` and `camera` don't support the platform — resulting in an unhandled crash instead of a user-friendly message.

### Solution

Disable audio on the camera controller (only video is needed for card scanning), add `NSMicrophoneUsageDescription` to Info.plist as a safety net, and add platform detection in `ScanScreen` to show an "unavailable on web" message instead of attempting to initialize unsupported plugins.

### Scope

**In Scope:**
- Set `enableAudio: false` on `CameraController`
- Add `NSMicrophoneUsageDescription` to Info.plist as fallback
- Platform-aware check in `ScanScreen` to show an unavailable message on web
- Keep existing mobile scanning pipeline untouched

**Out of Scope:**
- Web-compatible OCR implementation
- Android-specific fixes (not reported broken)
- Any changes to the recognition pipeline logic

## Context for Development

### Codebase Patterns

- **Provider pattern:** Manual `Provider<T>((ref) => ...)` and `AsyncNotifierProvider` with `ref.onDispose` for cleanup. No code generation.
- **Platform detection:** `platformTypeProvider` (a `Provider<PlatformType>`) is overridden at app startup in `start.dart` via `detectPlatformType()`. Available project-wide through `ref.watch(platformTypeProvider)`.
- **UI pattern for unavailable states:** `CameraPermissionDenied` widget uses centered layout with icon + title text + body text + action button. The web-unavailable widget should follow this same visual pattern.
- **Lint rules:** Very Good Analysis 6.0.0 — strict, requires trailing commas, `const` constructors, required params before optional.

### Files to Reference

| File | Purpose |
| ---- | ------- |
| `lib/feature/scanning/providers/camera_controller_provider.dart` | `CameraController` creation — add `enableAudio: false` |
| `ios/Runner/Info.plist` | iOS privacy keys — add `NSMicrophoneUsageDescription` |
| `lib/feature/scanning/screens/scan_screen.dart` | Entry point for scanning — add web platform guard |
| `lib/shared/util/platform_type.dart` | Existing `platformTypeProvider` and `PlatformType.web` enum |
| `lib/feature/scanning/widgets/camera_permission_denied.dart` | UI pattern reference for the web-unavailable view |
| `test/feature/scanning/screens/scan_screen_test.dart` | Existing tests — add web platform guard test |

### Technical Decisions

- Audio capture is unnecessary for card scanning — disabling it removes the microphone permission requirement entirely.
- `NSMicrophoneUsageDescription` added as defense-in-depth in case a future change re-enables audio.
- Web degradation uses the existing `platformTypeProvider` (not raw `kIsWeb`) to follow the established project pattern and enable easy test overrides.
- The web-unavailable check goes in `ScanScreen.build()` before the permission check — this prevents `permission_handler` from being called on web (which has limited support).

## Implementation Plan

### Tasks

- [x] Task 1: Disable audio capture on CameraController
  - File: `lib/feature/scanning/providers/camera_controller_provider.dart`
  - Action: Add `enableAudio: false` to the `CameraController` constructor call at line 39
  - Notes: Change from `CameraController(backCamera, ResolutionPreset.medium, imageFormatGroup: ...)` to `CameraController(backCamera, ResolutionPreset.medium, enableAudio: false, imageFormatGroup: ...)`. This is the primary iOS fix — prevents AVCaptureSession from requesting microphone access.

- [x] Task 2: Add NSMicrophoneUsageDescription to Info.plist
  - File: `ios/Runner/Info.plist`
  - Action: Add `<key>NSMicrophoneUsageDescription</key><string>Microphone access is not used but required by the camera plugin</string>` after the existing `NSCameraUsageDescription` entry (after line 54)
  - Notes: Defense-in-depth. Even though Task 1 disables audio, this ensures the app won't crash if a future change or plugin update re-enables it.

- [x] Task 3: Add web platform guard in ScanScreen
  - File: `lib/feature/scanning/screens/scan_screen.dart`
  - Action: In `build()`, before the `permissionAsync.when(...)` block, check `ref.watch(platformTypeProvider)`. If `PlatformType.web`, return a centered "not available" view instead of proceeding to camera/permission logic.
  - Notes: Import `platform_type.dart`. The web-unavailable view should follow the `CameraPermissionDenied` visual pattern: centered column with `Icons.web_asset_off` (or `Icons.desktop_access_disabled`), title "Card scanning is not available on web", body text "Use the iOS or Android app to scan cards", no action button needed. Use `const` constructor. This guard must come before `ref.watch(cameraPermissionProvider)` to prevent `permission_handler` from being invoked on web.

- [x] Task 4: Add web platform guard test
  - File: `test/feature/scanning/screens/scan_screen_test.dart`
  - Action: Add a new test case that overrides `platformTypeProvider` to `PlatformType.web` and verifies the web-unavailable message is displayed.
  - Notes: Follow the existing test pattern — `ProviderScope` with overrides, `MaterialApp` wrapping. Override both `platformTypeProvider` with `PlatformType.web` and `cameraPermissionProvider` with the pending notifier (to ensure the permission path is never reached). Assert `find.text('Card scanning is not available on web')` is found and `find.byType(CameraPermissionDenied)` is not found.

### Acceptance Criteria

- [ ] AC 1: Given the app is running on iOS, when the user navigates to the scan screen and grants camera permission, then the camera preview starts without crashing (no `__abort_with_payload` abort).
- [ ] AC 2: Given the app is running on iOS, when `enableAudio` is set to `false` on `CameraController`, then the app does not prompt for or require microphone permission.
- [ ] AC 3: Given the app is running on web, when the user navigates to the scan screen, then a message "Card scanning is not available on web" is displayed instead of attempting to initialize the camera or request permissions.
- [ ] AC 4: Given the app is running on web, when the scan screen loads, then `cameraPermissionProvider` and `cameraControllerProvider` are never invoked.
- [ ] AC 5: Given the app is running on iOS or Android, when the user navigates to the scan screen, then the existing camera/permission/recognition pipeline works unchanged.
- [ ] AC 6: Given the test suite runs, when the web platform guard test executes, then it passes — verifying the unavailable message is shown when `platformTypeProvider` is `PlatformType.web`.

## Additional Context

### Dependencies

- No new packages required. All changes use existing dependencies.
- `platformTypeProvider` from `lib/shared/util/platform_type.dart` is already available.

### Testing Strategy

- **Unit tests:** Add a test in `scan_screen_test.dart` that overrides `platformTypeProvider` to `PlatformType.web` and verifies the web-unavailable message is shown (not the camera viewfinder or permission denied views).
- **Manual verification:**
  - iOS device: Navigate to scan screen, grant camera permission, confirm camera preview loads without crash.
  - Chrome (web): Navigate to scan screen, confirm "Card scanning is not available on web" message appears.
  - Android device (regression): Confirm scanning still works as before.

### Notes

- The `camera` package `CameraController` constructor accepts `enableAudio` (defaults to `true`). Setting it to `false` prevents `AVCaptureSession` from requesting microphone access on iOS.
- `google_mlkit_text_recognition` is fundamentally mobile-only (uses platform channels to native ML Kit SDK). Web OCR would require a completely different approach (out of scope).
- The web guard is placed in `ScanScreen` (the screen level) rather than in individual providers, because it's the earliest point where we can short-circuit the entire camera pipeline cleanly.
- Risk: Low. All changes are additive or parameter changes. No existing logic is modified.

## Review Notes
- Adversarial review completed
- Findings: 5 total, 3 fixed, 2 skipped
- Resolution approach: auto-fix
- F1 (Medium): Reworded NSMicrophoneUsageDescription to avoid App Store rejection
- F2 (Medium): Changed ref.watch to ref.read for static platformTypeProvider
- F3 (Medium): Skipped — false positive, parent scaffold from navigation shell already provides navigation
- F4 (Low): Skipped — existing tests implicitly cover this via platformTypeProvider.overrideWithValue(PlatformType.iOS)
- F5 (Low): Skipped — code was already correct (onSurfaceVariant), reviewer misread diff
