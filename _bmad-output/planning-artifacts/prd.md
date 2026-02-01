---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
inputDocuments: ['product-brief-mtg-2026-01-28.md']
workflowType: 'prd'
documentCounts:
  brief: 1
  research: 0
  projectDocs: 0
classification:
  projectType: Mobile App (cross-platform, Flutter)
  domain: General / Consumer Utility
  complexity: Medium
  projectContext: Greenfield
---

# Product Requirements Document - mtg

**Author:** Guillaume
**Date:** 2026-01-28

## Executive Summary

**mtg** is a cross-platform mobile application (iOS + Android) that enables Magic: The Gathering players to scan their physical cards and maintain a digital collection they can browse anywhere.

**The Problem:** Physical MTG card collectors have no easy way to track what they own. Manual cataloging is tedious, and browsing a collection requires physical access to the cards.

**The Solution:** Point your phone camera at a card, have it recognized instantly via Scryfall API, and add it to your collection. Browse and search your entire collection offline - on the subway, at work, anywhere.

**Key Characteristics:**
- **Platform:** Flutter (cross-platform) - iOS primary, Android secondary
- **Architecture:** Offline-first with local database
- **Scope:** Personal passion project + mobile development learning opportunity
- **MVP:** Scan cards + browse collection with filters
- **Success:** App live on iOS App Store, Guillaume actually uses it

**Target Performance:** 99% scan accuracy, <2s per card, <1s browse response

---

## Success Criteria

### User Success

**Core Experience:**
- Scanning a card feels instant and accurate - no frustration, no retries
- Browsing the collection is as fast as scrolling through photos
- The app becomes the trusted source of "what do I own?"

**Measurable Targets:**
| Metric | Target | Validation |
|--------|--------|------------|
| Scan Accuracy | 99%+ | Correct card identified on first attempt |
| Scan Speed | < 2 seconds | From camera point to card confirmed |
| Browse Speed | < 1 second | Any filter/search returns results instantly |
| Filter Accuracy | 100% | No false positives/negatives in results |

**Success Moment:** "I scanned my entire booster pack in under 2 minutes and can now browse my collection on the train."

### Business Success

N/A - This is a passion project. Success is measured by:
- Personal utility: "I actually use this app"
- Learning achieved: "I understand mobile development now"
- Completion: "I shipped something to the App Store"

### Technical Success

**Stability & Performance:**
- App runs smoothly without crashes
- Resource-efficient (reasonable battery and memory usage)
- Works reliably in varied lighting conditions for scanning
- Offline browsing works without hiccups

**Platform:**
- Successfully deployed to iOS App Store
- Android build functional (Play Store optional for MVP)

**Integration:**
- Scryfall API integration working for card data
- Local database reliably persists collection

### Measurable Outcomes

| Outcome | Measure | Target |
|---------|---------|--------|
| Learning Goal | General mobile dev understanding | Achieved |
| Shipping Goal | App on iOS App Store | Published |
| Utility Goal | Guillaume uses it for his collection | Regular use |
| Accuracy Goal | Card recognition rate | 99%+ |

## Product Scope

### MVP - Minimum Viable Product

**Core Features (Must Have):**
1. **Card Scanning** - Camera-based recognition via Scryfall API, 99%+ accuracy, <2s per card
2. **Collection Storage** - Local SQLite/Hive database, duplicate tracking (4x Lightning Bolt), offline persistence
3. **Collection Browsing** - Grid/list view, tap for full card image, <1s response time
4. **Search & Filter** - Name search, filter by color/type/mana cost/set

**Platform:** iOS (App Store) + Android (functional build)

**Done when:** App is live on iOS App Store

### Growth Features (Post-MVP)

**v1.x Enhancements:**
- Abilities/keywords filter
- Deck building (create decks from collection)
- Card price integration (TCGPlayer/CardMarket)
- Cloud backup/sync
- Export collection (CSV, other app formats)
- Android Play Store deployment

### Vision (Future)

**v2.0+ Platform:**
- User accounts and authentication
- AI deck assistant ("build me a Commander deck around this card")
- Share collection with friends
- Trade request coordination
- Digital play with physical collections

**Long-term:** Bridge between physical MTG and digital convenience - paper cards with digital superpowers.

## User Journeys

### Journey 1: First Booster Scan

**Persona:** Guillaume - Returning player, just downloaded the app

**Opening Scene:**
Guillaume has just cracked open a fresh Draft Booster. The cards are spread on the table. He opens the app for the first time, curious if this thing actually works.

**The Journey:**
1. Opens app → Camera view appears immediately (no tutorial, no signup)
2. Points phone at first card (a foil rare he's excited about)
3. Card is recognized in under 2 seconds - name and set appear on screen
4. Taps "Add to Collection" → Card saved
5. Repeats for remaining 13 cards
6. After last card: "14 cards added to collection" confirmation

**Climax:** The third card scans instantly despite tricky lighting. "Okay, this actually works."

**Resolution:** All 14 cards scanned in under 2 minutes. Guillaume thinks: "That was painless. I might actually keep using this."

**Requirements Revealed:**
- Camera opens immediately on app launch (or one tap away)
- Fast recognition (< 2 seconds)
- Simple "Add" action after recognition
- Session summary after batch scanning
- Works in varied lighting

---

### Journey 2: Subway Collection Browse

**Persona:** Guillaume - Has ~200 cards scanned over a few weeks

**Opening Scene:**
Guillaume is on the metro heading home. He's thinking about building a new Commander deck around a blue/red theme. His cards are at home, but his phone isn't.

**The Journey:**
1. Opens app → Collection view appears
2. Taps filter → Selects "Blue" and "Red" colors
3. Scrolls through 47 matching cards in grid view
4. Spots a card he forgot he owned - "Oh right, I have this!"
5. Taps card → Full card image appears (the one he scanned)
6. Mentally notes synergies, keeps browsing
7. Switches filter to "Instant" type to see combat tricks

**Climax:** Finds three cards he forgot about that work perfectly together.

**Resolution:** Arrives at his stop with deck ideas forming. The physical cards are at home, but the planning happened on the train.

**Requirements Revealed:**
- Collection view as default/easy access
- Multi-select filters (color + type combinable)
- Grid view for quick scanning
- Tap to see full card detail
- Fast filter response (< 1 second)
- Works fully offline

---

### Journey 3: Adding New Cards to Existing Collection

**Persona:** Guillaume - Regular user, 500+ cards in collection

**Opening Scene:**
Guillaume just bought a Commander precon deck (100 cards) and two boosters at his local game store. He wants to add them before he forgets.

**The Journey:**
1. Opens app → Taps "Scan" to enter camera mode
2. Scans cards one by one from the precon
3. Scans a card he already owns → App shows "Lightning Bolt (You have 3)" → Adds anyway (now has 4)
4. Continues through all cards
5. Some cards from same set scan very fast (already seen similar)
6. Finishes session → "128 cards added. Collection total: 634"

**Climax:** Duplicate detection works smoothly - doesn't block, just informs.

**Resolution:** Entire haul catalogued in 15 minutes while watching TV. Collection stays current with zero friction.

**Requirements Revealed:**
- Duplicate detection with count display
- Non-blocking duplicate handling (inform, don't prevent)
- Session statistics
- Running collection total
- Scanning works well for large batches

---

### Journey Requirements Summary

| Capability | Revealed By Journey |
|------------|---------------------|
| Instant camera access | Journey 1, 3 |
| < 2 second recognition | Journey 1 |
| Simple add action | Journey 1, 3 |
| Batch scanning flow | Journey 1, 3 |
| Offline browsing | Journey 2 |
| Multi-filter support | Journey 2 |
| Grid + detail views | Journey 2 |
| Duplicate detection | Journey 3 |
| Session/collection stats | Journey 1, 3 |
| Works in varied conditions | Journey 1 |

## Mobile App Specific Requirements

### Project-Type Overview

Cross-platform mobile application built with Flutter, targeting iOS (primary) and Android (secondary). The app follows an offline-first architecture with camera-based card scanning as the core input mechanism.

### Technical Architecture Considerations

**Framework:** Flutter (Dart)
- Single codebase for iOS and Android
- Learning opportunity for mobile development
- Strong community and package ecosystem

**Architecture Pattern:** Offline-first
- Local database is source of truth
- Network required only for card recognition API calls
- Full functionality for browsing without connectivity

### Platform Requirements

| Platform | Target | Priority |
|----------|--------|----------|
| iOS | iOS 14+ | Primary - Must ship to App Store |
| Android | Android 8+ (API 26) | Secondary - Functional build |

**Flutter Version:** Latest stable
**Min SDK:** iOS 14, Android API 26 (covers 95%+ of devices)

### Device Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| Camera | Card scanning | Yes - core feature |
| Photo Library | Save/access card images | Yes - store scanned images |
| Internet | Scryfall API for card recognition | Yes - for scanning only |

**Not Required for MVP:**
- Push notifications
- Location
- Microphone
- Contacts
- Background processing

### Offline Mode

| Feature | Offline | Online Required |
|---------|---------|-----------------|
| Browse collection | Yes | No |
| Search/filter cards | Yes | No |
| View card details | Yes | No |
| Scan new cards | No | Yes (API call) |
| Add scanned card to collection | Yes | After recognition |

**Data Sync Strategy:** None for MVP (local-only)
**Future:** Cloud backup/sync in v1.x

### Push Strategy

**MVP:** No push notifications

**Future Consideration (v1.x+):**
- New set release alerts
- Price change notifications (if price tracking added)
- Collection milestone celebrations

### Store Compliance

**iOS App Store:**
- Privacy policy required (camera + network usage)
- App Review Guidelines compliance
- Age rating: 4+ (no objectionable content)
- No in-app purchases for MVP

**Google Play Store:**
- Privacy policy required
- Target API level compliance
- Age rating: Everyone
- No monetization for MVP

**Privacy Policy Needs:**
- Camera usage disclosure
- Local data storage explanation
- Scryfall API data transmission
- No personal data collection beyond card images

### Implementation Considerations

**State Management:** Provider or Riverpod (Flutter standard)
**Local Database:** Hive or SQLite (via sqflite package)
**Camera:** camera package + image processing
**API Client:** http or dio package for Scryfall calls
**Image Storage:** Local file system with database references

**Testing Strategy:**
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for scan → store → browse flow
- Manual testing on physical devices (camera features)

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Problem-Solving MVP
- Solve one problem well: "I can't easily track my MTG collection"
- Minimal features, maximum utility
- Ship when it works, iterate based on personal use

**Resource Model:** Solo developer passion project
- No team dependencies
- Flexible timeline driven by interest and availability
- Success measured by personal utility and learning, not market metrics

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
1. First Booster Scan - Open app, scan cards, add to collection
2. Subway Browse - Filter and search collection offline
3. Add New Cards - Scan additional cards with duplicate handling

**Must-Have Capabilities:**

| Feature | Why It's MVP |
|---------|--------------|
| Camera scanning | Core input - no collection without it |
| Scryfall API recognition | Accuracy requirement (99%) |
| Local database | Persistence - collection must survive restart |
| Browse/grid view | Core output - useless to scan if you can't browse |
| Search by name | Basic retrieval |
| Filter by color/type/mana/set | MTG players think in these dimensions |
| Tap for card detail | Need to see what you scanned |
| Duplicate handling | Real collections have 4x of cards |
| iOS App Store | Definition of "done" |

**Explicitly NOT in MVP:**
- Abilities filter
- Deck building
- Price tracking
- Cloud sync/backup
- Push notifications
- User accounts
- Android Play Store (build works, but not published)

### Post-MVP Features

**Phase 2 - Enhanced Collection (v1.x):**
| Feature | Value Add |
|---------|-----------|
| Abilities/keywords filter | Better deck-building support |
| Deck management | Create decks from collection |
| Price integration | Know what collection is worth |
| Cloud backup | Don't lose collection if phone dies |
| Export (CSV) | Interoperability with other tools |
| Android Play Store | Friends on Android can use it |

**Phase 3 - Social & AI (v2.0+):**
| Feature | Value Add |
|---------|-----------|
| User accounts | Identity for social features |
| AI deck assistant | "Build me a deck around this card" |
| Share collection | Friends can see what you have |
| Trade coordination | Plan trades before meetups |
| Digital play | Play MTG remotely with physical cards |

### Risk Mitigation Strategy

**Technical Risk (Card Recognition Accuracy):**
- Primary approach: Scryfall API image matching
- Risk: May not hit 99% accuracy target
- Mitigation: Evaluate when encountered; may need to explore alternative recognition approaches or adjust accuracy expectations
- Philosophy: "I'll see if it happens" - solve problems as they arise

**Market Risk:** N/A - Not a commercial product

**Resource Risk:**
- Solo passion project with flexible timeline
- No hard deadlines or external commitments
- Risk is low - if interest wanes, project pauses
- No minimum viable team required

## Functional Requirements

### Card Scanning

- FR1: User can access the camera scanner from the main screen with one tap or less
- FR2: User can point the camera at an MTG card and have it recognized automatically
- FR3: User can see the recognized card name and set displayed after successful scan
- FR4: User can confirm and add a recognized card to their collection
- FR5: User can see their current ownership count when scanning a card they already own
- FR6: User can continue scanning additional cards without returning to the main screen
- FR7: User can see a summary of cards added after completing a scanning session

### Collection Management

- FR8: User can have their collection persisted locally between app sessions
- FR9: User can have duplicate cards tracked with quantity (e.g., "4x Lightning Bolt")
- FR10: User can add multiple copies of the same card to their collection
- FR11: User can view the total number of cards in their collection
- FR12: System stores the scanned card image for later viewing

### Collection Browsing

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

### Card Details

- FR23: User can tap a card in the collection to view its full details
- FR24: User can see the scanned card image in the detail view
- FR25: User can see the card's name, type, mana cost, and set in the detail view
- FR26: User can return to the collection view from the detail view

### Session & Statistics

- FR27: User can see how many cards were added in the current scanning session
- FR28: User can see their total collection count on the main screen

## Non-Functional Requirements

### Performance

| Metric | Requirement | Rationale |
|--------|-------------|-----------|
| Scan Recognition | < 2 seconds | User shouldn't wait; scanning 14 cards should feel fast |
| Browse/Filter Response | < 1 second | Instant feedback when searching or filtering |
| App Startup | < 3 seconds | Ready to scan quickly when opening a booster |
| Scan Accuracy | 99%+ | Wrong recognition breaks trust in the collection |

**Stability:**
- App should not crash during normal use
- No data loss on app restart or phone reboot
- Reasonable memory/battery usage (no background drain)

### Integration

**Scryfall API:**
| Aspect | Requirement |
|--------|-------------|
| Dependency | Card recognition requires Scryfall API |
| Offline Handling | Scanning fails gracefully with clear message when offline |
| Error Handling | API errors display user-friendly message, don't crash app |

**Note:** No rate limit concerns for personal use volume. If Scryfall is unavailable, user simply cannot scan new cards until connection is restored.

### Data & Storage

| Aspect | Requirement |
|--------|-------------|
| Persistence | Collection data survives app updates and phone restarts |
| Storage | Local device storage only (no cloud for MVP) |
| Image Storage | Scanned card images stored locally for offline viewing |
