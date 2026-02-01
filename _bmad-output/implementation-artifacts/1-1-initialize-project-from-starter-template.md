# Story 1.1: Initialize Project from Starter Template

Status: ready-for-dev

## Story

As a **developer**,
I want **the project initialized from SimpleBoilerplates/Flutter starter**,
So that **I have a working Flutter project with Riverpod, Dio, go_router, and Freezed pre-configured**.

## Acceptance Criteria

1. **Given** the starter template repository URL
   **When** I clone and initialize the project
   **Then** the project structure matches the architecture document

2. **Given** the cloned project
   **When** I run `flutter pub get`
   **Then** all dependencies install without errors

3. **Given** the project with dependencies
   **When** I run `flutter analyze`
   **Then** analysis passes with no errors (warnings acceptable)

4. **Given** the analyzed project
   **When** I run `flutter test`
   **Then** tests execute (pass or no tests yet is acceptable)

5. **Given** the tested project
   **When** I launch on iOS simulator
   **Then** the app displays the default starter screen

## Tasks / Subtasks

- [ ] Task 1: Clone and initialize project (AC: #1)
  - [ ] Clone SimpleBoilerplates/Flutter to local directory
  - [ ] Remove existing git history
  - [ ] Initialize fresh git repository
  - [ ] Rename project to "mtg" in pubspec.yaml
  - [ ] Update app bundle identifier for iOS/Android

- [ ] Task 2: Verify dependencies (AC: #2)
  - [ ] Run `flutter pub get`
  - [ ] Verify Riverpod is installed
  - [ ] Verify Dio is installed
  - [ ] Verify go_router is installed
  - [ ] Verify Freezed is installed
  - [ ] Verify Very Good Analysis is configured

- [ ] Task 3: Verify code quality (AC: #3)
  - [ ] Run `flutter analyze`
  - [ ] Fix any errors (not warnings)
  - [ ] Ensure lint rules from Very Good Analysis are active

- [ ] Task 4: Verify test setup (AC: #4)
  - [ ] Run `flutter test`
  - [ ] Confirm test runner executes

- [ ] Task 5: Verify app launches (AC: #5)
  - [ ] Run on iOS simulator
  - [ ] Verify app launches without crash
  - [ ] Take screenshot of running app

- [ ] Task 6: Initial commit (housekeeping)
  - [ ] Create initial commit with message: "Initialize project from SimpleBoilerplates/Flutter starter"

## Dev Notes

### Architecture Compliance

**Starter Template:** SimpleBoilerplates/Flutter
- Repository: https://github.com/SimpleBoilerplates/Flutter.git
- Provides out-of-box: Riverpod 2.x, Dio, go_router, Freezed, Very Good Analysis

**Expected Project Structure After Init:**
```
mtg/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── data/
│   ├── features/
│   └── router/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── (iOS/Android platform folders)
```

### Initialization Commands

```bash
# Clone the boilerplate
git clone https://github.com/SimpleBoilerplates/Flutter.git mtg
cd mtg

# Remove git history and start fresh
rm -rf .git
git init

# Update pubspec.yaml name to: mtg
# Update iOS bundle identifier: com.example.mtg → appropriate ID
# Update Android package name in build.gradle

# Install dependencies
flutter pub get

# Verify setup
flutter analyze
flutter test
flutter run
```

### Key Dependencies to Verify

| Package | Purpose | Expected |
|---------|---------|----------|
| flutter_riverpod | State management | ^2.x |
| dio | HTTP client | ^5.x |
| go_router | Navigation | ^12.x+ |
| freezed | Code generation | ^2.x |
| freezed_annotation | Annotations | ^2.x |
| build_runner | Code gen runner | dev dependency |

### Platform Configuration

**iOS:**
- Minimum deployment target: iOS 14.0
- Bundle identifier format: com.yourname.mtg

**Android:**
- minSdkVersion: 26 (API 26 = Android 8.0)
- Package name format: com.yourname.mtg

### Project Structure Notes

- The starter provides feature-first organization which aligns with architecture
- Existing structure should NOT be modified in this story
- Focus is purely on initialization and verification

### Testing Notes

- This story has no unit tests to write
- Verification is done through CLI commands and manual app launch
- Success = app runs on simulator without errors

### References

- [Source: architecture.md#Starter Template Evaluation]
- [Source: architecture.md#Selected Starter: SimpleBoilerplates/Flutter]
- [Source: architecture.md#Initialization]
- [Source: epics.md#Story 1.1]

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Debug Log References

(To be filled during implementation)

### Completion Notes List

(To be filled during implementation)

### File List

(To be filled during implementation - list all files created/modified)
