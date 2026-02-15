# Story 2.5: Scan Result Overlay

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to see the recognized card name and set displayed after a successful scan**,
So that **I can confirm it's the correct card before adding**.

**Epic Context:** Epic 2 - Card Scanning. This is the 5th of 9 stories. Stories 2.1-2.4 built the complete recognition pipeline: camera viewfinder (2.1), OCR text extraction (2.2), Scryfall API integration (2.3), and automatic card recognition with visual/haptic feedback (2.4). This story adds the information overlay that tells the user WHAT was recognized. Story 2.6 (Add Card to Collection) will add the tap-to-add action on this overlay. Story 2.7 (Duplicate Detection Display) will add the "You have X" badge to this overlay.

## Acceptance Criteria

1. **Given** a card has been successfully recognized (RecognitionStatus == recognized)
   **When** recognition completes
   **Then** an overlay appears showing the card name and set code (e.g., "Lightning Bolt" / "LEA")

2. **Given** the scan result overlay is displayed
   **When** the user views it
   **Then** the overlay appears over the camera viewfinder with a semi-transparent background
   **And** the card name uses Title Medium typography for clear readability
   **And** the set code is displayed below the card name in a secondary style

3. **Given** the scan result overlay is visible
   **When** the camera recognizes a different card (new name extracted)
   **Then** the overlay updates to show the new card's name and set code
   **And** the transition between cards feels smooth (no jarring flash)

4. **Given** the scan result overlay is visible
   **When** recognition state returns to idle (e.g., card removed from frame, error occurs)
   **Then** the overlay disappears and the viewfinder returns to its default state

5. **Given** the overlay is displayed
   **When** the user views it on any supported device size
   **Then** the overlay is positioned at the bottom of the screen above the navigation bar
   **And** the overlay does not obstruct the card frame area
   **And** minimum touch target size (48x48dp) is maintained for future tap-to-add (Story 2.6)

## Tasks / Subtasks

- [x] Task 1: Create ScanResultOverlay widget (AC: #1, #2, #5)
  - [x] Create `lib/feature/scanning/widgets/scan_result_overlay.dart`
  - [x] Build a `StatelessWidget` that takes a `ScryfallCard` directly (decoupled from provider)
  - [x] Display card name (Title Medium) and set code (Body Medium) on semi-transparent dark surface
  - [x] Position at bottom of screen, above bottom navigation, below the card frame cutout
  - [x] Use `AnimatedSwitcher` or `AnimatedOpacity` for smooth appear/disappear transitions
  - [x] Ensure minimum 48x48dp overall touch area for future tap-to-add (Story 2.6 readiness)
  - [x] Use theme colors: Surface (#1E1E1E) with ~85% opacity background, white text

- [x] Task 2: Integrate ScanResultOverlay into CameraViewfinder (AC: #1, #2, #4)
  - [x] Modify `lib/feature/scanning/widgets/camera_viewfinder.dart`
  - [x] Add `ScanResultOverlay` to the existing `Stack` (after `CardFrameOverlay`)
  - [x] The overlay should only render when `recognitionState.status == RecognitionStatus.recognized`
  - [x] Pass `recognitionState.recognizedCard` to the overlay widget

- [x] Task 3: Handle card transition and disappearance (AC: #3, #4)
  - [x] When `recognizedCard` changes (different card recognized), animate transition
  - [x] When status returns to `idle` or `processing`, overlay fades out smoothly
  - [x] Use `AnimatedSwitcher` with `key` based on card id for card-to-card transitions
  - [x] Fade duration: ~200ms for appear, ~150ms for disappear

- [x] Task 4: Write widget tests for ScanResultOverlay (AC: #1, #2, #3, #4, #5)
  - [x] Create `test/feature/scanning/widgets/scan_result_overlay_test.dart`
  - [x] Test: overlay displays card name when recognized
  - [x] Test: overlay displays set code when recognized
  - [x] Test: overlay is hidden when status is idle
  - [x] Test: overlay is hidden when status is processing (covered by "hidden when not in widget tree")
  - [x] Test: overlay updates when a different card is recognized
  - [x] Test: overlay uses correct typography (Title Medium for name)

- [x] Task 5: Write updated widget tests for CameraViewfinder integration (AC: #1, #4)
  - [x] Create `test/feature/scanning/widgets/camera_viewfinder_test.dart`
  - [x] Test: ScanResultOverlay is present in the widget tree when recognized
  - [x] Test: ScanResultOverlay is absent when idle

## Dev Notes

### Critical Architecture Context

**This is Story 2.5 in Epic 2 (Card Scanning) - the information display layer on top of the recognition pipeline.** Story 2.4 wired the complete pipeline (camera stream -> OCR -> Scryfall -> state update + green pulse + haptic). This story adds a visible overlay widget that tells the user WHAT card was recognized, displaying the card name and set code.

**What this story does:**
- Creates a new `ScanResultOverlay` widget that renders card name + set code
- Integrates it into the existing `CameraViewfinder` Stack
- Adds smooth animated transitions (appear, disappear, card-to-card switch)

**What this story does NOT include (handled by later stories):**
- Tap-to-add-to-collection action -> Story 2.6
- Duplicate detection "You have X" badge -> Story 2.7
- Session counter in header -> Story 2.8
- Session summary on navigation -> Story 2.9

**However, the widget MUST be designed to support these future features:**
- The overlay must be tappable (minimum 48dp touch target) for Story 2.6
- The widget layout must accommodate an additional badge/text for Story 2.7
- Keep the widget composable so future stories can add children without refactoring

### Key Technical Patterns

**ScanResultOverlay Widget Pattern:**
```dart
/// Overlay showing the recognized card's name and set code.
/// Positioned at the bottom of the camera viewfinder.
class ScanResultOverlay extends StatelessWidget {
  const ScanResultOverlay({
    super.key,
    required this.card,
  });

  final ScryfallCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,  // Above bottom nav area
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer
              .withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.name, style: theme.textTheme.titleMedium),
            Text(card.setCode.toUpperCase(),
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
```
**NOTE:** The widget takes a `ScryfallCard` directly, NOT `RecognitionState`. Keep it simple and decoupled - the parent (`CameraViewfinder`) controls visibility based on state.

**Integration into CameraViewfinder (current Stack):**
```dart
// In camera_viewfinder.dart, inside the Stack:
return Stack(
  children: [
    SizedBox.expand(/* camera preview */),
    CardFrameOverlay(recognitionStatus: recognitionState.status),
    // NEW: Scan result overlay - only when recognized
    if (recognitionState.status == RecognitionStatus.recognized &&
        recognitionState.recognizedCard != null)
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ScanResultOverlay(
          key: ValueKey(recognitionState.recognizedCard!.id),
          card: recognitionState.recognizedCard!,
        ),
      ),
  ],
);
```

**AnimatedSwitcher Pattern for Smooth Transitions:**
- Use `AnimatedSwitcher` wrapping the `ScanResultOverlay`
- The `key: ValueKey(card.id)` ensures card-to-card transitions animate (old card fades out, new fades in)
- When status is not `recognized`, pass `SizedBox.shrink()` to AnimatedSwitcher so it fades out

**Alternative: Simpler approach using AnimatedOpacity:**
```dart
// If AnimatedSwitcher causes issues with Positioned in Stack:
Positioned(
  left: 16, right: 16, bottom: 24,
  child: AnimatedOpacity(
    opacity: isRecognized ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 200),
    child: isRecognized
        ? ScanResultOverlay(card: recognitionState.recognizedCard!)
        : const SizedBox.shrink(),
  ),
),
```

**Theme Usage (CRITICAL - use theme, not hardcoded colors):**
```dart
final theme = Theme.of(context);
// Card name: titleMedium (Material 3 Title Medium)
Text(card.name, style: theme.textTheme.titleMedium?.copyWith(
  color: theme.colorScheme.onSurface,  // #FFFFFF
))
// Set code: bodyMedium secondary
Text(card.setCode.toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(
  color: theme.colorScheme.onSurfaceVariant,  // #E0E0E0
))
// Background: surfaceContainer (#1E1E1E) with alpha
theme.colorScheme.surfaceContainer.withValues(alpha: 0.85)
```

### Previous Story Intelligence

**From Story 2.4 (Automatic Card Recognition) - MOST RECENT:**
- `RecognitionState` has `status` (enum), `recognizedCard` (ScryfallCard?), `errorMessage`, `lastExtractedName`
- `cardRecognitionProvider` is `NotifierProvider<CardRecognitionNotifier, RecognitionState>`
- `CameraViewfinder` already watches `cardRecognitionProvider` and extracts `recognitionState`
- `CardFrameOverlay` receives `recognitionStatus` parameter for green pulse animation
- The `Stack` in `CameraViewfinder` has exactly 2 children: camera preview + CardFrameOverlay
- Story 2.5 adds the 3rd child to this Stack

**From Story 2.4 Code Review:**
- `CardFramePainter` widget tests use `find.byWidgetPredicate` to target specific `CustomPaint` widgets
- Test pattern: wrap in `MaterialApp` + `Scaffold`, use `tester.pump()` for animations
- `HapticFeedback.lightImpact()` requires `TestWidgetsFlutterBinding.ensureInitialized()` in tests

**From Story 2.1 Code Review:**
- `ElevatedButton.icon` doesn't render in Flutter test - use standard `ElevatedButton` with `Row` child
- Hardcoded styles should use `Theme.of(context)` consistently

**From All Previous Stories:**
- `build_runner` does NOT work - all code must be manual (no Freezed, no @riverpod annotations)
- Very Good Analysis 6.0.0: trailing commas, `const` constructors, required params before optional
- `@immutable` annotation + manual `operator==`/`hashCode` for state classes (not needed here since we're making a StatelessWidget)
- Feature folder: `lib/feature/` (SINGULAR, not plural)
- `mocktail: ^1.0.4` available for test mocking
- No existing `camera_viewfinder_test.dart` file - Task 5 creates this new file

**Git commit pattern:**
- `feat(scanning): implement Story 2.5 - Scan Result Overlay`

### Architecture Compliance Notes

**ScryfallCard fields available for display:**
- `name` (String) - e.g., "Lightning Bolt"
- `setCode` (String) - e.g., "lea" (lowercase from Scryfall API, display as uppercase)
- `setName` (String) - e.g., "Limited Edition Alpha" (full name, could use as tooltip or secondary info)
- `typeLine` (String) - e.g., "Instant" (NOT displayed in this story, but available)
- `manaCost` (String?) - e.g., "{R}" (NOT displayed in this story)

**Card frame positioning context:**
The CardFrameOverlay cutout is centered on screen:
- Width: 80% of screen width (`_cutoutWidthFraction = 0.80`)
- Height: calculated from 63:88 MTG aspect ratio
- The cutout center is at screen center
- The overlay instruction text is at `bottom: 15%` of screen height
- The ScanResultOverlay MUST sit BELOW the card cutout and above the instruction text area, OR replace the instruction text when recognized

**Positioning strategy:**
- The card cutout bottom edge is approximately at: `screenHeight/2 + cutoutHeight/2`
- For a 812px screen (iPhone 14): cutout bottom ~= 406 + 228 = ~634px from top, ~178px from bottom
- For a 667px screen (iPhone SE): cutout bottom ~= 333 + 188 = ~521px from top, ~146px from bottom
- The scan result overlay at `bottom: 24` with padding should work on all devices
- Consider using `MediaQuery.of(context).padding.bottom` for safe area

**The overlay must NOT be a `Positioned.fill` widget.**
It must be `Positioned` with explicit bottom/left/right to avoid covering the card frame cutout and blocking camera interaction. The semi-transparent background should be confined to the overlay card, not full screen.

**Widget test considerations:**
- `ScanResultOverlay` is a simple StatelessWidget - test it in isolation
- For CameraViewfinder integration tests, you'll need to mock the Riverpod providers
- Use `ProviderScope(overrides: [...])` to inject test state
- Mock `cameraControllerProvider` (needs AsyncValue wrapper)
- The camera package needs `TestWidgetsFlutterBinding.ensureInitialized()`

### File Structure

**Files to CREATE:**
- `lib/feature/scanning/widgets/scan_result_overlay.dart` - New overlay widget
- `test/feature/scanning/widgets/scan_result_overlay_test.dart` - Widget tests
- `test/feature/scanning/widgets/camera_viewfinder_test.dart` - New integration tests

**Files to MODIFY:**
- `lib/feature/scanning/widgets/camera_viewfinder.dart` - Add ScanResultOverlay to Stack

**Files NOT to touch:**
- `lib/feature/scanning/models/recognition_state.dart` - No changes needed
- `lib/feature/scanning/providers/card_recognition_provider.dart` - No changes needed
- `lib/feature/scanning/providers/frame_processor_provider.dart` - No changes needed
- `lib/feature/scanning/providers/camera_controller_provider.dart` - No changes needed
- `lib/feature/scanning/screens/scan_screen.dart` - No changes needed
- `lib/feature/scanning/widgets/card_frame_overlay.dart` - No changes needed
- `lib/data/models/scryfall_card.dart` - No changes needed
- `pubspec.yaml` - No new packages needed (all Flutter built-in widgets)

### Testing Strategy

**Widget tests for ScanResultOverlay (isolated):**
- Wrap in `MaterialApp(theme: AppTheme.darkTheme, home: Scaffold(body: ...))` to ensure theme is available
- Create test `ScryfallCard` fixtures with known name/setCode values
- Test that `find.text('Lightning Bolt')` finds the card name
- Test that `find.text('LEA')` finds the set code (uppercase)
- Test typography: find `Text` widget and verify style matches `titleMedium`
- Test no content renders when widget is absent from tree (handled by parent)

**Widget tests for CameraViewfinder integration:**
- Override `cameraControllerProvider` with mock `AsyncValue.data(mockController)`
- Override `cardRecognitionProvider` with `RecognitionState.recognized(testCard)`
- Override `frameProcessorProvider` with `true`
- Verify `ScanResultOverlay` appears in widget tree
- Change override to `RecognitionState.idle()` and verify overlay absent
- Camera mocking pattern: mock `CameraController` with `value.isInitialized = true` and `value.previewSize = Size(1920, 1080)`

**Test fixtures:**
```dart
const testCard = ScryfallCard(
  id: 'test-id-123',
  name: 'Lightning Bolt',
  typeLine: 'Instant',
  manaCost: '{R}',
  cmc: 1,
  colors: ['R'],
  setCode: 'lea',
  setName: 'Limited Edition Alpha',
  rarity: 'common',
);
```

### Performance Budget

| Stage | Budget | Notes |
|-------|--------|-------|
| Widget build | ~2ms | Simple Column with 2 Text widgets |
| Animation | 200ms | AnimatedSwitcher fade transition |
| State reaction | ~16ms | Riverpod rebuild on recognition state change |
| **Total** | **~218ms** | Imperceptible to user |

This is purely UI work - no network calls, no heavy computation. Performance is not a concern for this story.

### References

- [Source: epics.md#Story 2.5 - Scan Result Overlay]
- [Source: architecture.md#Frontend Architecture - Key Screens]
- [Source: architecture.md#Implementation Patterns - State Management Patterns]
- [Source: architecture.md#Project Structure & Boundaries - Scanning Feature]
- [Source: prd.md#Functional Requirements - FR3: See recognized card name and set]
- [Source: ux-design-specification.md#Custom Components - ScanResultOverlay]
- [Source: ux-design-specification.md#Visual Design Foundation - Typography System]
- [Source: ux-design-specification.md#Visual Design Foundation - Color System]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Success]
- [Source: ux-design-specification.md#Defining Experience - Experience Mechanics - Feedback]
- [Flutter AnimatedSwitcher](https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html)
- [Flutter Positioned](https://api.flutter.dev/flutter/widgets/Positioned-class.html)
- [Material 3 Typography](https://m3.material.io/styles/typography)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- `Positioned` inside `ScanResultOverlay` conflicted with `AnimatedSwitcher` (which wraps children in `FadeTransition`). Fix: moved `Positioned` to the parent `CameraViewfinder` Stack and made `ScanResultOverlay` return just the Container content.

### Completion Notes List

- Created `ScanResultOverlay` as a simple `StatelessWidget` taking a `ScryfallCard` directly (not a `ConsumerWidget` watching providers - kept decoupled per Dev Notes guidance)
- Integrated into `CameraViewfinder` Stack as the 3rd child, wrapped in `Positioned` + `AnimatedSwitcher`
- `AnimatedSwitcher` with `ValueKey(card.id)` handles card-to-card transitions; `SizedBox.shrink()` child when not recognized handles fade-out
- 200ms appear / 150ms disappear durations for smooth transitions
- Uses theme colors: `surfaceContainer` with 85% opacity background, `onSurface` for card name, `onSurfaceVariant` for set code
- 48dp minimum height constraint for future tap-to-add (Story 2.6)
- All 159 tests pass (6 new ScanResultOverlay + 2 new CameraViewfinder integration + 151 existing)
- No new analysis issues introduced

### File List

- `lib/feature/scanning/widgets/scan_result_overlay.dart` (NEW) - ScanResultOverlay widget
- `lib/feature/scanning/widgets/camera_viewfinder.dart` (MODIFIED) - Added ScanResultOverlay integration with AnimatedSwitcher + safe area
- `test/feature/scanning/widgets/scan_result_overlay_test.dart` (NEW) - 5 widget tests
- `test/feature/scanning/widgets/camera_viewfinder_test.dart` (NEW) - 4 integration tests

## Senior Developer Review (AI)

**Reviewer:** Guillaume (Code Review Workflow)
**Date:** 2026-02-15
**Outcome:** Approved with fixes applied

### Issues Found & Fixed (7 total: 2 Medium, 5 Low)

**MEDIUM:**
- M1: Added safe area handling (`MediaQuery.of(context).padding.bottom`) to overlay positioning in `camera_viewfinder.dart` - prevents overlap with home indicator on modern iPhones
- M2: Removed tautological test "is hidden when not in widget tree" from `scan_result_overlay_test.dart` - it tested nothing meaningful (widget absent because never added)

**LOW:**
- L1: Added `processing` and `error` state tests to `camera_viewfinder_test.dart` to cover AC#4 fully
- L2: Made typography test resilient by comparing against resolved theme `titleMedium` instead of hardcoded `16.0`
- L3: Added `maxLines: 2` and `overflow: TextOverflow.ellipsis` to card name Text for long/double-faced card names
- L4: Updated File List to reflect accurate test counts after review
- L5: Updated test helper to wrap in `Stack` > `Positioned` matching production layout context

### Post-Review Test Results
- All 160 tests pass (5 ScanResultOverlay + 4 CameraViewfinder integration + 151 existing)
- No analysis issues in modified files

## Change Log

- 2026-02-15: Implemented Story 2.5 - Scan Result Overlay. Created ScanResultOverlay widget showing card name (Title Medium) and set code (Body Medium uppercase) on semi-transparent dark surface. Integrated into CameraViewfinder Stack with AnimatedSwitcher for smooth appear/disappear/card-switch transitions. Added 8 new tests (6 widget + 2 integration). All 159 tests pass.
- 2026-02-15: Code review fixes applied. Added safe area handling, overflow protection for long card names, removed tautological test, added processing/error state tests, improved typography test resilience, updated test context to match production layout. All 160 tests pass.
