# Story 2.6: Add Card to Collection

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to tap to confirm and add a recognized card to my collection**,
So that **the card is saved with its image for later viewing**.

**Epic Context:** Epic 2 - Card Scanning. This is the 6th of 9 stories. Stories 2.1-2.5 built the complete recognition pipeline with visual feedback: camera viewfinder (2.1), OCR text extraction (2.2), Scryfall API integration (2.3), automatic card recognition with haptic/visual feedback (2.4), and scan result overlay showing card name + set code (2.5). This story adds the **core action** - tapping the overlay to persist the card into the local database and save its image. Story 2.7 (Duplicate Detection Display) will add the "You have X" badge. Story 2.8 (Session Counter) will add the running counter. Story 2.9 (Session Summary) will add the snackbar on navigation away.

## Acceptance Criteria

1. **Given** a scan result overlay is displayed
   **When** I tap anywhere on the overlay
   **Then** the card is saved to the local database (Drift/SQLite)

2. **Given** a scan result overlay is displayed and I tap to add
   **When** the card is saved successfully
   **Then** the scanned image is downloaded from Scryfall and saved to the app documents folder
   **And** the image path is stored in the database record

3. **Given** I tap the overlay to add a card
   **When** the save completes
   **Then** a brief "Added!" confirmation animation appears (green checkmark + text)
   **And** the confirmation replaces the card name overlay smoothly (AnimatedSwitcher)

4. **Given** I tap the overlay to add a card
   **When** the save completes
   **Then** a success haptic pulse confirms the action (HapticFeedback.mediumImpact)

5. **Given** a card has been added successfully
   **When** the "Added!" confirmation has displayed briefly (~1 second)
   **Then** the viewfinder is immediately ready for the next card
   **And** the recognition state resets to idle
   **And** the overlay disappears

6. **Given** I tap the overlay for a card that already exists in my collection
   **When** the save completes
   **Then** the card's quantity is incremented (not duplicated)
   **And** the same "Added!" confirmation appears
   **And** the behavior is identical to adding a new card

7. **Given** I tap the overlay while a previous add is still processing
   **When** a second tap occurs
   **Then** the second tap is ignored (debounce protection)

## Tasks / Subtasks

- [x] Task 1: Create ImageStorageService (AC: #2)
  - [x] Create `lib/data/services/image_storage_service.dart`
  - [x] Implement `saveCardImage(String scryfallId, String imageUrl)` that downloads from Scryfall and saves to `{appDocuments}/card_images/{scryfallId}.jpg`
  - [x] Create the `card_images/` directory if it doesn't exist
  - [x] Return the local file path on success, `null` on failure (non-throwing)
  - [x] Use Dio for HTTP download with short timeout (10s)
  - [x] Handle errors gracefully (network failure, file system error) - return null, don't throw
  - [x] Create provider in `lib/data/providers/image_storage_provider.dart`

- [x] Task 2: Create AddCardState model (AC: #3, #5, #7)
  - [x] Create `lib/feature/scanning/models/add_card_state.dart`
  - [x] Define `AddCardStatus` enum: `idle`, `adding`, `added`, `error`
  - [x] Create immutable `AddCardState` class following project pattern (@immutable, manual ==, hashCode)
  - [x] Named constructors: `.idle()`, `.adding()`, `.added()`, `.error(String message)`

- [x] Task 3: Create AddCardNotifier provider (AC: #1, #2, #3, #4, #5, #6, #7)
  - [x] Create `lib/feature/scanning/providers/add_card_provider.dart`
  - [x] Implement `AddCardNotifier extends Notifier<AddCardState>`
  - [x] `addCard(ScryfallCard card)` method:
    1. Debounce check: if state is `adding`, return immediately
    2. Set state to `adding`
    3. Save card to DB via `CardRepository.addCard()` (handles duplicate quantity increment)
    4. Set state to `added`
    5. Trigger `HapticFeedback.mediumImpact()`
    6. After ~1s delay, reset `cardRecognitionProvider` to idle and set own state to idle
    7. Fire-and-forget: download image via ImageStorageService and update DB record with image path

- [x] Task 4: Modify ScanResultOverlay to accept onTap callback (AC: #1)
  - [x] Modify `lib/feature/scanning/widgets/scan_result_overlay.dart`
  - [x] Add optional `VoidCallback? onTap` parameter
  - [x] Wrap content in `GestureDetector` when `onTap` is provided
  - [x] Add `InkWell`-like visual feedback (Material splash) on tap

- [x] Task 5: Create AddedConfirmation widget (AC: #3)
  - [x] Create widget inline in `camera_viewfinder.dart` (private widget) or in a separate file
  - [x] Display green checkmark icon + "Added!" text
  - [x] Use success color (#4CAF50) for icon and text
  - [x] Match same container styling as ScanResultOverlay (same dimensions, border radius, background)
  - [x] This widget replaces ScanResultOverlay in the AnimatedSwitcher when state is `added`

- [x] Task 6: Integrate add-card flow into CameraViewfinder (AC: #1, #3, #4, #5, #7)
  - [x] Modify `lib/feature/scanning/widgets/camera_viewfinder.dart`
  - [x] Watch `addCardProvider` in addition to existing `cardRecognitionProvider`
  - [x] AnimatedSwitcher child logic:
    - If addCardState.status == added → show AddedConfirmation widget
    - Else if recognized && recognizedCard != null → show ScanResultOverlay with onTap
    - Else → SizedBox.shrink()
  - [x] onTap callback calls `ref.read(addCardProvider.notifier).addCard(recognizedCard)`

- [x] Task 7: Write unit tests for ImageStorageService (AC: #2)
  - [x] Create `test/data/services/image_storage_service_test.dart`
  - [x] Test: successful image download and save
  - [x] Test: returns null on network error (doesn't throw)
  - [x] Test: returns null when imageUris is null
  - [x] Test: creates card_images directory if missing

- [x] Task 8: Write unit tests for AddCardNotifier (AC: #1, #3, #4, #5, #6, #7)
  - [x] Create `test/feature/scanning/providers/add_card_provider_test.dart`
  - [x] Test: addCard saves card to repository
  - [x] Test: addCard transitions state: idle → adding → added → idle
  - [x] Test: addCard triggers haptic feedback
  - [x] Test: addCard resets recognition provider after delay
  - [x] Test: addCard debounces duplicate taps (second call while adding is ignored)
  - [x] Test: addCard handles repository errors gracefully (state → error)
  - [x] Test: duplicate card increments quantity (CardRepository handles this, verify it's called)

- [x] Task 9: Write widget tests for CameraViewfinder integration (AC: #1, #3, #5)
  - [x] Extend `test/feature/scanning/widgets/camera_viewfinder_test.dart`
  - [x] Test: tapping ScanResultOverlay triggers addCard
  - [x] Test: AddedConfirmation widget appears when addCardState is `added`
  - [x] Test: ScanResultOverlay is hidden when addCardState is `adding`
  - [x] Test: viewfinder returns to idle state after add completes

## Dev Notes

### Critical Architecture Context

**This is Story 2.6 in Epic 2 (Card Scanning) - the CORE ACTION that completes the scanning flow.** Stories 2.1-2.5 built the entire pipeline from camera to visual recognition overlay. This story connects that pipeline to the **data layer**, allowing recognized cards to be persisted in the local database with their images saved for offline viewing.

**What this story does:**
- Makes the scan result overlay tappable
- Saves the recognized card to the Drift database (new card or quantity increment)
- Downloads the Scryfall card image and saves it locally
- Shows brief "Added!" confirmation with haptic feedback
- Resets the viewfinder for the next card

**What this story does NOT include (handled by later stories):**
- "You have X" duplicate count badge → Story 2.7
- Session counter in header ("14 cards") → Story 2.8
- Session summary snackbar on navigation → Story 2.9

**However, the implementation MUST support these future features:**
- Story 2.7 will need to know the current quantity of a card. The `CardRepository.getCardByScryfallId()` already returns this. The `AddCardNotifier` should return or expose whether the card was new vs duplicate for Story 2.7 to build on.
- Story 2.8 will need to track how many cards were added per session. Consider exposing a counter or event stream.

### Key Technical Patterns

**AddCardState (immutable state class):**
```dart
import 'package:flutter/foundation.dart';

enum AddCardStatus { idle, adding, added, error }

@immutable
class AddCardState {
  const AddCardState._({
    required this.status,
    this.errorMessage,
  });

  const AddCardState.idle()
      : this._(status: AddCardStatus.idle);

  const AddCardState.adding()
      : this._(status: AddCardStatus.adding);

  const AddCardState.added()
      : this._(status: AddCardStatus.added);

  const AddCardState.error(String message)
      : this._(
          status: AddCardStatus.error,
          errorMessage: message,
        );

  final AddCardStatus status;
  final String? errorMessage;

  @override
  bool operator ==(Object other) { /* ... */ }

  @override
  int get hashCode => Object.hash(status, errorMessage);
}
```

**AddCardNotifier (orchestrates the add flow):**
```dart
class AddCardNotifier extends Notifier<AddCardState> {
  @override
  AddCardState build() => const AddCardState.idle();

  Future<void> addCard(ScryfallCard card) async {
    // Debounce: ignore tap if already adding
    if (state.status == AddCardStatus.adding) return;

    state = const AddCardState.adding();

    try {
      final repository = ref.read(cardRepositoryProvider);

      // 1. Save card to DB immediately (fast, local)
      await repository.addCard(
        scryfallId: card.id,
        name: card.name,
        type: card.typeLine,
        setCode: card.setCode,
        oracleText: card.oracleText,
        manaCost: card.manaCost,
        colors: card.colors?.join(','),
      );

      // 2. Show "Added!" + haptic
      state = const AddCardState.added();
      await HapticFeedback.mediumImpact();

      // 3. After brief delay, reset viewfinder
      await Future.delayed(const Duration(milliseconds: 1000));
      ref.read(cardRecognitionProvider.notifier).reset();
      state = const AddCardState.idle();

      // 4. Background: download image and update DB
      _downloadImageInBackground(card, repository);
    } on Exception catch (e) {
      state = AddCardState.error('Failed to add card: $e');
    }
  }

  Future<void> _downloadImageInBackground(
    ScryfallCard card,
    CardRepository repository,
  ) async {
    try {
      final imageService = ref.read(imageStorageServiceProvider);
      final imageUrl = card.imageUris?.normal;
      if (imageUrl == null) return;

      final localPath = await imageService.saveCardImage(
        card.id,
        imageUrl,
      );
      if (localPath == null) return;

      // Update DB record with image path
      final savedCard = await repository.getCardByScryfallId(card.id);
      if (savedCard != null) {
        await repository.updateCard(
          savedCard.copyWith(imagePath: localPath),
        );
      }
    } on Exception {
      // Silently fail - card is already saved, image is non-critical
    }
  }
}

final addCardProvider =
    NotifierProvider<AddCardNotifier, AddCardState>(
  AddCardNotifier.new,
);
```

**ImageStorageService:**
```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageStorageService {
  ImageStorageService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  /// Downloads a card image and saves it locally.
  /// Returns the local file path, or null if download/save failed.
  Future<String?> saveCardImage(
    String scryfallId,
    String imageUrl,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'card_images'));
      if (!imageDir.existsSync()) {
        await imageDir.create(recursive: true);
      }

      final filePath = p.join(imageDir.path, '$scryfallId.jpg');
      await _dio.download(imageUrl, filePath);
      return filePath;
    } on Exception {
      return null;
    }
  }

  void dispose() {
    _dio.close();
  }
}
```

**ScanResultOverlay modification (add onTap callback):**
```dart
class ScanResultOverlay extends StatelessWidget {
  const ScanResultOverlay({
    required this.card,
    this.onTap,
    super.key,
  });

  final ScryfallCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ... existing container code unchanged
      ),
    );
  }
}
```

**CameraViewfinder integration (AnimatedSwitcher child logic):**
```dart
// In CameraViewfinder build method:
final addCardState = ref.watch(addCardProvider);

// ... existing code ...

// AnimatedSwitcher child selection:
Widget switcherChild;
if (addCardState.status == AddCardStatus.added) {
  switcherChild = _AddedConfirmation(
    key: const ValueKey('added'),
  );
} else if (isRecognized && recognizedCard != null &&
           addCardState.status != AddCardStatus.adding) {
  switcherChild = ScanResultOverlay(
    key: ValueKey(recognizedCard.id),
    card: recognizedCard,
    onTap: () => ref
        .read(addCardProvider.notifier)
        .addCard(recognizedCard),
  );
} else {
  switcherChild = const SizedBox.shrink();
}
```

**AddedConfirmation widget (private, in camera_viewfinder.dart):**
```dart
class _AddedConfirmation extends StatelessWidget {
  const _AddedConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer
            .withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Added!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Previous Story Intelligence

**From Story 2.5 (Scan Result Overlay) - MOST RECENT:**
- `ScanResultOverlay` is a `StatelessWidget` receiving `ScryfallCard` directly (decoupled from providers)
- Integrated in `CameraViewfinder` Stack as 3rd child, wrapped in `Positioned` + `AnimatedSwitcher`
- `AnimatedSwitcher` with `ValueKey(recognizedCard.id)` handles card-to-card transitions
- 200ms appear / 150ms disappear durations
- Container has `minHeight: 48` constraint (touch target ready)
- Uses `theme.colorScheme.surfaceContainer.withValues(alpha: 0.85)` for background
- Safe area: `bottom: 24 + MediaQuery.of(context).padding.bottom`
- All 160 tests pass at end of Story 2.5

**From Story 2.5 Code Review:**
- `Positioned` inside `ScanResultOverlay` conflicted with `AnimatedSwitcher` - fix: `Positioned` stays in parent, overlay returns just Container
- Added `maxLines: 2` + `overflow: TextOverflow.ellipsis` for long card names
- Typography test uses resolved theme `titleMedium` (not hardcoded value)
- Test helper wraps in `Stack` > `Positioned` matching production layout

**From Story 2.4 (Automatic Card Recognition):**
- `CardRecognitionNotifier` has `reset()` method to return to idle state
- `processFrame()` checks `state.status == RecognitionStatus.processing` for throttle
- Haptic feedback uses `HapticFeedback.lightImpact()` (50ms) for recognition
- Story 2.6 should use `HapticFeedback.mediumImpact()` for add confirmation (different feel)

**From Story 2.1 Code Review:**
- `ElevatedButton.icon` doesn't render in Flutter test - use standard widgets
- Hardcoded styles should use `Theme.of(context)` consistently

**From All Previous Stories:**
- `build_runner` does NOT work - all code must be manual (no Freezed, no @riverpod annotations)
- Very Good Analysis 6.0.0: trailing commas, `const` constructors, required params before optional
- `@immutable` annotation + manual `operator==`/`hashCode` for state classes
- Feature folder: `lib/feature/` (SINGULAR, not plural)
- `mocktail: ^1.0.4` available for test mocking
- Providers use manual `Provider<T>((ref) => ...)` pattern with `ref.onDispose` for cleanup
- Dio 5.0.1: uses `DioError` and `DioErrorType` (NOT `DioException`/`DioExceptionType`)

### Architecture Compliance Notes

**ScryfallCard → CardRepository field mapping:**
| ScryfallCard field | CardRepository.addCard() param | Notes |
|---|---|---|
| `card.id` | `scryfallId` | Scryfall UUID |
| `card.name` | `name` | Card name |
| `card.typeLine` | `type` | Type line |
| `card.setCode` | `setCode` | Set code (lowercase) |
| `card.oracleText` | `oracleText` | Rules text (nullable) |
| `card.manaCost` | `manaCost` | Mana cost string (nullable) |
| `card.colors?.join(',')` | `colors` | List→comma-separated string |
| (from ImageStorageService) | `imagePath` | Set via background update |

**CardRepository.addCard() behavior:**
- If card with same `scryfallId` exists → calls `_dao.incrementQuantity(existing.id)` → quantity +1
- If card is new → inserts via `_dao.insertCard(companion)` with quantity=1
- Returns `bool` (true on success)
- This means Story 2.6 does NOT need separate duplicate-handling logic

**Image storage path convention:**
- Base directory: `{appDocumentsDirectory}/card_images/`
- File name: `{scryfallId}.jpg` (Scryfall IDs are UUIDs, guaranteed unique)
- Image source: `card.imageUris?.normal` (488x680 JPG, ~50-100KB)
- Fallback: if `imageUris` is null (some special cards), skip image download

**Background image download approach (CRITICAL):**
- Card is saved to DB **immediately** (without imagePath) for instant "Added!" feedback
- Image is downloaded in the background AFTER the "Added!" confirmation
- Once download completes, DB record is updated with the local file path
- If download fails, card is still in the DB (just without a local image)
- This ensures "viewfinder is immediately ready for the next card" (AC #5)

**Packages already available (no new dependencies needed):**
- `dio: ^5.0.1` - HTTP client for image download
- `path_provider: ^2.1.5` - App documents directory
- `path: ^1.9.1` - Path manipulation
- `flutter_riverpod: ^2.6.1` - State management
- `camera: ^0.11.0+2` - Camera access
- `mocktail: ^1.0.4` - Test mocking

### Project Structure Notes

**Files to CREATE:**
- `lib/data/services/image_storage_service.dart` - Downloads and saves card images locally
- `lib/data/providers/image_storage_provider.dart` - Provides ImageStorageService via Riverpod
- `lib/feature/scanning/models/add_card_state.dart` - Immutable state for add-card flow
- `lib/feature/scanning/providers/add_card_provider.dart` - Orchestrates add-to-collection
- `test/data/services/image_storage_service_test.dart` - Unit tests for image storage
- `test/feature/scanning/providers/add_card_provider_test.dart` - Unit tests for add card flow

**Files to MODIFY:**
- `lib/feature/scanning/widgets/scan_result_overlay.dart` - Add `onTap` callback, wrap in `GestureDetector`
- `lib/feature/scanning/widgets/camera_viewfinder.dart` - Watch `addCardProvider`, add tap handler, add `_AddedConfirmation` widget, update AnimatedSwitcher logic

**Files to EXTEND (tests):**
- `test/feature/scanning/widgets/camera_viewfinder_test.dart` - Add tests for tap-to-add and "Added!" display

**Files NOT to touch:**
- `lib/feature/scanning/models/recognition_state.dart` - No changes needed
- `lib/feature/scanning/providers/card_recognition_provider.dart` - No changes (reset() already exists)
- `lib/feature/scanning/providers/frame_processor_provider.dart` - No changes
- `lib/feature/scanning/providers/camera_controller_provider.dart` - No changes
- `lib/feature/scanning/screens/scan_screen.dart` - No changes
- `lib/feature/scanning/widgets/card_frame_overlay.dart` - No changes
- `lib/data/models/scryfall_card.dart` - No changes
- `lib/data/models/card.dart` - No changes
- `lib/data/repositories/card_repository.dart` - No changes (addCard + getCardByScryfallId + updateCard already exist)
- `lib/data/database/*` - No changes
- `lib/data/providers/database_provider.dart` - No changes (cardRepositoryProvider already exists)
- `pubspec.yaml` - No new packages needed

### Testing Strategy

**Unit tests for ImageStorageService:**
- Mock Dio with `mocktail` to simulate download responses
- Mock `path_provider` using `TestWidgetsFlutterBinding` and method channel mocks
- Test successful download: verify file path returned, correct directory used
- Test network error: verify null returned, no exception thrown
- Test null imageUrl: verify null returned gracefully

**Unit tests for AddCardNotifier:**
- Override `cardRepositoryProvider` with mock CardRepository
- Override `imageStorageServiceProvider` with mock ImageStorageService
- Override `cardRecognitionProvider` with mock notifier
- Test state transitions: idle → adding → added → idle
- Test debounce: call addCard twice quickly, verify repository called only once
- Test haptic: verify `HapticFeedback.mediumImpact()` called (mock via TestDefaultBinaryMessengerBinding)
- Test recognition reset: verify `cardRecognitionProvider.notifier.reset()` called after delay
- Test error handling: mock repository to throw, verify state → error

**Widget tests for CameraViewfinder:**
- Override all providers (camera, recognition, addCard)
- Test tap on ScanResultOverlay: set recognition to `recognized`, tap, verify `addCard` called
- Test "Added!" display: set addCardState to `added`, verify `_AddedConfirmation` in tree
- Test overlay hidden during adding: set addCardState to `adding`, verify ScanResultOverlay hidden

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
  imageUris: ScryfallImageUris(
    small: 'https://cards.scryfall.io/small/test.jpg',
    normal: 'https://cards.scryfall.io/normal/test.jpg',
    large: 'https://cards.scryfall.io/large/test.jpg',
    png: 'https://cards.scryfall.io/png/test.png',
    artCrop: 'https://cards.scryfall.io/art_crop/test.jpg',
    borderCrop: 'https://cards.scryfall.io/border_crop/test.jpg',
  ),
);
```

### Performance Budget

| Stage | Budget | Notes |
|-------|--------|-------|
| Tap recognition | ~1ms | GestureDetector callback |
| DB insert/increment | ~5-15ms | Local SQLite via Drift |
| Haptic feedback | ~2ms | System call |
| State update + rebuild | ~16ms | Single Riverpod notification |
| "Added!" animation | 200ms | AnimatedSwitcher fade |
| Reset delay | 1000ms | Intentional pause for user feedback |
| **User-visible total** | **~1.2s** | From tap to viewfinder ready |
| Image download (background) | 500-3000ms | Non-blocking, doesn't affect UX |

### References

- [Source: epics.md#Story 2.6 - Add Card to Collection]
- [Source: prd.md#Functional Requirements - FR4: Confirm and add card, FR12: Store scanned image]
- [Source: architecture.md#Data Architecture - Image Storage: File System]
- [Source: architecture.md#API & Communication Patterns - Scryfall Integration Flow step 5]
- [Source: architecture.md#Implementation Patterns - State Management Patterns]
- [Source: architecture.md#Project Structure & Boundaries - Scanning Feature → Card Repository]
- [Source: ux-design-specification.md#Defining Experience - Experience Mechanics - Completion]
- [Source: ux-design-specification.md#UX Consistency Patterns - Feedback Patterns - Scan Success]
- [Source: ux-design-specification.md#Visual Design Foundation - Color System - Success: #4CAF50]
- [Source: ux-design-specification.md#Flow Optimization Principles - Minimize taps to value]
- [Source: 2-5-scan-result-overlay.md#Dev Notes - ScanResultOverlay widget pattern]
- [Source: 2-5-scan-result-overlay.md#Dev Notes - CameraViewfinder AnimatedSwitcher integration]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

None - clean implementation with no blocking issues.

### Completion Notes List

- **Task 1:** Created `ImageStorageService` with Dio-based image download, `card_images/` directory management, and non-throwing error handling. Provider created with `ref.onDispose` for cleanup.
- **Task 2:** Created `AddCardState` immutable model with `AddCardStatus` enum (idle/adding/added/error) following project pattern (manual `==`/`hashCode`, named constructors).
- **Task 3:** Created `AddCardNotifier` orchestrating the full add-card flow: debounce check, DB save, haptic feedback, 1s "Added!" delay, recognition reset, and fire-and-forget background image download with `unawaited()`.
- **Task 4:** Modified `ScanResultOverlay` to accept optional `onTap` callback, wrapping content in `GestureDetector`.
- **Task 5:** Created `_AddedConfirmation` private widget in `camera_viewfinder.dart` with green checkmark icon + "Added!" text, matching `ScanResultOverlay` container styling.
- **Task 6:** Integrated add-card flow into `CameraViewfinder`: watches `addCardProvider`, updates `AnimatedSwitcher` child logic (added > recognized > empty), wires `onTap` to `addCard()`.
- **Task 7:** 5 unit tests for `ImageStorageService` - successful download, directory creation, network error returns null, file system error returns null, dispose closes Dio.
- **Task 8:** 9 unit tests for `AddCardNotifier` - initial state, saves to repo, state transitions, haptic feedback, recognition reset, debounce, error handling, background image download, skip download when no imageUris.
- **Task 9:** 4 widget tests for `CameraViewfinder` add-card integration - tap triggers addCard, "Added!" confirmation display, overlay hidden during adding, idle state after completion.

### Change Log

- 2026-02-15: Implemented Story 2.6 - Add Card to Collection. Created ImageStorageService, AddCardState, AddCardNotifier. Modified ScanResultOverlay with onTap. Integrated add-card flow into CameraViewfinder with AddedConfirmation widget. Added 18 new tests (5 + 9 + 4). All 178 tests pass.
- 2026-02-15: **Code Review Fixes (3 MEDIUM issues):** (1) Replaced GestureDetector with Material+InkWell for visual tap feedback on ScanResultOverlay. (2) Kept overlay visible during `adding` state for smooth crossfade to "Added!" confirmation. (3) Expanded background image download test to verify full DB update chain (getCardByScryfallId + updateCard with imagePath). Updated scan_result_overlay_test to match new Ink-based structure. All 178 tests pass.

### File List

**New files:**
- `lib/data/services/image_storage_service.dart`
- `lib/data/providers/image_storage_provider.dart`
- `lib/feature/scanning/models/add_card_state.dart`
- `lib/feature/scanning/providers/add_card_provider.dart`
- `test/data/services/image_storage_service_test.dart`
- `test/feature/scanning/providers/add_card_provider_test.dart`

**Modified files:**
- `lib/feature/scanning/widgets/scan_result_overlay.dart`
- `lib/feature/scanning/widgets/camera_viewfinder.dart`
- `test/feature/scanning/widgets/camera_viewfinder_test.dart`
- `test/feature/scanning/widgets/scan_result_overlay_test.dart`
