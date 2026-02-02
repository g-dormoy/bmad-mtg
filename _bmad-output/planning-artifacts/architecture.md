---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments: ['prd.md', 'product-brief-mtg-2026-01-28.md']
workflowType: 'architecture'
status: 'complete'
completedAt: '2026-01-31'
project_name: 'mtg'
user_name: 'Guillaume'
date: '2026-01-28'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
28 FRs across 5 capability areas defining a card scanning and collection management app:

| Area | Count | Architectural Implication |
|------|-------|---------------------------|
| Card Scanning | 7 | Camera integration, API client, recognition pipeline |
| Collection Management | 5 | Local database, image storage, duplicate tracking |
| Collection Browsing | 10 | Query optimization, filtering engine, grid/list views |
| Card Details | 4 | Image retrieval, card metadata display |
| Session & Statistics | 2 | State management, aggregation queries |

**Non-Functional Requirements:**

| NFR | Target | Architectural Impact |
|-----|--------|---------------------|
| Scan Speed | < 2 seconds | Efficient camera → API → storage pipeline |
| Browse Speed | < 1 second | Indexed local database, optimized queries |
| Scan Accuracy | 99%+ | Reliable API integration, image quality handling |
| App Startup | < 3 seconds | Lazy loading, minimal initialization |
| Offline Browse | Full capability | Local-first architecture, cached images |
| Stability | No crashes/data loss | Error boundaries, transactional writes |

**Scale & Complexity:**

- Primary domain: Mobile (Flutter cross-platform)
- Complexity level: Low-Medium
- Estimated architectural components: 6-8 major modules
- Data scale: Hundreds to low thousands of cards per user
- User scale: Single user, local data only (MVP)

### Technical Constraints & Dependencies

**Framework Constraint:** Flutter (Dart) - chosen for learning goals and cross-platform
**Platform Targets:** iOS 14+ (primary), Android API 26+ (secondary)
**External Dependency:** Scryfall API for card recognition/data
**Connectivity:** Online required for scanning, offline for everything else
**Storage:** Local device only (no cloud backend for MVP)

### Cross-Cutting Concerns Identified

| Concern | Affects | Strategy Needed |
|---------|---------|-----------------|
| Offline Capability | Browsing, filtering, viewing | Local-first data model |
| Image Management | Scanning, storage, display | Efficient storage + caching |
| Error Handling | API calls, camera, database | Graceful degradation patterns |
| Performance | All features | Lazy loading, pagination, indexing |
| State Management | Scanning flow, filters, navigation | Consistent state architecture |

## Starter Template Evaluation

### Primary Technology Domain

Mobile application (Flutter cross-platform) based on project requirements analysis.

### Starter Options Considered

| Option | Pros | Cons | Fit |
|--------|------|------|-----|
| `flutter create` (minimal) | Simple, full control | No architecture, manual setup | Learning but slow |
| Very Good CLI | Production-ready, CI/CD | Uses Bloc, not Riverpod | Mismatch |
| SimpleBoilerplates/Flutter | Riverpod, Dio, go_router, Freezed | Requires understanding of patterns | Best fit |
| ApparenceKit | Riverpod, tested | Commercial focus | Overkill |

### Selected Starter: SimpleBoilerplates/Flutter

**Rationale for Selection:**
- Uses Riverpod for state management (user preference)
- Includes Dio for HTTP (needed for Scryfall API)
- Clean architecture with feature-first structure
- Built on Very Good CLI best practices
- Good balance of structure and learning opportunity

**Initialization:**

```bash
# Clone the boilerplate
git clone https://github.com/SimpleBoilerplates/Flutter.git mtg-app
cd mtg-app

# Remove git history and start fresh
rm -rf .git
git init

# Install dependencies
flutter pub get
```

### Architectural Decisions Provided by Starter

**Language & Runtime:**
- Dart with null safety
- Flutter latest stable

**State Management:**
- Riverpod 2.x for reactive state management
- Provider-based dependency injection

**HTTP Client:**
- Dio for network requests
- Interceptors for logging and error handling

**Routing:**
- go_router for declarative navigation
- Type-safe route definitions

**Data Models:**
- Freezed for immutable data classes
- JSON serialization built-in

**Project Structure:**
- Feature-first organization
- Clean architecture layers (data, domain, presentation)
- Separation of concerns

**Development Experience:**
- Very Good Analysis lint rules
- Pre-configured testing setup
- Environment flavors (dev, staging, prod)

**Note:** Project initialization using this starter should be the first implementation story.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Local Database: SQLite via Drift
- Image Storage: File System
- Camera Integration: Official camera package
- Card Recognition: OCR + Scryfall API

**Important Decisions (Shape Architecture):**
- Already handled by starter: State management (Riverpod), HTTP client (Dio), Routing (go_router)

**Deferred Decisions (Post-MVP):**
- CI/CD pipeline (can use basic GitHub Actions initially)
- Cloud backup infrastructure
- User authentication (not needed for MVP)

### Data Architecture

| Decision | Choice | Version | Rationale |
|----------|--------|---------|-----------|
| Local Database | Drift (SQLite) | ^2.30.1 | Type-safe SQL, perfect for complex filtering (color/type/mana/set), reactive queries |
| Image Storage | File System | N/A | Industry standard - images in app documents folder, paths in database |
| Data Models | Freezed | From starter | Immutable classes with JSON serialization, works with Drift |

**Database Schema Approach:**
- Cards table: id, scryfall_id, name, type, oracle_text, mana_cost, colors, set_code, image_path, quantity, created_at
- Indexes on: name, colors, type, set_code, mana_cost (for fast filtering)

### Authentication & Security

**MVP:** No authentication required
- Single user, local data only
- No sensitive data beyond card images
- Standard App Store privacy compliance

**Future (v2.0):** Firebase Auth or similar when social features added

### API & Communication Patterns

| Decision | Choice | Rationale |
|----------|--------|-----------|
| HTTP Client | Dio | From starter - interceptors, error handling |
| Card Recognition | Google ML Kit OCR → Scryfall fuzzy search | Free, on-device OCR, reliable Scryfall data |
| Offline Handling | Graceful degradation | Scanning fails with message, browsing works fully |

**Scryfall Integration Flow:**
1. Capture card image with camera
2. Extract card name via ML Kit OCR (on-device, no network)
3. Call Scryfall `/cards/named?fuzzy={extracted_name}`
4. Receive card metadata (name, type, colors, mana_cost, set, official image URL)
5. Store scanned image locally + metadata in Drift database
6. Optionally cache Scryfall's official image for offline viewing

**Error Handling Strategy:**
- OCR fails → Prompt user to retry with better lighting/angle
- Scryfall not found → Show "Card not recognized" with manual search option
- Network error → Clear offline message, retry option

### Frontend Architecture

| Decision | Choice | Source |
|----------|--------|--------|
| State Management | Riverpod | Starter + user preference |
| Routing | go_router | Starter |
| Camera | camera (official) | User decision - full control over scan UX |
| UI Framework | Material 3 | Flutter default, clean look |

**Key Screens:**
- Home: Collection grid with filter bar
- Scan: Camera viewfinder with card frame overlay
- Card Detail: Full card image and metadata
- Filter: Color/type/mana/set selection

### Infrastructure & Deployment

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Primary Platform | iOS App Store | User's definition of "done" |
| Secondary Platform | Android (functional) | For friends, Play Store later |
| CI/CD | GitHub Actions (basic) | Simple workflow for solo dev |
| Monitoring | Crashlytics (optional) | Free crash reporting |

**Deployment Strategy:**
- TestFlight for iOS beta testing
- Local APK builds for Android testing
- App Store submission when MVP complete

### Decision Impact Analysis

**Implementation Sequence:**
1. Project setup (clone starter, configure)
2. Drift database schema and models
3. Camera integration with ML Kit OCR
4. Scryfall API service
5. Card scanning flow (camera → OCR → API → save)
6. Collection browsing with filters
7. Card detail view
8. Polish and App Store submission

**Cross-Component Dependencies:**
- Drift models used by: Scanning, Browsing, Details
- Dio client used by: Scryfall service only
- Riverpod state connects: UI ↔ Database ↔ API
- Camera + ML Kit: Tightly coupled in scan feature

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 5 areas where AI agents could make different choices - all resolved with industry-standard Dart/Flutter patterns.

### Naming Patterns

**File Naming (Dart Standard):**
| Type | Pattern | Example |
|------|---------|---------|
| Dart files | snake_case | `card_repository.dart` |
| Test files | snake_case + _test | `card_repository_test.dart` |
| Asset files | snake_case | `app_logo.png` |

**Code Naming (Dart Standard):**
| Type | Pattern | Example |
|------|---------|---------|
| Classes | PascalCase | `CardRepository`, `ScanProvider` |
| Functions/methods | camelCase | `getCards()`, `scanCard()` |
| Variables | camelCase | `cardList`, `isLoading` |
| Private members | _camelCase | `_localDatabase`, `_apiClient` |
| Constants | lowerCamelCase | `defaultPageSize`, `maxRetries` |
| Enums | PascalCase + camelCase values | `CardColor.blue`, `CardType.creature` |

**Database Naming (Drift/SQLite):**
| Type | Pattern | Example |
|------|---------|---------|
| Tables | snake_case plural | `cards`, `scan_sessions` |
| Columns | snake_case | `card_name`, `mana_cost`, `created_at` |
| Foreign keys | snake_case + _id | `scryfall_id` |
| Indexes | idx_table_column | `idx_cards_name` |

**JSON/API Naming:**
| Type | Pattern | Example |
|------|---------|---------|
| JSON fields | snake_case | `mana_cost`, `set_code` (matches Scryfall) |
| Query params | snake_case | `?fuzzy=lightning+bolt` |

### Structure Patterns

**Feature-First Organization:**
```
lib/
├── core/                    # Shared across features
│   ├── constants/           # App-wide constants
│   ├── errors/              # Error types and handling
│   ├── extensions/          # Dart extensions
│   └── utils/               # Helper functions
├── data/                    # Data layer
│   ├── database/            # Drift database, DAOs
│   ├── repositories/        # Repository implementations
│   └── services/            # API services (Scryfall)
├── features/                # Feature modules
│   ├── scanning/
│   │   ├── models/          # Feature-specific models
│   │   ├── providers/       # Riverpod providers
│   │   ├── screens/         # Screen widgets
│   │   └── widgets/         # Feature widgets
│   ├── collection/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── card_detail/
│       ├── providers/
│       ├── screens/
│       └── widgets/
└── main.dart
```

**Test Organization (Co-located):**
```
test/
├── core/
├── data/
├── features/
│   ├── scanning/
│   ├── collection/
│   └── card_detail/
└── test_utils/              # Shared test helpers
```

### State Management Patterns (Riverpod)

**Provider Naming:**
| Type | Pattern | Example |
|------|---------|---------|
| State providers | featureStateProvider | `collectionStateProvider` |
| Notifier providers | featureNotifierProvider | `filterNotifierProvider` |
| Future providers | featureFutureProvider | `cardDetailFutureProvider` |
| Repository providers | repositoryProvider | `cardRepositoryProvider` |

**Provider Organization:**
- One provider per file for clarity
- Providers live in feature's `providers/` folder
- Shared providers in `core/providers/`

**State Update Pattern:**
```dart
// Always use immutable state updates with Freezed
state = state.copyWith(isLoading: true);
```

### Error Handling Patterns

**Error Flow:**
1. Data layer throws typed exceptions (`ApiException`, `DatabaseException`)
2. Repository catches and converts to domain errors
3. Provider exposes `AsyncValue<T>` (loading/error/data states)
4. UI renders based on `AsyncValue` state

**User-Facing Errors:**
| Error Type | User Message | Log Level |
|------------|--------------|-----------|
| Network offline | "No internet connection. Scanning requires network." | info |
| Card not found | "Card not recognized. Try better lighting or search manually." | warning |
| API error | "Something went wrong. Please try again." | error |
| Database error | "Failed to save. Please try again." | error |

**Logging Pattern:**
- Use `logger` package
- Debug: Development details
- Info: User actions (scan started, card added)
- Warning: Recoverable issues (OCR low confidence)
- Error: Failures requiring attention

### Loading State Patterns

**AsyncValue Pattern (Riverpod Standard):**
```dart
// Provider exposes AsyncValue
ref.watch(collectionProvider).when(
  loading: () => LoadingSpinner(),
  error: (e, st) => ErrorWidget(e),
  data: (cards) => CardGrid(cards),
);
```

**Loading State Naming:**
| State | Convention |
|-------|------------|
| Initial load | `AsyncValue.loading()` |
| Refreshing | `isRefreshing` bool in state |
| Action in progress | `isScanning`, `isSaving` |

### Enforcement Guidelines

**All AI Agents MUST:**
1. Follow Dart file naming (snake_case) - enforced by linter
2. Use Freezed for all state/model classes
3. Expose `AsyncValue` for async operations in providers
4. Place code in correct feature folder based on primary responsibility
5. Write tests in matching `test/` folder structure

**Pattern Enforcement:**
- Very Good Analysis lint rules catch naming violations
- PR review checklist includes pattern compliance
- Architecture document is source of truth for patterns

### Pattern Examples

**Good Examples:**
```dart
// File: lib/features/scanning/providers/scan_provider.dart
final scanNotifierProvider = NotifierProvider<ScanNotifier, ScanState>(
  ScanNotifier.new,
);

// File: lib/data/repositories/card_repository.dart
class CardRepository {
  Future<List<Card>> getCardsByColor(List<CardColor> colors) async {
    // Implementation
  }
}
```

**Anti-Patterns (Avoid):**
```dart
// ❌ Wrong file naming
lib/features/scanning/ScanProvider.dart  // Should be snake_case

// ❌ Wrong variable naming
final CardList = [];  // Should be camelCase: cardList

// ❌ Throwing raw exceptions to UI
throw Exception('Failed');  // Should use typed errors + AsyncValue

// ❌ Mutable state
state.cards.add(newCard);  // Should use copyWith for immutability
```

## Project Structure & Boundaries

### Complete Project Directory Structure

```
mtg/
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
├── .env.example
├── .github/
│   └── workflows/
│       └── ci.yml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── api_constants.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   ├── api_exception.dart
│   │   │   └── database_exception.dart
│   │   ├── extensions/
│   │   │   └── string_extensions.dart
│   │   ├── providers/
│   │   │   └── shared_providers.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       └── image_utils.dart
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── app_database.g.dart
│   │   │   ├── tables/
│   │   │   │   └── cards_table.dart
│   │   │   └── daos/
│   │   │       └── cards_dao.dart
│   │   ├── repositories/
│   │   │   └── card_repository.dart
│   │   └── services/
│   │       ├── scryfall_service.dart
│   │       └── ocr_service.dart
│   ├── features/
│   │   ├── scanning/
│   │   │   ├── models/
│   │   │   │   └── scan_state.dart
│   │   │   ├── providers/
│   │   │   │   └── scan_notifier_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── scan_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_viewfinder.dart
│   │   │       ├── card_frame_overlay.dart
│   │   │       └── scan_result_card.dart
│   │   ├── collection/
│   │   │   ├── models/
│   │   │   │   ├── collection_state.dart
│   │   │   │   └── filter_state.dart
│   │   │   ├── providers/
│   │   │   │   ├── collection_notifier_provider.dart
│   │   │   │   └── filter_notifier_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── collection_screen.dart
│   │   │   └── widgets/
│   │   │       ├── card_grid.dart
│   │   │       ├── card_list_tile.dart
│   │   │       ├── filter_bar.dart
│   │   │       ├── color_filter_chips.dart
│   │   │       ├── type_filter_chips.dart
│   │   │       └── search_field.dart
│   │   └── card_detail/
│   │       ├── providers/
│   │       │   └── card_detail_provider.dart
│   │       ├── screens/
│   │       │   └── card_detail_screen.dart
│   │       └── widgets/
│   │           ├── card_image_viewer.dart
│   │           └── card_metadata.dart
│   └── router/
│       └── app_router.dart
├── test/
│   ├── core/
│   │   └── utils/
│   │       └── image_utils_test.dart
│   ├── data/
│   │   ├── database/
│   │   │   └── cards_dao_test.dart
│   │   ├── repositories/
│   │   │   └── card_repository_test.dart
│   │   └── services/
│   │       ├── scryfall_service_test.dart
│   │       └── ocr_service_test.dart
│   ├── features/
│   │   ├── scanning/
│   │   │   └── providers/
│   │   │       └── scan_notifier_provider_test.dart
│   │   ├── collection/
│   │   │   └── providers/
│   │   │       └── collection_notifier_provider_test.dart
│   │   └── card_detail/
│   │       └── providers/
│   │           └── card_detail_provider_test.dart
│   └── test_utils/
│       ├── mocks.dart
│       └── fixtures.dart
├── integration_test/
│   └── scan_to_browse_test.dart
├── assets/
│   └── images/
│       └── app_icon.png
├── ios/
│   └── (Flutter iOS project files)
└── android/
    └── (Flutter Android project files)
```

### Architectural Boundaries

**API Boundaries:**
| Boundary | Location | Responsibility |
|----------|----------|----------------|
| Scryfall API | `data/services/scryfall_service.dart` | All external card data requests |
| OCR Processing | `data/services/ocr_service.dart` | On-device text extraction |
| Database Access | `data/database/daos/` | All Drift/SQLite operations |

**Component Boundaries:**
| Component | Owns | Communicates With |
|-----------|------|-------------------|
| Scanning Feature | Camera, OCR, card recognition flow | Scryfall Service, Card Repository |
| Collection Feature | Browsing, filtering, search | Card Repository, Database |
| Card Detail Feature | Single card display | Card Repository (read-only) |
| Data Layer | All persistence and external APIs | Features via Repository pattern |

**Data Flow:**
```
Camera → OCR Service → Scryfall Service → Card Repository → Drift Database
                                                    ↓
                              Collection/Detail UI ← Riverpod Providers
```

### Requirements to Structure Mapping

**Card Scanning (FR1-FR7):**
- Camera access: `features/scanning/widgets/camera_viewfinder.dart`
- OCR processing: `data/services/ocr_service.dart`
- Scryfall lookup: `data/services/scryfall_service.dart`
- Card confirmation UI: `features/scanning/widgets/scan_result_card.dart`
- Session tracking: `features/scanning/models/scan_state.dart`

**Collection Management (FR8-FR12):**
- Local persistence: `data/database/` (Drift)
- Duplicate tracking: `data/database/daos/cards_dao.dart`
- Image storage: File system via `core/utils/image_utils.dart`
- Repository pattern: `data/repositories/card_repository.dart`

**Collection Browsing (FR13-FR22):**
- Grid/list views: `features/collection/widgets/card_grid.dart`, `card_list_tile.dart`
- Search: `features/collection/widgets/search_field.dart`
- Filters: `features/collection/widgets/*_filter_chips.dart`
- State management: `features/collection/providers/`

**Card Details (FR23-FR26):**
- Detail screen: `features/card_detail/screens/card_detail_screen.dart`
- Image display: `features/card_detail/widgets/card_image_viewer.dart`
- Metadata display: `features/card_detail/widgets/card_metadata.dart`

### Integration Points

**Internal Communication:**
- Features communicate via Riverpod providers (no direct feature-to-feature imports)
- All data access through `CardRepository` interface
- Shared utilities in `core/` accessible by all features

**External Integrations:**
- Scryfall API: `https://api.scryfall.com/cards/named?fuzzy={name}`
- Google ML Kit: On-device OCR via `google_mlkit_text_recognition` package
- Camera: Native camera via `camera` package

**Offline Behavior:**
- Database and file system work offline (browsing, filtering)
- `scryfall_service.dart` returns clear error when offline (scanning disabled)
- No sync required (local-first, single device)

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
All technology choices work together without conflicts:
- Flutter + Dart form the foundation
- Riverpod 2.x + Freezed integrate seamlessly (both from starter)
- Drift (SQLite) + Freezed models enable type-safe queries
- Dio handles Scryfall REST API calls
- Official camera + ML Kit OCR are both Google packages with no conflicts
- go_router fits the Riverpod reactive state model

**Pattern Consistency:**
- Dart naming conventions applied consistently across all layers
- Feature-first structure aligns with Riverpod provider organization
- AsyncValue pattern used uniformly for all async operations
- Repository pattern provides clean data access abstraction

**Structure Alignment:**
- Directory structure directly supports all chosen patterns
- Clean separation between data layer and feature modules
- Test structure mirrors source structure for easy navigation

### Requirements Coverage Validation ✅

**Functional Requirements Coverage:**

| Category | FRs | Architectural Support |
|----------|-----|----------------------|
| Card Scanning | FR1-7 | Camera + OCR Service + Scryfall Service + Repository |
| Collection Management | FR8-12 | Drift Database + File System + Repository |
| Collection Browsing | FR13-22 | Indexed SQLite queries + Riverpod providers |
| Card Details | FR23-26 | Repository + Detail screen + Image viewer |
| Session & Stats | FR27-28 | Scan state + Database aggregation queries |

**Non-Functional Requirements Coverage:**

| NFR | Target | Architectural Support |
|-----|--------|----------------------|
| Scan Speed | < 2 seconds | On-device ML Kit OCR + single Scryfall API call |
| Browse Speed | < 1 second | Indexed SQLite via Drift + local-only queries |
| Scan Accuracy | 99%+ | ML Kit text recognition + Scryfall fuzzy matching |
| Offline Browse | Full capability | Local-first Drift database + cached images |
| Stability | No crashes/data loss | AsyncValue error handling + transactional Drift writes |

### Implementation Readiness Validation ✅

**Decision Completeness:**
- All critical package versions specified
- Starter template provides foundation setup
- Pattern examples included for all major conventions
- Anti-patterns documented to prevent common mistakes

**Structure Completeness:**
- 60+ specific files defined in project tree
- All features mapped to directories
- Integration points clearly specified
- Test organization mirrors source

**Pattern Completeness:**
- 5 naming pattern tables cover all scenarios
- Error handling flow fully documented
- AsyncValue pattern for loading states
- Good and bad examples provided

### Gap Analysis Results

**No Critical Gaps Found** - All blocking decisions documented.

**Minor Enhancement Opportunities (Post-MVP):**
- CI/CD workflow details deferred to implementation
- Crashlytics setup optional for personal project
- No monitoring/analytics needed initially

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (Low-Medium)
- [x] Technical constraints identified (Flutter, Scryfall API)
- [x] Cross-cutting concerns mapped (offline, images, errors, performance, state)

**✅ Architectural Decisions**
- [x] Critical decisions documented with versions
- [x] Technology stack fully specified
- [x] Integration patterns defined (OCR → API → DB)
- [x] Performance considerations addressed

**✅ Implementation Patterns**
- [x] Naming conventions established (5 tables)
- [x] Structure patterns defined (feature-first)
- [x] Communication patterns specified (Riverpod)
- [x] Process patterns documented (error handling, loading states)

**✅ Project Structure**
- [x] Complete directory structure defined (60+ files)
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High

**Key Strengths:**
- Clear technology stack with specific versions
- Comprehensive patterns prevent AI agent conflicts
- Feature-first organization scales well
- Local-first design ensures offline capability
- Industry-standard Dart/Flutter conventions

**First Implementation Step:**
```bash
git clone https://github.com/SimpleBoilerplates/Flutter.git mtg
cd mtg
rm -rf .git && git init
flutter pub get
```

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented
- Use implementation patterns consistently across all components
- Respect project structure and boundaries
- Refer to this document for all architectural questions
- When uncertain, default to Dart/Flutter industry standards
