# Story 1.3: Create App Shell with Bottom Navigation

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **user**,
I want **to see a two-tab navigation bar when I open the app**,
So that **I can switch between Scan and Collection screens**.

## Acceptance Criteria

1. **Given** the app is launched
   **When** the home screen loads
   **Then** a bottom navigation bar displays with 2 tabs: "Scan" and "Collection"

2. **Given** the bottom navigation bar
   **When** I look at the Scan tab
   **Then** it shows a camera icon

3. **Given** the bottom navigation bar
   **When** I look at the Collection tab
   **Then** it shows a grid/collections icon

4. **Given** the bottom navigation bar
   **When** I tap each tab
   **Then** it navigates to its respective screen (placeholder content is acceptable)

5. **Given** the app is freshly launched
   **When** the home screen loads
   **Then** the app opens to the Scan tab by default (camera-first)

6. **Given** the navigation structure
   **When** I navigate between tabs
   **Then** go_router handles all navigation using StatefulShellRoute

## Tasks / Subtasks

- [x] Task 1: Upgrade go_router for StatefulShellRoute support (AC: #6)
  - [x] Upgrade `go_router` from ^6.0.3 to a version supporting StatefulShellRoute (^10.0.0+)
  - [x] Update `go_router_builder` if using code-gen, or remove if switching to manual route definitions
  - [x] Run `flutter pub get` and resolve any dependency conflicts
  - [x] Verify the app still compiles after the upgrade

- [x] Task 2: Create placeholder screens for Scan and Collection (AC: #4, #5)
  - [x] Create `lib/feature/scanning/screens/scan_screen.dart` with placeholder UI
    - [x] Show centered camera icon and "Scan" text
    - [x] Use Scaffold with body content only (no AppBar - shell provides nav)
  - [x] Create `lib/feature/collection/screens/collection_screen.dart` with placeholder UI
    - [x] Show centered grid icon and "Collection" text
    - [x] Use Scaffold with body content only (no AppBar - shell provides nav)

- [x] Task 3: Create ScaffoldWithBottomNav shell widget (AC: #1, #2, #3)
  - [x] Create `lib/shared/widget/scaffold_with_bottom_nav.dart`
  - [x] Accept `StatefulNavigationShell` from go_router
  - [x] Add NavigationBar (Material 3) with 2 destinations:
    - [x] Scan: camera icon (`Icons.camera_alt_outlined` / `Icons.camera_alt`)
    - [x] Collection: grid icon (`Icons.collections_bookmark_outlined` / `Icons.collections_bookmark`)
  - [x] Wire `onDestinationSelected` to `navigationShell.goBranch()`
  - [x] Handle re-tap on active tab (reset to initial location)

- [x] Task 4: Reconfigure go_router with StatefulShellRoute (AC: #4, #5, #6)
  - [x] Refactor `lib/shared/route/app_router.dart`
  - [x] Replace current flat route structure with StatefulShellRoute.indexedStack
  - [x] Define 2 branches:
    - [x] Branch 0: `/scan` → ScanScreen (initial location)
    - [x] Branch 1: `/collection` → CollectionScreen
  - [x] Set `initialLocation: '/scan'` for camera-first experience
  - [x] Keep any needed root-level routes outside the shell (e.g., auth routes if still used)
  - [x] Remove or repurpose old boilerplate routes (AppStartPage, SignIn, SignUp, HomePage)

- [x] Task 5: Clean up boilerplate code (AC: all)
  - [x] Remove or archive starter template feature code that's no longer needed:
    - [x] `lib/feature/auth/` (not needed for MVP - no authentication)
    - [x] `lib/feature/home/` (replaced by new shell + tabs)
    - [x] `lib/app/widget/app_start_page.dart` (auth gate - not needed)
    - [x] `lib/app/provider/app_start_provider.dart` (auth provider)
    - [x] `lib/app/state/app_start_state.dart` (auth state)
  - [x] Update `lib/app/widget/app.dart` to use the new router without auth gate
  - [x] Keep: `lib/shared/http/`, `lib/shared/util/`, `lib/data/` (database from Story 1.2)

- [x] Task 6: Write widget tests (AC: #1, #2, #3, #4, #5)
  - [x] Create `test/shared/widget/scaffold_with_bottom_nav_test.dart`
    - [x] Test: Bottom navigation bar renders with 2 tabs
    - [x] Test: Scan tab has camera icon
    - [x] Test: Collection tab has grid icon
    - [x] Test: Tapping tabs triggers navigation
  - [x] Create `test/shared/route/app_router_test.dart`
    - [x] Test: Initial location is /scan
    - [x] Test: Routes resolve correctly for /scan and /collection

## Dev Notes

### Critical Architecture Context

**Navigation Structure (from architecture.md + UX spec):**
- 2-tab bottom navigation: Scan and Collection
- App opens to Scan tab by default (camera-first philosophy)
- go_router handles all navigation
- Material 3 NavigationBar component (not BottomNavigationBar which is M2)

**Feature-First Structure (from architecture.md#Structure Patterns):**
```
lib/
├── features/              # NEW - per architecture doc
│   ├── scanning/
│   │   └── screens/
│   │       └── scan_screen.dart
│   ├── collection/
│   │   └── screens/
│   │       └── collection_screen.dart
│   └── card_detail/       # Future - not needed yet
├── shared/
│   ├── route/
│   │   └── app_router.dart  # MODIFY - add StatefulShellRoute
│   └── widget/
│       └── scaffold_with_bottom_nav.dart  # NEW
```

**IMPORTANT - Current vs Architecture Structure Mismatch:**
The starter template uses `lib/feature/` (singular) but the architecture doc specifies `lib/features/` (plural). The current code also uses `lib/shared/` instead of `lib/core/`. **Decision for developer:** Either:
1. Migrate to architecture doc structure (`lib/features/`, `lib/core/`) during this story, OR
2. Continue with existing convention (`lib/feature/`, `lib/shared/`) for consistency with starter

Recommendation: Continue with `lib/feature/` and `lib/shared/` to avoid unnecessary refactoring of existing code. The architecture's `data/` directory already matches.

### go_router Version & Migration

**CRITICAL:** The current `go_router: ^6.0.3` does NOT support `StatefulShellRoute`. This feature was introduced in go_router v7/v8. The developer MUST upgrade go_router.

**Latest versions (as of Feb 2026):**
- `go_router: ^17.1.0` (latest, requires Flutter 3.32+/Dart 3.8+)
- `go_router_builder: ^4.0.1` (latest, if using code gen)

**Upgrade considerations:**
- Check your Flutter SDK version first: `flutter --version`
- If Flutter SDK < 3.32, use an older compatible go_router version (e.g., ^13.x or ^14.x)
- Breaking changes since v6: StatefulShellRoute API, case-sensitive URLs (v15+), GoRouteData redesign (v16+)
- **build_runner limitation (from Story 1.2):** Since build_runner doesn't work with Homebrew Flutter, consider switching from TypedGoRoute to manual GoRoute definitions

**Recommended pattern - StatefulShellRoute.indexedStack:**
```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithBottomNav(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/collection', builder: (_, __) => const CollectionScreen()),
      ],
    ),
  ],
)
```

### UX Design Requirements

**Bottom Navigation Bar (from ux-design-specification.md#Navigation Structure):**
| Tab | Icon | Destination |
|-----|------|-------------|
| Scan | Camera (filled when active) | Camera viewfinder |
| Collection | Grid (filled when active) | Collection browser |

**Active tab style:** Filled icon + label
**Inactive tab style:** Outline icon, no label (per UX spec - but NavigationBar in M3 always shows labels; consider using NavigationBar default behavior)

**Empty states for placeholder screens:**
- Scan: Centered camera icon + "Point your camera at a card to scan" (or simple placeholder for now)
- Collection: Centered illustration + "Your collection is empty" + "Scan your first card" CTA

### Boilerplate Cleanup Strategy

The starter template includes auth features (SignIn, SignUp, token management) and a sample "books" feature. These are NOT needed for the MTG app (no authentication for MVP per PRD).

**Safe to remove:**
- `lib/feature/auth/` - Entire auth feature (no auth in MVP)
- `lib/feature/home/` - Starter's sample home with books list
- `lib/app/widget/app_start_page.dart` - Auth gate widget
- `lib/app/provider/app_start_provider.dart` - Auth startup provider
- `lib/app/state/app_start_state.dart` - Auth startup state
- `lib/shared/route/router_notifier.dart` - Auth-based route redirect

**Keep and reuse:**
- `lib/shared/http/` - Dio client (needed for Scryfall API in Epic 2)
- `lib/shared/util/` - Logger, validators, platform detection
- `lib/shared/widget/loading_widget.dart` - Reusable loading indicator
- `lib/shared/widget/error_page.dart` - Reusable error display
- `lib/shared/constants/` - Theme constants (will be expanded in Story 1.4)
- `lib/data/` - Database from Story 1.2 (keep everything)
- `lib/gen/` - Generated asset/color files
- `lib/start.dart` - App initialization (simplify to remove auth)

**Caution:** When removing auth, also update:
- `lib/start.dart` - Remove any auth-dependent initialization
- `lib/app/widget/app.dart` - Simplify to just use router without auth redirects
- `lib/shared/route/app_router.dart` - Remove auth routes, add shell route

### Previous Story Intelligence

**From Story 1.1:**
- Project initialized from SimpleBoilerplates/Flutter starter
- SDK constraint: `>=3.0.0 <4.0.0` - may need update for go_router upgrade
- Package imports use `package:mtg/`
- Very Good Analysis lint rules active (6.0.0)
- Xcode not installed - iOS simulator unavailable, web builds work
- `flutter_test` is enabled in pubspec

**From Story 1.2:**
- **build_runner does NOT work** with Homebrew Flutter SDK (missing `frontend_server.dart.snapshot`)
- Manually wrote generated files (.g.dart) for Drift
- Card model uses manual immutable class instead of Freezed code-gen
- `dependency_overrides` exist for sqlite3 ^3.1.0 and ffi ^2.1.0
- All 31 database tests passing
- Key dependencies: drift ^2.24.0, flutter_riverpod ^2.6.1, riverpod_annotation ^2.6.1

**From Story 1.2 Code Review:**
- Pinned versions for reproducible builds
- Repository pattern properly abstracts database entities into domain models
- Security: SQL LIKE patterns escaped with parameterized queries

**Git patterns established:**
- Conventional commits: `feat(scope): message`
- Branch naming: `feature/story-X.Y-description`
- PR workflow with code review

### Project Structure Notes

- Current structure uses `lib/feature/` (singular) from starter template
- Architecture doc specifies `lib/features/` (plural) - see Dev Notes above for recommendation
- `lib/data/` already contains Story 1.2's database layer
- `lib/shared/` contains routing, HTTP, utils, widgets
- Test structure mirrors source: `test/` follows `lib/` folder hierarchy

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: architecture.md#Structure Patterns]
- [Source: architecture.md#Complete Project Directory Structure]
- [Source: architecture.md#Implementation Patterns & Consistency Rules]
- [Source: ux-design-specification.md#Navigation Structure]
- [Source: ux-design-specification.md#Component Strategy]
- [Source: ux-design-specification.md#Design Direction]
- [Source: epics.md#Story 1.3]
- [Source: prd.md#Functional Requirements - FR1]
- [go_router StatefulShellRoute docs: https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html]
- [go_router changelog: https://pub.dev/packages/go_router/changelog]

## Change Log

- 2026-02-14: Story 1.3 implemented — app shell with 2-tab bottom navigation (Scan/Collection), go_router upgraded to v14, boilerplate auth/home removed, 7 widget tests added
- 2026-02-14: Code review fixes — debugLogDiagnostics guarded by kDebugMode, removed commented-out code from api_provider, removed unused flutter_secure_storage dependency, added useMaterial3: true, strengthened router test, added re-tap reset test, corrected Dev Agent Record inaccuracy. 39 tests pass.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- go_router upgraded from ^6.0.3 to ^14.8.1 (StatefulShellRoute support)
- go_router_builder removed (build_runner incompatible with Homebrew Flutter SDK)
- Followed Dev Notes recommendation: kept `lib/feature/` (singular) convention from starter template
- Manually updated app_router.g.dart for Riverpod provider (no build_runner)
- Removed auth token dependency from api_provider.dart to keep HTTP client functional for future Scryfall API

### Completion Notes List

- Task 1: Upgraded go_router ^6.0.3 → ^14.8.1, removed go_router_builder. Switched from TypedGoRoute code-gen to manual GoRoute definitions. All dependencies resolved, app compiles cleanly.
- Task 2: Created ScanScreen and CollectionScreen as StatelessWidget placeholders with centered icon + text, Scaffold body-only (no AppBar).
- Task 3: Created ScaffoldWithBottomNav with Material 3 NavigationBar, 2 destinations (camera/collections_bookmark icons with outlined/filled variants), goBranch() navigation, re-tap reset.
- Task 4: Refactored app_router.dart to use StatefulShellRoute.indexedStack with 2 branches (/scan, /collection), initialLocation '/scan'. Manually wrote .g.dart for Riverpod provider.
- Task 5: Deleted lib/feature/auth/, lib/feature/home/, app_start_page, app_start_provider (+.g.dart), app_start_state (+.freezed.dart), router_notifier. Cleaned api_provider.dart (removed token dependency). Cleaned app.dart (removed commented code). Analysis issues reduced from 154 to 81 (74 info-level, 7 warnings in pre-existing boilerplate code).
- Task 6: Created 5 widget tests (scaffold_with_bottom_nav_test.dart) and 2 router tests (app_router_test.dart). All 38 tests pass (31 existing + 7 new), zero regressions.

### File List

**New files:**
- lib/feature/scanning/screens/scan_screen.dart
- lib/feature/collection/screens/collection_screen.dart
- lib/shared/widget/scaffold_with_bottom_nav.dart
- test/shared/widget/scaffold_with_bottom_nav_test.dart
- test/shared/route/app_router_test.dart

**Modified files:**
- pubspec.yaml (go_router ^6.0.3 → ^14.8.1, removed go_router_builder)
- pubspec.lock (updated dependencies)
- lib/shared/route/app_router.dart (rewritten with StatefulShellRoute)
- lib/shared/route/app_router.g.dart (rewritten for Riverpod provider only)
- lib/app/widget/app.dart (removed commented code, removed deprecated appBarTheme)
- lib/shared/http/api_provider.dart (removed auth token dependency)

**Deleted files:**
- lib/feature/auth/ (entire directory — model, provider, repository, state, widget)
- lib/feature/home/ (entire directory — model, provider, repository, state, widget)
- lib/app/widget/app_start_page.dart
- lib/app/provider/app_start_provider.dart
- lib/app/provider/app_start_provider.g.dart
- lib/app/state/app_start_state.dart
- lib/app/state/app_start_state.freezed.dart
- lib/shared/route/router_notifier.dart
