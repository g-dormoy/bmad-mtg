# Story 2.3: Scryfall API Integration

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want **a service that looks up cards via Scryfall's fuzzy search API**,
So that **extracted card names can be matched to official card data**.

**Epic Context:** Epic 2 - Card Scanning. This is the 3rd of 9 stories. The OCR service (Story 2.2) extracts card names from camera frames. This story provides the API layer that converts those names into official card data. Story 2.4 (Automatic Card Recognition) will wire OCR + Scryfall together into the live recognition pipeline.

## Acceptance Criteria

1. **Given** an extracted card name string
   **When** I call the Scryfall service
   **Then** the API endpoint `https://api.scryfall.com/cards/named?fuzzy={name}` is called

2. **Given** a successful API response (HTTP 200)
   **When** the response is parsed
   **Then** it returns: name, type_line, mana_cost, colors, set_code (field: `set`), and image_uris

3. **Given** a 404 response from Scryfall
   **When** the error is handled
   **Then** the service indicates card not found (distinguishing "not found" from "ambiguous match")

4. **Given** a network error (no connectivity, timeout, server error)
   **When** the error is handled
   **Then** a clear, typed error is returned (not a raw exception)

5. **Given** the service implementation
   **When** reviewed for architecture compliance
   **Then** the service uses Dio with proper error handling

6. **Given** the service code
   **When** unit tests run
   **Then** tests mock API responses and verify all success/error paths

## Tasks / Subtasks

- [x] Task 1: Create ScryfallCard model (AC: #2)
  - [x] Create `lib/data/models/scryfall_card.dart`
  - [x] Define `ScryfallCard` immutable class with fields: id, name, typeLine, manaCost, cmc, colors, setCode, setName, imageUris, oracleText, rarity
  - [x] Define `ScryfallImageUris` class with fields: small, normal, large, png, artCrop, borderCrop
  - [x] Add `ScryfallCard.fromJson(Map<String, dynamic>)` factory constructor
  - [x] Handle multi-faced cards: if top-level `image_uris` is null, extract from `card_faces[0]`
  - [x] Write manually (no Freezed code-gen - build_runner doesn't work with Homebrew Flutter SDK)

- [x] Task 2: Create ScryfallException typed errors (AC: #3, #4)
  - [x] Create `lib/data/services/scryfall_exception.dart`
  - [x] Define `ScryfallException` base class implementing `Exception`
  - [x] Add subclasses: `ScryfallNotFoundException`, `ScryfallAmbiguousException`, `ScryfallNetworkException`, `ScryfallServerException`
  - [x] `ScryfallAmbiguousException` stores the `details` string from API error response
  - [x] Follow `OcrException` pattern from Story 2.2

- [x] Task 3: Create ScryfallService (AC: #1, #2, #3, #4, #5)
  - [x] Create `lib/data/services/scryfall_service.dart`
  - [x] Create dedicated `Dio` instance with Scryfall base URL `https://api.scryfall.com`
  - [x] Set `User-Agent: MTGCollectionApp/1.0` header (Scryfall requires this)
  - [x] Set `Accept: application/json` header
  - [x] Set connect/receive timeout to 10 seconds
  - [x] Implement `Future<ScryfallCard> searchByName(String fuzzyName)`:
    - Call `GET /cards/named?fuzzy={fuzzyName}`
    - Parse 200 response into `ScryfallCard.fromJson()`
    - Map 404 with `type: "ambiguous"` → `ScryfallAmbiguousException`
    - Map 404 without ambiguous → `ScryfallNotFoundException`
    - Map network/timeout → `ScryfallNetworkException`
    - Map 5xx → `ScryfallServerException`
  - [x] Implement `void dispose()` to close the Dio instance

- [x] Task 4: Create Riverpod provider (AC: #5)
  - [x] Create `lib/feature/scanning/providers/scryfall_provider.dart`
  - [x] Create `scryfallServiceProvider` as `Provider<ScryfallService>`
  - [x] Dispose service on provider disposal via `ref.onDispose`
  - [x] Follow existing manual provider declaration pattern (not @riverpod annotation)

- [x] Task 5: Write unit tests for ScryfallCard model (AC: #2, #6)
  - [x] Create `test/data/models/scryfall_card_test.dart`
  - [x] Test: fromJson parses a complete Scryfall API response
  - [x] Test: fromJson handles null/missing optional fields (mana_cost, oracle_text)
  - [x] Test: fromJson extracts image_uris from card_faces[0] when top-level is null (multi-faced cards)
  - [x] Test: colors list is correctly parsed from JSON array

- [x] Task 6: Write unit tests for ScryfallService (AC: #1, #3, #4, #6)
  - [x] Create `test/data/services/scryfall_service_test.dart`
  - [x] Test: searchByName calls correct endpoint with fuzzy parameter
  - [x] Test: successful response returns parsed ScryfallCard
  - [x] Test: 404 response throws ScryfallNotFoundException
  - [x] Test: 404 with ambiguous type throws ScryfallAmbiguousException
  - [x] Test: DioError (timeout/network) throws ScryfallNetworkException
  - [x] Test: 500 response throws ScryfallServerException
  - [x] Use `MockAdapter` or mock Dio interceptor for HTTP mocking

## Dev Notes

### Critical Architecture Context

**This is Story 2.3 in Epic 2 (Card Scanning) - the Scryfall API bridge.** This service converts OCR-extracted card names (from Story 2.2) into official card data from Scryfall. Story 2.4 (Automatic Card Recognition) depends on this service to complete the camera → OCR → API → display pipeline. Story 2.6 (Add Card to Collection) will use the `ScryfallCard` model data to save cards to the Drift database.

**Service placement:** `lib/data/services/scryfall_service.dart` - following the architecture document's data layer placement. The `OcrService` from Story 2.2 is already in `lib/data/services/`, establishing this pattern.

**Model placement:** `lib/data/models/scryfall_card.dart` - alongside the existing `Card` domain model in `lib/data/models/card.dart`.

**Provider placement:** `lib/feature/scanning/providers/scryfall_provider.dart` - the Riverpod provider lives in the scanning feature since Scryfall lookup is only used by scanning.

**Feature folder convention:** `lib/feature/` (SINGULAR, not `lib/features/`). This convention was established by the starter template and confirmed in all stories 1.1-2.2. Architecture doc shows `lib/features/` (plural) but the actual project uses `lib/feature/` - **follow the actual project convention**.

### Key Technical Patterns

**DO NOT use the existing `ApiProvider` (`lib/shared/http/api_provider.dart`).** It is designed around authenticated requests with token management, a dotenv-configured base URL, and the project's internal API patterns. Scryfall is a public API with no authentication. Create a **dedicated Dio instance** inside `ScryfallService` with Scryfall-specific configuration.

**Dedicated Dio Instance Pattern:**
```dart
class ScryfallService {
  ScryfallService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.scryfall.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'User-Agent': 'MTGCollectionApp/1.0',
                'Accept': 'application/json',
              },
            ));

  final Dio _dio;
  // ...
}
```
Note: The `ScryfallService({Dio? dio})` constructor pattern allows injecting a mock Dio for testing - same testability pattern used in `OcrService.withRecognizer()` from Story 2.2.

**Scryfall API Details:**
- Endpoint: `GET /cards/named?fuzzy={name}`
- Fuzzy search is case-insensitive, tolerates misspellings and partial words
- Returns HTTP 200 with a Card JSON object on success
- Returns HTTP 404 for not-found OR ambiguous matches (check `type` field in error response)
- No authentication required - completely public API
- **Required headers:** `User-Agent` (identifies your app) and `Accept: application/json`
- **Rate limit:** 50-100ms between requests recommended. No rate limit headers returned; 429 if exceeded. Not a concern for single-card lookups.

**Scryfall Error Response Format:**
```json
{
  "object": "error",
  "code": "not_found",
  "type": "ambiguous",
  "status": 404,
  "details": "Too many cards match ambiguous name \"nissa\"."
}
```
Check `response.data['type'] == 'ambiguous'` to distinguish ambiguous from not-found.

**Multi-Faced Card Handling (CRITICAL):**
Cards with layouts like `transform`, `modal_dfc`, `split` have `image_uris: null` at top level. Instead, they have a `card_faces` array where each face has its own `image_uris`. The `ScryfallCard.fromJson()` MUST handle this:
```dart
// Pseudo-logic for image_uris extraction:
final imageUrisJson = json['image_uris'] as Map<String, dynamic>?
    ?? (json['card_faces'] as List?)?.first['image_uris'] as Map<String, dynamic>?;
```

**ScryfallCard Model - Key Fields to Parse:**

| JSON field | Dart field | Type | Notes |
|------------|-----------|------|-------|
| `id` | `id` | `String` | UUID |
| `name` | `name` | `String` | "Lightning Bolt" or "Front // Back" |
| `type_line` | `typeLine` | `String` | "Instant" or "Creature — Human Wizard" |
| `mana_cost` | `manaCost` | `String?` | "{R}" - null for lands |
| `cmc` | `cmc` | `double` | Mana value (e.g., 1.0) |
| `colors` | `colors` | `List<String>?` | ["R"] - WUBRG notation |
| `set` | `setCode` | `String` | "lea", "cmm" |
| `set_name` | `setName` | `String` | "Limited Edition Alpha" |
| `oracle_text` | `oracleText` | `String?` | Rules text |
| `rarity` | `rarity` | `String` | "common", "uncommon", "rare", "mythic" |
| `image_uris` | `imageUris` | `ScryfallImageUris?` | See multi-face handling above |

**ScryfallImageUris - Fields:**

| JSON field | Dart field | Type |
|------------|-----------|------|
| `small` | `small` | `String` | 146x204 JPG |
| `normal` | `normal` | `String` | 488x680 JPG |
| `large` | `large` | `String` | 672x936 JPG |
| `png` | `png` | `String` | 745x1040 PNG |
| `art_crop` | `artCrop` | `String` | Art-only crop |
| `border_crop` | `borderCrop` | `String` | 480x680 JPG |

**Riverpod Provider Pattern (matching existing providers):**
```dart
// Manual provider declaration - NOT @riverpod annotation
// (build_runner doesn't work with Homebrew Flutter SDK)
final scryfallServiceProvider = Provider<ScryfallService>((ref) {
  final service = ScryfallService();
  ref.onDispose(service.dispose);
  return service;
});
```

**Exception Hierarchy Pattern (following OcrException from Story 2.2):**
```dart
class ScryfallException implements Exception {
  const ScryfallException(this.message, [this.cause]);
  final String message;
  final Object? cause;
}

class ScryfallNotFoundException extends ScryfallException {
  const ScryfallNotFoundException(super.message);
}

class ScryfallAmbiguousException extends ScryfallException {
  const ScryfallAmbiguousException(super.message);
}

class ScryfallNetworkException extends ScryfallException {
  const ScryfallNetworkException(super.message, [super.cause]);
}

class ScryfallServerException extends ScryfallException {
  const ScryfallServerException(super.message, [super.cause]);
}
```

### Previous Story Intelligence

**From Story 2.2 (OCR Text Extraction):**
- `OcrService` is in `lib/data/services/ocr_service.dart` - follow same service pattern
- `OcrException` typed exception pattern established - replicate for Scryfall
- `OcrService.withRecognizer()` constructor enables testability - use same `ScryfallService({Dio? dio})` pattern
- `ocrServiceProvider` in `lib/feature/scanning/providers/ocr_provider.dart` - follow same provider placement
- `mocktail: ^1.0.4` is available as dev dependency for mocking

**From Story 2.2 Code Review:**
- `defaultTargetPlatform` preferred over `dart:io` Platform for testability
- Typed exceptions (`OcrException`) with `cause` parameter established
- Error handling in service methods wraps raw exceptions into typed ones

**From Story 2.1 (Camera Viewfinder):**
- Camera controller provider pattern with `ref.onDispose` for cleanup
- `ElevatedButton.icon` not rendering in Flutter test environment - use standard `ElevatedButton` with `Row` child
- Hardcoded styles replaced with theme colors - use `Theme.of(context)` consistently

**From Story 1.2 (Database):**
- `build_runner` does NOT work with Homebrew Flutter SDK - write ALL code manually
- No Freezed code-gen available - write immutable classes manually with `@immutable`, `operator==`, `hashCode`, `copyWith()`
- The `Card` domain model in `lib/data/models/card.dart` uses this manual pattern - follow it for `ScryfallCard`
- `CardRepository.addCard()` takes `scryfallId`, `name`, `type`, `manaCost`, `colors`, `setCode`, `imagePath` - these must map from `ScryfallCard` fields

**From Story 1.1 (Project Setup):**
- Very Good Analysis lint rules (6.0.0) are active - follow ALL lint rules strictly
- Use `const` constructors wherever possible
- Add trailing commas per lint rules
- SDK constraint: `>=3.0.0 <4.0.0`

**Git patterns established:**
- Conventional commits: `feat(scanning): implement Scryfall API integration`
- Branch naming: `feature/story-2.3-scryfall-api-integration`

### Architecture Deviation Note

**iOS deployment target is 15.5** (raised from architecture doc's "iOS 14+" in Story 2.2 for ML Kit compatibility). This does NOT affect the Scryfall service but is important context.

**The existing `ApiProvider` is NOT used** for Scryfall. This is intentional - `ApiProvider` is designed for authenticated internal APIs with token management. Scryfall is a public API. Creating a dedicated Dio instance inside `ScryfallService` is cleaner and avoids coupling to the project's auth infrastructure.

### File Structure

**Files to CREATE:**
- `lib/data/models/scryfall_card.dart` - ScryfallCard + ScryfallImageUris models
- `lib/data/services/scryfall_exception.dart` - Typed exception hierarchy
- `lib/data/services/scryfall_service.dart` - API service with Dio
- `lib/feature/scanning/providers/scryfall_provider.dart` - Riverpod provider
- `test/data/models/scryfall_card_test.dart` - Model unit tests
- `test/data/services/scryfall_service_test.dart` - Service unit tests

**Files NOT to touch:**
- `lib/shared/http/api_provider.dart` - Do NOT use for Scryfall
- `lib/data/services/ocr_service.dart` - No changes needed
- `lib/data/models/card.dart` - No changes to domain model
- `lib/data/repositories/card_repository.dart` - No changes until Story 2.6
- `lib/feature/scanning/screens/scan_screen.dart` - No UI changes until Story 2.4
- `lib/feature/scanning/widgets/*` - No UI changes in this story
- `pubspec.yaml` - Dio (`^5.0.1`) is already a dependency, no new packages needed

### Project Structure Notes

- New model file goes in `lib/data/models/` alongside existing `card.dart`
- New service files go in `lib/data/services/` alongside existing `ocr_service.dart`
- New provider file goes in `lib/feature/scanning/providers/` alongside existing `ocr_provider.dart`
- Test structure mirrors source: `test/data/models/`, `test/data/services/`
- No new directories needed - all parent directories already exist
- No `pubspec.yaml` changes needed - Dio is already installed

### Testing Strategy

**Unit tests for ScryfallCard model:**
- Use real Scryfall API response JSON fixtures (hardcoded in test)
- Test standard single-faced card parsing (Lightning Bolt)
- Test multi-faced card parsing (transform card with `card_faces`)
- Test null/missing optional fields (land with no mana_cost)
- Test colors array parsing

**Unit tests for ScryfallService:**
- Use `MockAdapter` or create a mock `Dio` via `mocktail` to intercept HTTP calls
- Pattern: inject mock Dio via `ScryfallService(dio: mockDio)` constructor
- Test each error path: 404 not-found, 404 ambiguous, network error, server error
- Verify correct endpoint URL and query parameters

**What we CANNOT test in unit tests:**
- Actual Scryfall API availability/responses
- Real network conditions
- Rate limiting behavior
- These require manual testing or integration tests

### References

- [Source: epics.md#Story 2.3 - Scryfall API Integration]
- [Source: architecture.md#API & Communication Patterns - Scryfall Integration Flow]
- [Source: architecture.md#API & Communication Patterns - Error Handling Strategy]
- [Source: architecture.md#Core Architectural Decisions - API: Dio]
- [Source: architecture.md#Structure Patterns - Feature-First Organization]
- [Source: architecture.md#Implementation Patterns - Error Handling Patterns]
- [Source: architecture.md#Naming Patterns - JSON/API Naming]
- [Source: architecture.md#Project Structure - data/services/scryfall_service.dart]
- [Source: prd.md#Non-Functional Requirements - NFR8: Scryfall API required]
- [Source: prd.md#Non-Functional Requirements - NFR9: Scanning fails gracefully offline]
- [Source: prd.md#Non-Functional Requirements - NFR10: API errors user-friendly]
- [Source: ux-design-specification.md#UX Consistency Patterns - Scan Error]
- [Scryfall REST API - /cards/named endpoint](https://scryfall.com/docs/api/cards/named)
- [Scryfall Error Objects](https://scryfall.com/docs/api/errors)
- [Scryfall Card Object Schema](https://scryfall.com/docs/api/cards)
- [Dio ^5.0.1 (already installed)](https://pub.dev/packages/dio)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (claude-opus-4-6)

### Debug Log References

- Dio 5.0.1 uses `DioError`/`DioErrorType` (not `DioException`/`DioExceptionType`). Story Dev Notes referenced Dio 5.x naming which changed in later 5.x releases. Adapted to match the actual installed version.

### Completion Notes List

- Task 1: Created `ScryfallCard` and `ScryfallImageUris` immutable model classes with manual `fromJson`, `operator==`, `hashCode`, `toString`. Multi-faced card handling extracts `image_uris` from `card_faces[0]` when top-level is null.
- Task 2: Created `ScryfallException` hierarchy with 4 subclasses following the `OcrException` pattern. `ScryfallAmbiguousException` captures API `details` field.
- Task 3: Created `ScryfallService` with dedicated Dio instance, `searchByName()` fuzzy search, and typed error mapping. Uses `DioError` (Dio 5.0.1 API).
- Task 4: Created `scryfallServiceProvider` as manual `Provider<ScryfallService>` with `ref.onDispose` cleanup, matching `ocrServiceProvider` pattern.
- Task 5: 8 unit tests for model: JSON parsing, null fields, multi-faced cards, colors array, equality.
- Task 6: 8 unit tests for service: endpoint verification, success parsing, 404 not-found, 404 ambiguous, timeout/network error, 500 server error, dispose.
- Full test suite: 110/110 tests pass (16 new + 94 existing). Zero regressions.
- Code Review: Fixed 7 issues (1 HIGH, 6 MEDIUM). Added generic catch for non-DioError exceptions, input validation, 4xx error handling, immutable colors list, subclass toString overrides, fixed doc comment references, added 2 new tests. 112/112 tests pass post-review.

### File List

- `lib/data/models/scryfall_card.dart` (new) - ScryfallCard + ScryfallImageUris models
- `lib/data/services/scryfall_exception.dart` (new) - Typed exception hierarchy
- `lib/data/services/scryfall_service.dart` (new) - Scryfall API service with Dio
- `lib/feature/scanning/providers/scryfall_provider.dart` (new) - Riverpod provider
- `test/data/models/scryfall_card_test.dart` (new) - Model unit tests (8 tests)
- `test/data/services/scryfall_service_test.dart` (new) - Service unit tests (10 tests)

## Change Log

- 2026-02-14: Implemented Story 2.3 - Scryfall API Integration. Created ScryfallCard model, ScryfallException hierarchy, ScryfallService with Dio, Riverpod provider, and 16 unit tests. All 110 tests pass.
- 2026-02-14: Code Review - Fixed 7 issues (1 HIGH, 6 MEDIUM). Hardened error handling, added input validation, enforced immutability, added 2 new tests. 112/112 tests pass.
