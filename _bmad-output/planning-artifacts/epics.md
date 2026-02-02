---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: ['prd.md', 'architecture.md', 'ux-design-specification.md']
---

# mtg - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for mtg, decomposing the requirements from the PRD, UX Design, and Architecture documents into implementable stories.

## Requirements Inventory

### Functional Requirements

**Card Scanning (FR1-FR7):**
- FR1: User can access the camera scanner from the main screen with one tap or less
- FR2: User can point the camera at an MTG card and have it recognized automatically
- FR3: User can see the recognized card name and set displayed after successful scan
- FR4: User can confirm and add a recognized card to their collection
- FR5: User can see their current ownership count when scanning a card they already own
- FR6: User can continue scanning additional cards without returning to the main screen
- FR7: User can see a summary of cards added after completing a scanning session

**Collection Management (FR8-FR12):**
- FR8: User can have their collection persisted locally between app sessions
- FR9: User can have duplicate cards tracked with quantity (e.g., "4x Lightning Bolt")
- FR10: User can add multiple copies of the same card to their collection
- FR11: User can view the total number of cards in their collection
- FR12: System stores the scanned card image for later viewing

**Collection Browsing (FR13-FR22):**
- FR13: User can view their entire collection in a grid layout
- FR14: User can view their entire collection in a list layout
- FR15: User can search their collection by card name
- FR16: User can filter their collection by card color (White, Blue, Black, Red, Green, Colorless, Multicolor)
- FR17: User can filter their collection by card type (Creature, Instant, Sorcery, Enchantment, Artifact, Land, Planeswalker)
- FR18: User can filter their collection by mana cost
- FR19: User can filter their collection by set/extension
- FR20: User can apply multiple filters simultaneously
- FR21: User can clear all filters to see the full collection
- FR22: User can browse their collection while offline (no internet connection)

**Card Details (FR23-FR26):**
- FR23: User can tap a card in the collection to view its full details
- FR24: User can see the scanned card image in the detail view
- FR25: User can see the card's name, type, mana cost, and set in the detail view
- FR26: User can return to the collection view from the detail view

**Session & Statistics (FR27-FR28):**
- FR27: User can see how many cards were added in the current scanning session
- FR28: User can view their total collection count on the main screen

### NonFunctional Requirements

**Performance:**
- NFR1: Scan recognition must complete in < 2 seconds
- NFR2: Browse/filter response must be < 1 second
- NFR3: App startup must be < 3 seconds
- NFR4: Scan accuracy must be 99%+

**Stability:**
- NFR5: App should not crash during normal use
- NFR6: No data loss on app restart or phone reboot
- NFR7: Reasonable memory/battery usage (no background drain)

**Integration:**
- NFR8: Card recognition requires Scryfall API
- NFR9: Scanning fails gracefully with clear message when offline
- NFR10: API errors display user-friendly message, don't crash app

**Data & Storage:**
- NFR11: Collection data survives app updates and phone restarts
- NFR12: Local device storage only (no cloud for MVP)
- NFR13: Scanned card images stored locally for offline viewing

### Additional Requirements

**From Architecture - Starter Template:**
- Project must be initialized using SimpleBoilerplates/Flutter starter template
- Starter provides: Riverpod, Dio, go_router, Freezed, Very Good Analysis

**From Architecture - Technical Stack:**
- Local Database: Drift (SQLite) ^2.30.1 with indexed queries
- Image Storage: File system (app documents folder, paths in database)
- Camera: Official Flutter camera package
- OCR: Google ML Kit text recognition (on-device)
- Card Data: Scryfall API fuzzy search endpoint

**From Architecture - Implementation Patterns:**
- Feature-first project organization (scanning/, collection/, card_detail/)
- Riverpod AsyncValue pattern for all async operations
- Repository pattern for data access
- Freezed for immutable state/model classes
- Snake_case file naming, PascalCase class naming

**From Architecture - Database Schema:**
- Cards table: id, scryfall_id, name, type, oracle_text, mana_cost, colors, set_code, image_path, quantity, created_at
- Indexes on: name, colors, type, set_code, mana_cost

**From UX Design - Visual & Interaction:**
- Dark theme as default (Material Design 3)
- 2-tab bottom navigation (Scan, Collection)
- App opens to Scan screen (camera-first)
- Haptic feedback on scan recognition (50ms pulse)
- Session counter visible during scanning

**From UX Design - Custom Components:**
- CameraViewfinder: Full-screen camera preview with states (Idle, Scanning, Recognized, Error)
- CardFrameOverlay: Card positioning guide (63:88 MTG ratio, green pulse on recognition)
- ScanResultOverlay: Card name, set code, duplicate badge, tap to add
- CollectionGridCard: Card thumbnail with quantity badge
- CardDetailViewer: Full card view with swipe navigation

**From UX Design - Accessibility:**
- WCAG AA compliance required
- Minimum 48x48dp touch targets
- Screen reader support (VoiceOver/TalkBack)
- Font scaling support up to 200%
- Color not used alone to convey information

**From UX Design - Responsive:**
- 2-column grid (portrait), 3-column (landscape)
- Layouts adapt to device size (compact < 360px, standard 360-414px, expanded > 414px)

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 2 | Camera access with one tap |
| FR2 | Epic 2 | Auto card recognition |
| FR3 | Epic 2 | Display recognized card name/set |
| FR4 | Epic 2 | Confirm and add card |
| FR5 | Epic 2 | Show ownership count for duplicates |
| FR6 | Epic 2 | Continue scanning without navigation |
| FR7 | Epic 2 | Session summary |
| FR8 | Epic 3 | Local persistence |
| FR9 | Epic 3 | Duplicate quantity tracking |
| FR10 | Epic 3 | Add multiple copies |
| FR11 | Epic 3 | Total collection count |
| FR12 | Epic 2 | Store scanned image |
| FR13 | Epic 3 | Grid layout |
| FR14 | Epic 3 | List layout |
| FR15 | Epic 3 | Search by name |
| FR16 | Epic 3 | Filter by color |
| FR17 | Epic 3 | Filter by type |
| FR18 | Epic 3 | Filter by mana cost |
| FR19 | Epic 3 | Filter by set |
| FR20 | Epic 3 | Multiple filters |
| FR21 | Epic 3 | Clear filters |
| FR22 | Epic 3 | Offline browsing |
| FR23 | Epic 4 | Tap to view details |
| FR24 | Epic 4 | View scanned image |
| FR25 | Epic 4 | View card metadata |
| FR26 | Epic 4 | Return to collection |
| FR27 | Epic 2 | Session card count |
| FR28 | Epic 3 | Total count on main screen |

## Epic List

### Epic 1: App Foundation

*Goal: Establish the working app shell with navigation and data infrastructure*

Users can launch the app and see the two-tab navigation structure (Scan / Collection). The foundation enables all future features.

**Scope:**
- Initialize project from SimpleBoilerplates/Flutter starter
- Set up Drift database with cards table and indexes
- Create app shell with 2-tab bottom navigation
- Apply dark theme with MTG mana colors
- Configure go_router navigation

**FRs covered:** None directly (infrastructure enables all FRs)

---

### Epic 2: Card Scanning

*Goal: Users can scan physical MTG cards and add them to their collection*

After this epic, users can open the app, point their camera at a card, see it recognized, and tap to add it. The core "magic moment" of the app is complete.

**Scope:**
- Camera viewfinder with card frame overlay
- ML Kit OCR text extraction
- Scryfall API integration (fuzzy name search)
- Save card with image to local database
- Duplicate detection ("You have 3")
- Session counter during scanning
- Session summary on completion

**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR12, FR27

---

### Epic 3: Collection Browsing

*Goal: Users can browse, search, and filter their collection anywhere (including offline)*

After this epic, users can view their entire collection in grid or list view, search by name, apply multiple filters, and do all of this while offline on the subway.

**Scope:**
- Collection grid view (2-col portrait, 3-col landscape)
- Collection list view alternative
- Search by card name
- Filter by color (W/U/B/R/G/C/Multi)
- Filter by type (Creature, Instant, etc.)
- Filter by mana cost
- Filter by set/extension
- Combined multi-filter support
- Clear all filters
- Offline browsing capability
- Total collection count display

**FRs covered:** FR8, FR9, FR10, FR11, FR13, FR14, FR15, FR16, FR17, FR18, FR19, FR20, FR21, FR22, FR28

---

### Epic 4: Card Details

*Goal: Users can view the full details of any card in their collection*

After this epic, users can tap any card to see its full image and metadata, swipe between cards, and navigate back to the collection.

**Scope:**
- Card detail screen
- Full card image display
- Metadata display (name, type, mana cost, set, quantity)
- Back navigation to collection
- Swipe navigation between cards

**FRs covered:** FR23, FR24, FR25, FR26

---

## Epic 1: App Foundation

*Goal: Establish the working app shell with navigation and data infrastructure*

### Story 1.1: Initialize Project from Starter Template

As a **developer**,
I want **the project initialized from SimpleBoilerplates/Flutter starter**,
So that **I have a working Flutter project with Riverpod, Dio, go_router, and Freezed pre-configured**.

**Acceptance Criteria:**

**Given** the starter template repository URL
**When** I clone and initialize the project
**Then** the project structure matches the architecture document
**And** `flutter pub get` completes without errors
**And** `flutter analyze` passes with no errors
**And** `flutter test` runs (even if no tests exist yet)
**And** the app launches on iOS simulator showing default starter screen

---

### Story 1.2: Set Up Database with Cards Table

As a **developer**,
I want **Drift database configured with the cards table**,
So that **scanned cards can be persisted locally**.

**Acceptance Criteria:**

**Given** the initialized Flutter project
**When** I add Drift and configure the database
**Then** the cards table is created with columns: id, scryfall_id, name, type, mana_cost, colors, set_code, image_path, quantity, created_at
**And** indexes exist on: name, colors, type, set_code, mana_cost
**And** the database file is created in the app documents directory
**And** CRUD operations work via CardRepository
**And** unit tests verify database operations

---

### Story 1.3: Create App Shell with Bottom Navigation

As a **user**,
I want **to see a two-tab navigation bar when I open the app**,
So that **I can switch between Scan and Collection screens**.

**Acceptance Criteria:**

**Given** the app is launched
**When** the home screen loads
**Then** a bottom navigation bar displays with 2 tabs: "Scan" and "Collection"
**And** the Scan tab shows a camera icon
**And** the Collection tab shows a grid icon
**And** tapping each tab navigates to its respective screen (placeholder content is acceptable)
**And** the app opens to the Scan tab by default (camera-first)
**And** go_router handles all navigation

---

### Story 1.4: Apply Dark Theme with MTG Colors

As a **user**,
I want **the app to display in dark theme with MTG-inspired colors**,
So that **the visual design matches the card gaming aesthetic**.

**Acceptance Criteria:**

**Given** the app shell is in place
**When** I view any screen
**Then** the background color is dark (#121212)
**And** surface colors use #1E1E1E for cards and elevated surfaces
**And** primary text is white (#FFFFFF)
**And** the primary accent color is #6750A4
**And** MTG mana colors are defined in the theme (White: #F9FAF4, Blue: #0E68AB, Black: #3D3D3D, Red: #D32029, Green: #00733E, Colorless: #9E9E9E, Gold: #C9A227)
**And** the theme respects Material 3 design tokens

---

## Epic 2: Card Scanning

*Goal: Users can scan physical MTG cards and add them to their collection*

### Story 2.1: Camera Viewfinder with Frame Overlay

As a **user**,
I want **to see a camera viewfinder with a card-shaped frame when I open the Scan tab**,
So that **I know where to position my card for scanning**.

**Acceptance Criteria:**

**Given** I tap the Scan tab
**When** the scan screen loads
**Then** a full-screen camera viewfinder displays
**And** a card frame overlay (63:88 aspect ratio) guides card positioning
**And** the frame is visible but not obtrusive (white outline)
**And** camera permission is requested if not already granted
**And** a helpful message appears if camera permission is denied

---

### Story 2.2: OCR Text Extraction Service

As a **developer**,
I want **an OCR service that extracts text from camera frames**,
So that **card names can be identified for Scryfall lookup**.

**Acceptance Criteria:**

**Given** a camera frame containing a card
**When** the OCR service processes the image
**Then** text is extracted from the card (especially the title area)
**And** the extracted text is returned as a string
**And** processing completes in under 500ms
**And** ML Kit text recognition runs on-device (no network required)
**And** unit tests verify text extraction from sample card images

---

### Story 2.3: Scryfall API Integration

As a **developer**,
I want **a service that looks up cards via Scryfall's fuzzy search API**,
So that **extracted card names can be matched to official card data**.

**Acceptance Criteria:**

**Given** an extracted card name string
**When** I call the Scryfall service
**Then** the API endpoint `https://api.scryfall.com/cards/named?fuzzy={name}` is called
**And** successful response returns: name, type_line, mana_cost, colors, set_code, image_uris
**And** 404 response indicates card not found
**And** network errors are handled gracefully with clear error messages
**And** the service uses Dio with proper error handling
**And** unit tests mock API responses

---

### Story 2.4: Automatic Card Recognition

As a **user**,
I want **my card to be recognized automatically when I point my camera at it**,
So that **I don't have to tap a button to start scanning**.

**Acceptance Criteria:**

**Given** I am on the scan screen with a card in the frame
**When** the card is stable and readable
**Then** OCR extracts the card name automatically
**And** Scryfall lookup happens automatically
**And** recognition completes in under 2 seconds (NFR1)
**And** the frame overlay pulses green when recognition succeeds
**And** haptic feedback (50ms vibration) confirms recognition
**And** if recognition fails, the frame returns to idle state for retry

---

### Story 2.5: Scan Result Overlay

As a **user**,
I want **to see the recognized card name and set displayed after a successful scan**,
So that **I can confirm it's the correct card before adding**.

**Acceptance Criteria:**

**Given** a card has been successfully recognized
**When** recognition completes
**Then** an overlay appears showing the card name and set code
**And** the overlay appears over the camera viewfinder (semi-transparent background)
**And** the card name is clearly readable (Title Medium typography)
**And** the overlay remains until I take action or scan another card

---

### Story 2.6: Add Card to Collection

As a **user**,
I want **to tap to confirm and add a recognized card to my collection**,
So that **the card is saved with its image for later viewing**.

**Acceptance Criteria:**

**Given** a scan result overlay is displayed
**When** I tap anywhere on the overlay
**Then** the card is saved to the local database
**And** the scanned image is saved to the app documents folder
**And** the image path is stored in the database record
**And** a brief "Added!" confirmation animation appears
**And** a success haptic pulse confirms the action
**And** the viewfinder is immediately ready for the next card

---

### Story 2.7: Duplicate Detection Display

As a **user**,
I want **to see my current ownership count when scanning a card I already own**,
So that **I know how many copies I have before adding another**.

**Acceptance Criteria:**

**Given** I scan a card that already exists in my collection
**When** the scan result overlay appears
**Then** a badge shows "You have X" (where X is current quantity)
**And** the badge uses warning color (#FFB74D/gold)
**And** I can still tap to add the card (not blocked)
**And** adding increments the quantity rather than creating a duplicate record

---

### Story 2.8: Session Counter

As a **user**,
I want **to see how many cards I've added during my current scanning session**,
So that **I can track my progress while scanning a batch**.

**Acceptance Criteria:**

**Given** I am on the scan screen
**When** I add cards to my collection
**Then** a counter in the header shows "X cards" added this session
**And** the counter starts at 0 when entering scan mode
**And** the counter increments with each card added
**And** the counter persists while I remain on the scan screen

---

### Story 2.9: Session Summary

As a **user**,
I want **to see a summary of cards added when I finish scanning**,
So that **I know how many cards I catalogued in this session**.

**Acceptance Criteria:**

**Given** I have added cards during a scanning session
**When** I navigate away from the scan screen (tap Collection tab)
**Then** a snackbar displays "X cards added to collection"
**And** the session counter resets for the next session
**And** if no cards were added, no summary is shown

---

## Epic 3: Collection Browsing

*Goal: Users can browse, search, and filter their collection anywhere (including offline)*

### Story 3.1: Collection Grid View

As a **user**,
I want **to view my entire collection in a grid layout**,
So that **I can visually browse my cards quickly**.

**Acceptance Criteria:**

**Given** I tap the Collection tab
**When** the collection screen loads
**Then** my cards display in a grid layout
**And** the grid shows 2 columns in portrait mode
**And** the grid shows 3 columns in landscape mode
**And** each card shows its image thumbnail (63:88 aspect ratio)
**And** a quantity badge ("4x") appears on cards with multiple copies
**And** cards load from the local Drift database
**And** the grid scrolls smoothly with many cards

---

### Story 3.2: Collection List View

As a **user**,
I want **to view my collection in a list layout**,
So that **I can see card names and details at a glance**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I toggle to list view
**Then** cards display as list items with thumbnail, name, and type
**And** quantity is shown for cards with multiple copies
**And** a view toggle button switches between grid and list
**And** the selected view preference persists across sessions

---

### Story 3.3: Collection Count Display

As a **user**,
I want **to see my total collection count on the collection screen**,
So that **I know how many cards I own**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** the screen loads
**Then** the header displays "Collection (X cards)" where X is total unique cards
**And** the count updates when cards are added via scanning
**And** the count reflects current filter results when filters are active

---

### Story 3.4: Search by Card Name

As a **user**,
I want **to search my collection by card name**,
So that **I can quickly find a specific card**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I tap the search icon and type a card name
**Then** the collection filters to show only matching cards
**And** search is case-insensitive
**And** partial matches are included (e.g., "bolt" matches "Lightning Bolt")
**And** results update as I type (debounced 300ms)
**And** search response is under 1 second (NFR2)
**And** a clear button appears to reset the search

---

### Story 3.5: Filter by Color

As a **user**,
I want **to filter my collection by card color**,
So that **I can find cards for a specific color deck**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I tap a color filter chip
**Then** the collection shows only cards containing that color
**And** filter chips are available for: White, Blue, Black, Red, Green, Colorless, Multicolor
**And** chips use MTG mana colors as backgrounds
**And** selected chips show a checkmark
**And** I can select multiple colors (shows cards with ANY selected color)
**And** filter response is under 1 second (NFR2)

---

### Story 3.6: Filter by Card Type

As a **user**,
I want **to filter my collection by card type**,
So that **I can find creatures, instants, or other specific types**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I tap a type filter chip
**Then** the collection shows only cards of that type
**And** filter chips are available for: Creature, Instant, Sorcery, Enchantment, Artifact, Land, Planeswalker
**And** I can select multiple types
**And** filter response is under 1 second (NFR2)

---

### Story 3.7: Filter by Mana Cost

As a **user**,
I want **to filter my collection by mana cost**,
So that **I can find cards at specific points on the mana curve**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I select a mana cost filter
**Then** the collection shows only cards with that converted mana cost
**And** filter options include: 0, 1, 2, 3, 4, 5, 6, 7+
**And** I can select multiple mana costs
**And** filter response is under 1 second (NFR2)

---

### Story 3.8: Filter by Set

As a **user**,
I want **to filter my collection by set/expansion**,
So that **I can see all cards from a specific release**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I select a set filter
**Then** the collection shows only cards from that set
**And** only sets present in my collection appear as options
**And** sets display by code (e.g., "MKM", "LCI")
**And** I can select multiple sets
**And** filter response is under 1 second (NFR2)

---

### Story 3.9: Combined Multi-Filter Support

As a **user**,
I want **to apply multiple filters simultaneously**,
So that **I can narrow down my collection precisely**.

**Acceptance Criteria:**

**Given** I am on the collection screen
**When** I select filters from multiple categories (color + type + mana + set)
**Then** the collection shows cards matching ALL selected criteria
**And** filters are applied with AND logic across categories
**And** the result count updates to show matches
**And** "No cards match your filters" appears if no results
**And** combined filter response is under 1 second (NFR2)

---

### Story 3.10: Clear All Filters

As a **user**,
I want **to clear all filters to see my full collection**,
So that **I can start fresh after filtering**.

**Acceptance Criteria:**

**Given** I have one or more filters active
**When** I tap "Clear filters"
**Then** all filters are removed
**And** the full collection is displayed
**And** the search field is also cleared
**And** the clear button only appears when filters are active

---

### Story 3.11: Offline Browsing

As a **user**,
I want **to browse my collection while offline**,
So that **I can view my cards on the subway without internet**.

**Acceptance Criteria:**

**Given** my device has no internet connection
**When** I open the collection screen
**Then** all my cards display normally from local storage
**And** search and all filters work offline
**And** card images load from locally stored files
**And** no error messages appear for browsing
**And** only scanning is disabled when offline

---

## Epic 4: Card Details

*Goal: Users can view the full details of any card in their collection*

### Story 4.1: Navigate to Card Detail

As a **user**,
I want **to tap a card in my collection to view its full details**,
So that **I can examine the card more closely**.

**Acceptance Criteria:**

**Given** I am viewing my collection (grid or list view)
**When** I tap on a card
**Then** the card detail screen opens
**And** navigation uses go_router with proper route
**And** the transition animation is smooth
**And** the card detail screen displays in full screen

---

### Story 4.2: Card Image Display

As a **user**,
I want **to see the scanned card image in full detail**,
So that **I can read the card text and see the artwork**.

**Acceptance Criteria:**

**Given** I am on the card detail screen
**When** the screen loads
**Then** the scanned card image displays at full width
**And** the image loads from local storage (image_path in database)
**And** the image maintains proper aspect ratio (63:88)
**And** a loading placeholder shows while image loads
**And** an error state shows if image file is missing

---

### Story 4.3: Card Metadata Display

As a **user**,
I want **to see the card's name, type, mana cost, set, and quantity**,
So that **I have all the important information at a glance**.

**Acceptance Criteria:**

**Given** I am on the card detail screen
**When** the screen loads
**Then** the card name displays prominently (Headline Large)
**And** the type line displays (e.g., "Creature — Human Wizard")
**And** the mana cost displays (e.g., "2UU")
**And** the set code displays (e.g., "MKM")
**And** the quantity owned displays (e.g., "You own 4 copies")
**And** metadata is arranged clearly below the card image

---

### Story 4.4: Return to Collection

As a **user**,
I want **to return to my collection from the card detail view**,
So that **I can continue browsing**.

**Acceptance Criteria:**

**Given** I am on the card detail screen
**When** I tap the back button or use the back gesture
**Then** I return to the collection screen
**And** my previous scroll position is preserved
**And** my active filters remain applied
**And** swipe-from-edge gesture works for back navigation

---

### Story 4.5: Swipe Between Cards

As a **user**,
I want **to swipe left/right to navigate between cards in detail view**,
So that **I can browse cards without returning to the grid**.

**Acceptance Criteria:**

**Given** I am on the card detail screen
**When** I swipe left or right
**Then** the next/previous card in my current filtered collection displays
**And** the swipe animation is smooth (PageView)
**And** I can swipe through all cards in the current filter results
**And** reaching the first/last card shows a subtle bounce effect
