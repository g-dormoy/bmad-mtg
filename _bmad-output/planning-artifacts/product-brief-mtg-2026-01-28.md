---
stepsCompleted: [1, 2, 3, 4, 5]
inputDocuments: []
date: 2026-01-28
author: Guillaume
---

# Product Brief: mtg

## Executive Summary

mtg is a mobile application for iOS and Android that enables Magic: The Gathering players to scan their physical cards and maintain a digital collection they can browse anywhere. Built as a passion project by a player for personal use, the app prioritizes scan accuracy and effective browsing as its core value proposition. Future possibilities include AI-powered deck building assistance and social features for playing and trading with friends, but the foundation is simple: scan your cards well, browse them effectively.

---

## Core Vision

### Problem Statement

Physical Magic: The Gathering collectors have no easy way to track and reference their card collections. The manual effort of cataloging cards is prohibitively high, leading most players to simply not track what they own. This creates friction when building decks, identifying synergies, or remembering what cards are available.

### Problem Impact

- Players forget what cards they own, leading to duplicate purchases or missed deck-building opportunities
- Browsing a collection requires physical access to the cards - impossible while commuting, traveling, or away from home
- Finding synergies and building decks is limited to memory or having cards physically spread out
- No easy way to share collection information with friends for trading or collaborative deck building

### Why Existing Solutions Fall Short

This is a passion project - existing solutions haven't been evaluated. The goal isn't to compete with market alternatives but to build something personally useful while learning mobile development. The motivation is intrinsic: create an app that scratches a personal itch and provides a fun development challenge.

### Proposed Solution

A mobile application that:
1. **Scans MTG cards** with high accuracy using the phone camera
2. **Stores the collection** in an internal database
3. **Enables anywhere browsing** - a portable digital twin of the physical collection
4. **Provides effective search and filtering** to make the collection actually useful

Future expansion possibilities (not MVP):
- AI agent to help find card synergies and suggest competitive decks
- Digital play with friends using physical collections
- Trade request system for coordinating exchanges before meeting in person

### Key Differentiators

- **Player-built**: Created by someone who actually plays and understands the use case
- **Scan-first philosophy**: Accuracy is the foundation - everything else depends on reliable card recognition
- **Personal tool mindset**: No pressure to monetize or please a market - built for actual use
- **Learning vehicle**: Opportunity to develop real mobile app skills (creator is a CTO with web background seeking mobile experience)

## Target Users

### Primary Users

**The Returning Player** (represented by Guillaume)

A player who enjoyed Magic: The Gathering in their youth and has returned to the game with adult disposable income. They're rebuilding their collection through booster purchases and pre-built decks, currently modest in size (~40 boosters, 1 commander deck) but growing.

**Profile:**
- Plays multiple formats: Standard currently, moving toward Commander with friends
- Collection is manageable now but will grow over time
- Tech-comfortable (CTO background) but wants the app to "just work"
- Values efficiency - doesn't want card management to become a chore

**Core Needs:**
- Painless, accurate scanning of new cards after opening boosters
- Effective browsing with standard filters (color, type, mana cost) and name search
- Access to collection anywhere, not just at home with physical cards

**Workflow:**
1. Opens booster pack, enjoys looking at the cards first
2. Scans each card individually after the initial review
3. Browses collection later (commute, downtime) to think about decks and synergies

**Success Criteria:**
"I scanned all my boosters without friction and can now browse my collection from anywhere."

### Secondary Users

**Friends / Fellow Players**

Other MTG players in the user's social circle who would use the app independently with their own collections. Same core needs as the primary user - they start fresh with their own scanning and browsing.

Future consideration: Social features would connect these independent collections for trading coordination and deck sharing, but each user maintains their own data.

### User Journey

| Phase | Experience |
|-------|------------|
| **Discovery** | Personal project / word of mouth from friends |
| **Onboarding** | Download app, start scanning first cards immediately |
| **Core Usage** | Scan new acquisitions, browse collection for deck ideas |
| **Success Moment** | Entire collection scanned; finding a forgotten card while browsing on the go |
| **Long-term** | App becomes the source of truth for "what do I own?" |

## Success Metrics

### User Success Metrics

**Scanning Performance:**
| Metric | Target | Why It Matters |
|--------|--------|----------------|
| Scan Accuracy | 99%+ | Wrong card recognition breaks trust and collection integrity |
| Scan Speed | < 2 seconds per card | 14-card booster pack should feel fast, not tedious |
| Recognition Reliability | Works in varied lighting | Real-world usage isn't always ideal conditions |

**Browsing Effectiveness:**
| Metric | Target | Why It Matters |
|--------|--------|----------------|
| Card Lookup | Find any card in < 1 second | Browsing must be instant to feel useful |
| Filter Accuracy | 100% correct results | Wrong filters destroy trust in the collection |
| Filter Coverage | Color, type, mana cost, abilities, set/extension | These are the dimensions MTG players think in |

**Personal Value:**
- "I can browse my collection anywhere without my physical cards"
- "I know exactly what I own"
- "Scanning new cards is painless, not a chore"

### Business Objectives

N/A - This is a passion project. Success is measured by personal utility and learning, not business outcomes.

### Key Performance Indicators

**Project Success KPIs:**

| KPI | Target | Status |
|-----|--------|--------|
| App shipped to App Store | Yes | Defines "good result" |
| ML-based card recognition working | Yes | Defines "legendary result" |
| Personal learning achieved | Yes | Success regardless of app outcome |

**MVP Completion Criteria:**
- [ ] Card scanning functional with 99%+ accuracy
- [ ] Collection browsing with filters: color, type, mana cost, set/extension
- [ ] Data persisted locally (collection survives app restart)

The learning journey itself is the primary win - the working app is a bonus.

## MVP Scope

### Core Features

**1. Card Scanning**
- Camera-based card recognition using phone camera
- 99%+ accuracy target
- < 2 seconds per card scan
- Matches scanned card to MTG database (Scryfall API or similar)
- Requires internet connection for card recognition/matching

**2. Collection Storage**
- Local database storing all scanned cards
- Duplicate handling: tracks quantity (e.g., "4x Lightning Bolt")
- Data persists across app restarts
- Works offline for browsing

**3. Collection Browsing**
- Grid/list view of all cards in collection
- Tap card to view full card image (the scanned card)
- Search by card name
- Filter by:
  - Color (White, Blue, Black, Red, Green, Colorless, Multicolor)
  - Card type (Creature, Instant, Sorcery, Enchantment, Artifact, Land, Planeswalker)
  - Mana cost
  - Set/Extension
- Instant response (< 1 second to find any card)
- Full offline capability

**4. Platform**
- iOS (primary - for personal use)
- Android (secondary - for friends)

### Out of Scope for MVP

| Feature | Rationale | Future Phase |
|---------|-----------|--------------|
| Abilities/keywords filter | Nice-to-have, not essential for core browsing | v1.1 |
| AI deck building assistant | Exciting but complex; build foundation first | v2.0 |
| Social features (digital play) | Requires backend infrastructure, user accounts | v2.0+ |
| Trade coordination with friends | Depends on social features | v2.0+ |
| Price tracking/valuation | External dependency, not core to "what do I own?" | v1.x |
| Deck building/management | Focus on collection first | v1.x |
| Cloud sync/backup | Local-first MVP; sync adds complexity | v1.x |
| Card condition tracking (mint, played, etc.) | Adds scanning complexity | v1.x |

### MVP Success Criteria

The MVP is successful when:

- [ ] Can scan a 14-card booster pack in under 2 minutes with 99%+ accuracy
- [ ] Collection persists and is browsable offline
- [ ] Can find any card in collection in under 1 second
- [ ] App deployed to App Store (iOS)
- [ ] Guillaume actually uses it for his collection

**Go/No-Go for v1.1:**
- Personal satisfaction: "I use this instead of nothing"
- Technical foundation: Scanning pipeline is solid and extensible
- Learning achieved: Gained meaningful mobile development experience

### Future Vision

**Phase 1.x - Enhanced Collection:**
- Abilities/keywords filter
- Deck building (create decks from your collection)
- Card price integration
- Cloud backup/sync
- Export collection (CSV, other apps)

**Phase 2.0 - Social & AI:**
- User accounts and authentication
- AI deck assistant ("suggest a Commander deck with this card")
- Share collection with friends
- Trade request system
- Digital play with physical collections

**Long-term Dream:**
The app becomes the bridge between physical MTG and digital convenience - you own paper cards but get the benefits of digital: instant search, AI-assisted deck building, coordinated play with remote friends, all powered by a collection you built by simply scanning your cards.
