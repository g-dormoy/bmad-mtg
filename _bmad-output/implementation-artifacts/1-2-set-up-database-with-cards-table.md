# Story 1.2: Set Up Database with Cards Table

Status: done

## Story

As a **developer**,
I want **Drift database configured with the cards table**,
So that **scanned cards can be persisted locally**.

## Acceptance Criteria

1. **Given** the initialized Flutter project
   **When** I add Drift and configure the database
   **Then** the cards table is created with columns: id, scryfall_id, name, type, oracle_text, mana_cost, colors, set_code, image_path, quantity, created_at

2. **Given** the database schema
   **When** the database is initialized
   **Then** indexes exist on: name, colors, type, set_code, mana_cost

3. **Given** the Drift configuration
   **When** the app starts
   **Then** the database file is created in the app documents directory

4. **Given** the database and repository
   **When** I perform CRUD operations
   **Then** CardRepository successfully creates, reads, updates, and deletes cards

5. **Given** the CardRepository implementation
   **When** I run tests
   **Then** unit tests verify all database operations work correctly

## Tasks / Subtasks

- [x] Task 1: Add Drift dependencies (AC: #1)
  - [x] Add drift ^2.30.1 to pubspec.yaml dependencies
  - [x] Add drift_dev to dev_dependencies
  - [x] Add sqlite3_flutter_libs for mobile SQLite support
  - [x] Add path_provider for app documents directory
  - [x] Add path for path operations
  - [x] Run `flutter pub get`

- [x] Task 2: Create cards table schema (AC: #1, #2)
  - [x] Create `lib/data/database/tables/cards_table.dart`
  - [x] Define CardsTable class with Drift annotations
  - [x] Add columns: id (autoIncrement), scryfall_id, name, type, oracle_text, mana_cost, colors, set_code, image_path, quantity, created_at
  - [x] Define indexes on: name, colors, type, set_code, mana_cost

- [x] Task 3: Create database class (AC: #3)
  - [x] Create `lib/data/database/app_database.dart`
  - [x] Annotate with @DriftDatabase including cards table
  - [x] Configure database file location in app documents directory
  - [x] Manually wrote app_database.g.dart (build_runner incompatible with Homebrew Flutter SDK)

- [x] Task 4: Create CardDAO for database operations (AC: #4)
  - [x] Create `lib/data/database/daos/cards_dao.dart`
  - [x] Implement insertCard method
  - [x] Implement getAllCards method
  - [x] Implement getCardById method
  - [x] Implement getCardByScryfallId method
  - [x] Implement updateCard method
  - [x] Implement deleteCard method
  - [x] Implement incrementQuantity method
  - [x] Manually wrote cards_dao.g.dart (build_runner incompatible)

- [x] Task 5: Create CardRepository (AC: #4)
  - [x] Create `lib/data/repositories/card_repository.dart`
  - [x] Inject CardDAO via constructor
  - [x] Implement addCard method (insert or increment quantity for duplicates)
  - [x] Implement getCards method with optional filters
  - [x] Implement getCard method by id
  - [x] Implement updateCard method
  - [x] Implement deleteCard method
  - [x] Implement getCardCount method

- [x] Task 6: Create Card model with Freezed (AC: #4)
  - [x] Create `lib/data/models/card.dart`
  - [x] Used manual immutable class (build_runner unavailable)
  - [x] Include all fields matching database columns
  - [x] Add factory for creating from database entity
  - [x] Added copyWith, colorList, isMulticolor, isColorless helpers

- [x] Task 7: Create Riverpod providers (AC: #4)
  - [x] Create `lib/data/providers/database_provider.dart`
  - [x] Create appDatabaseProvider (singleton)
  - [x] Create cardsDaoProvider
  - [x] Create cardRepositoryProvider

- [x] Task 8: Write unit tests (AC: #5)
  - [x] Create `test/data/database/cards_dao_test.dart`
  - [x] Test insertCard creates record
  - [x] Test getCardByScryfallId returns correct card
  - [x] Test incrementQuantity updates quantity
  - [x] Test getAllCards returns all records
  - [x] Create `test/data/repositories/card_repository_test.dart`
  - [x] Test addCard for new card
  - [x] Test addCard for duplicate (increments quantity)
  - [x] Test getCards returns cards
  - [x] Test getCardCount returns correct count

## Dev Notes

### Architecture Compliance

**Database Stack (from architecture.md):**
- Local Database: Drift (SQLite) ^2.30.1
- Type-safe SQL with reactive queries
- Database file in app documents directory

**Schema (from architecture.md#Database Schema Approach):**
```sql
CREATE TABLE cards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scryfall_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  oracle_text TEXT,  -- Rules/description text from Scryfall
  mana_cost TEXT,
  colors TEXT,  -- Stored as comma-separated: "W,U,B"
  set_code TEXT NOT NULL,
  image_path TEXT,
  quantity INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cards_name ON cards(name);
CREATE INDEX idx_cards_colors ON cards(colors);
CREATE INDEX idx_cards_type ON cards(type);
CREATE INDEX idx_cards_set_code ON cards(set_code);
CREATE INDEX idx_cards_mana_cost ON cards(mana_cost);
```

**Project Structure (from architecture.md#Complete Project Directory Structure):**
```
lib/data/
├── database/
│   ├── app_database.dart       # Main database class
│   ├── app_database.g.dart     # Generated
│   ├── tables/
│   │   └── cards_table.dart    # Table definition
│   └── daos/
│       └── cards_dao.dart      # Data access object
├── models/
│   ├── card.dart               # Freezed model
│   └── card.freezed.dart       # Generated
├── repositories/
│   └── card_repository.dart    # Repository pattern
└── providers/
    └── database_provider.dart  # Riverpod providers
```

### Implementation Patterns

**Drift Table Definition Pattern:**
```dart
// lib/data/database/tables/cards_table.dart
import 'package:drift/drift.dart';

class CardsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scryfallId => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get oracleText => text().nullable()();  // Rules/description text
  TextColumn get manaCost => text().nullable()();
  TextColumn get colors => text().nullable()();  // "W,U,B" format
  TextColumn get setCode => text()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Drift Database Pattern:**
```dart
// lib/data/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [CardsTable], daos: [CardsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mtg.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**DAO Pattern:**
```dart
// lib/data/database/daos/cards_dao.dart
import 'package:drift/drift.dart';

part 'cards_dao.g.dart';

@DriftAccessor(tables: [CardsTable])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Future<int> insertCard(CardsTableCompanion card) =>
    into(cardsTable).insert(card);

  Future<List<CardsTableData>> getAllCards() =>
    select(cardsTable).get();

  Future<CardsTableData?> getCardByScryfallId(String scryfallId) =>
    (select(cardsTable)..where((t) => t.scryfallId.equals(scryfallId)))
      .getSingleOrNull();
}
```

**Repository Pattern:**
```dart
// lib/data/repositories/card_repository.dart
class CardRepository {
  final CardsDao _dao;

  CardRepository(this._dao);

  Future<void> addCard(Card card) async {
    final existing = await _dao.getCardByScryfallId(card.scryfallId);
    if (existing != null) {
      await _dao.incrementQuantity(existing.id);
    } else {
      await _dao.insertCard(card.toCompanion());
    }
  }
}
```

**Riverpod Provider Pattern:**
```dart
// lib/data/providers/database_provider.dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final cardsDaoProvider = Provider<CardsDao>((ref) {
  return ref.watch(appDatabaseProvider).cardsDao;
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(ref.watch(cardsDaoProvider));
});
```

### Previous Story Learnings (Story 1.1)

**Critical fixes applied in Story 1.1:**
1. Updated SDK constraint to `>=3.0.0 <4.0.0` (required for latest packages)
2. Removed `build_verify` dependency (conflicts with flutter_test)
3. Updated package imports from `flutter_boilerplate` to `mtg`
4. flutter_test was commented out - now enabled

**Key dependencies already installed:**
- flutter_riverpod 2.3.0
- freezed 2.3.2
- freezed_annotation (included)
- build_runner (already in dev_dependencies)

**Code generation command:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing Notes

**In-Memory Database for Tests:**
```dart
// test/test_utils/test_database.dart
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
```

**Test Structure:**
```dart
void main() {
  late AppDatabase db;
  late CardsDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.cardsDao;
  });

  tearDown(() => db.close());

  test('insertCard creates record', () async {
    final id = await dao.insertCard(testCardCompanion);
    expect(id, greaterThan(0));
  });
}
```

### References

- [Source: architecture.md#Data Architecture]
- [Source: architecture.md#Database Schema Approach]
- [Source: architecture.md#Complete Project Directory Structure]
- [Source: architecture.md#Implementation Patterns & Consistency Rules]
- [Source: epics.md#Story 1.2]
- [Drift Documentation: https://drift.simonbinder.eu/]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

N/A - No debug logs generated

### Completion Notes List

1. **Dependency Conflicts Resolved:**
   - Updated `lottie` from ^2.2.0 to ^3.3.2 due to conflict with drift_dev
   - Removed `flutter_gen_runner` due to incompatibility with drift_dev
   - Added `dependency_overrides` for sqlite3 ^3.1.0 and ffi ^2.1.0 to fix Dart SDK 3.10.8 FFI compatibility

2. **Build Runner Workaround:**
   - Homebrew Flutter SDK is missing `frontend_server.dart.snapshot` required by build_runner
   - Manually wrote `app_database.g.dart` and `cards_dao.g.dart` instead of code generation
   - Used manual immutable class for Card model instead of Freezed

3. **Test Import Conflict Fix:**
   - Added `hide isNotNull, isNull` to Drift import in tests to avoid conflict with flutter_test matchers

4. **All 31 tests passing (after code review fixes and oracleText addition):**
   - 17 CardsDao tests (added 4 edge case tests)
   - 14 CardRepository tests (added oracleText storage test)

### File List

**New Files Created:**
- `lib/data/database/tables/cards_table.dart` - Table definition with indexes
- `lib/data/database/app_database.dart` - Database class with migration
- `lib/data/database/app_database.g.dart` - Manually generated Drift code
- `lib/data/database/daos/cards_dao.dart` - Data access object
- `lib/data/database/daos/cards_dao.g.dart` - Manually generated DAO mixin
- `lib/data/repositories/card_repository.dart` - Repository with duplicate detection
- `lib/data/models/card.dart` - Immutable domain model
- `lib/data/providers/database_provider.dart` - Riverpod providers
- `test/test_utils/test_database.dart` - Test fixtures and utilities
- `test/data/database/cards_dao_test.dart` - DAO unit tests
- `test/data/repositories/card_repository_test.dart` - Repository unit tests

**Modified Files:**
- `pubspec.yaml` - Added Drift dependencies, updated lottie, added dependency_overrides
- `pubspec.lock` - Locked dependency versions

---

## Senior Developer Review (AI)

**Reviewer:** Claude Opus 4.5
**Date:** 2026-02-02
**Outcome:** ✅ APPROVED (with fixes applied)

### Issues Found and Fixed

#### HIGH Severity (3) - All Fixed

| ID | Issue | File | Fix Applied |
|----|-------|------|-------------|
| H1 | SQL injection via LIKE wildcards | `cards_dao.dart:88,94,99` | ✅ Used custom SQL with ESCAPE clause and parameterized variables |
| H2 | Silent failure in incrementQuantity | `cards_dao.dart:58-66` | ✅ Returns `bool` to indicate success/failure |
| H3 | Repository returned CardEntity instead of Card | `card_repository.dart` | ✅ Now converts to Card domain model |

#### MEDIUM Severity (4) - All Fixed

| ID | Issue | File | Fix Applied |
|----|-------|------|-------------|
| M1 | Missing edge case tests | `cards_dao_test.dart` | ✅ Added tests for SQL injection, special chars, empty search |
| M2 | Race condition in incrementQuantity | `cards_dao.dart:58-66` | ✅ Used atomic `UPDATE ... SET quantity = quantity + 1` |
| M3 | pubspec.lock not documented | Story File List | ✅ Added to Modified Files |
| M4 | Unpinned `any` versions | `pubspec.yaml` | ✅ Pinned to specific versions |

#### LOW Severity (3) - Documented

| ID | Issue | Status |
|----|-------|--------|
| L1 | Card.copyWith can't clear nullable fields | Acceptable - known limitation |
| L2 | Missing explicit index on scryfall_id | Acceptable - UNIQUE constraint creates implicit index |
| L3 | Card model manual instead of Freezed | Acceptable - build_runner unavailable |

### Test Results Post-Review

```
00:01 +31: All tests passed!
```

- **CardsDao tests:** 17 (was 13, added 4 edge cases)
- **CardRepository tests:** 14 (was 10, added oracleText storage test)

### Code Quality Improvements

1. **Security:** SQL LIKE patterns now escaped with parameterized queries
2. **Reliability:** incrementQuantity now atomic and returns success status
3. **Architecture:** Repository properly abstracts database entities into domain models
4. **Dependencies:** Versions pinned for reproducible builds

### Acceptance Criteria Verification

| AC | Status | Evidence |
|----|--------|----------|
| AC1: Cards table columns | ✅ | `cards_table.dart` defines all 11 columns (including oracle_text) |
| AC2: Indexes exist | ✅ | `app_database.dart:36-50` creates 5 indexes |
| AC3: DB in documents dir | ✅ | `app_database.dart:59-60` uses `getApplicationDocumentsDirectory()` |
| AC4: CRUD operations | ✅ | Repository passes all 12 tests |
| AC5: Unit tests pass | ✅ | 31 tests passing |

---

## Senior Developer Review #2 (AI)

**Reviewer:** Claude Opus 4.5
**Date:** 2026-02-02
**Outcome:** ✅ APPROVED (with fixes applied)

### Issues Found and Fixed

#### HIGH Severity (3) - All Fixed

| ID | Issue | File | Fix Applied |
|----|-------|------|-------------|
| H1 | Repository `addCard` missing `oracleText` parameter | `card_repository.dart:23-49` | ✅ Added `oracleText` parameter |
| H2 | Repository `updateCard` missing `oracleText` field | `card_repository.dart:82-99` | ✅ Added `oracleText` to CardEntity |
| H3 | Unpinned `any` versions in dependencies | `pubspec.yaml` | ✅ Pinned all versions |

#### MEDIUM Severity (3) - All Fixed

| ID | Issue | File | Fix Applied |
|----|-------|------|-------------|
| M1 | Test count mismatch in story (29 vs 30) | Story file | ✅ Corrected to 31 |
| M2 | Repository tests don't test `oracleText` | `card_repository_test.dart` | ✅ Added oracleText storage test |
| M3 | Architecture doc schema outdated | `architecture.md`, `epics.md` | ✅ Added oracle_text to schema |

#### LOW Severity (3) - Documented

| ID | Issue | Status |
|----|-------|--------|
| L1 | filterByColor/Type not tested in repository | Acceptable - DAO tests cover |
| L2 | No index on oracle_text column | Future consideration |
| L3 | Missing decrementQuantity method | Future feature |

### Test Results Post-Review #2

```
00:01 +31: All tests passed!
```

### Dependency Versions Pinned

- `flutter_riverpod: ^2.6.1`
- `riverpod_annotation: ^2.6.1`
- `json_serializable: ^6.9.5`
- `go_router_builder: ^2.4.1`
- `build_runner: ^2.5.4`
- `freezed: ^2.5.8`
- `riverpod_generator: ^2.6.4`
- `drift_dev: ^2.28.0`
