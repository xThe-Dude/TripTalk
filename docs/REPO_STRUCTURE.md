# TripTalk — Repo Tree, Key Files & Build Settings

## Repo Tree

```
TripTalk/
├── TripTalk.xcodeproj/            # Xcode project
├── TripTalk/                      # Main app target
│   ├── TripTalkApp.swift          # App entry point (@main)
│   ├── ContentView.swift          # Root TabView + navigation
│   │
│   ├── Models/
│   │   ├── Strain.swift           # Primary data model (15 fields)
│   │   ├── Enums.swift            # SubstanceType, Potency, Difficulty, EffectTag,
│   │   │                          #   BodyFeel, EmotionalTag, MoodTag, TripSetting
│   │   ├── Review.swift           # Review model
│   │   ├── TripReport.swift       # Trip report model
│   │   └── ServiceCenter.swift    # Harm reduction service model
│   │
│   ├── ViewModels/
│   │   └── AppState.swift         # @Observable singleton: all app state, persistence,
│   │                              #   filtering, search, bookmarks, tips
│   │
│   ├── Data/
│   │   └── MockData.swift         # Static seed data (15 strains, reports, reviews, services)
│   │
│   ├── Views/
│   │   ├── Home/
│   │   │   └── HomeView.swift     # Tab 0: Featured strain, tip of day, quick links
│   │   ├── Explore/
│   │   │   └── ExploreView.swift  # Tab 1: Curated sections, search
│   │   ├── Catalog/
│   │   │   ├── CatalogListView.swift      # Tab 2: Full strain catalog + filters
│   │   │   ├── CatalogFilterSheet.swift   # Filter sheet (potency/difficulty/effects)
│   │   │   ├── StrainDetailView.swift     # Strain detail (hero, stats, reports)
│   │   │   └── SubstanceDetailView.swift  # Substance category detail
│   │   ├── Reviews/
│   │   │   ├── ReviewsFeedView.swift      # Tab 3: All reviews feed
│   │   │   ├── WriteReviewView.swift      # Review submission form
│   │   │   └── WriteTripReportView.swift  # Trip report submission form
│   │   ├── Services/
│   │   │   ├── ServicesListView.swift     # Tab 4: Service directory
│   │   │   ├── ServicesFilterSheet.swift  # Service filter sheet
│   │   │   └── ServiceDetailView.swift   # Service center detail
│   │   ├── Profile/
│   │   │   └── ProfileView.swift  # Tab 5: Bookmarks, history, settings, crisis
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift       # 3-page onboarding flow
│   │   ├── AgeGate/
│   │   │   └── AgeGateView.swift          # 21+ verification with legal consent
│   │   └── Components/
│   │       ├── ThemeColors.swift          # Color palette (ttPrimary, ttAccent, etc.)
│   │       ├── GradientBackground.swift   # Reusable gradient background
│   │       ├── ThemedCard.swift           # .darkGlassCard() modifier
│   │       ├── StrainCard.swift           # Strain list card with thumbnail
│   │       ├── ReviewCard.swift           # Review card
│   │       ├── TripReportCard.swift       # Trip report card
│   │       ├── ServiceCard.swift          # Service center card
│   │       ├── SubstanceCard.swift        # Substance category card
│   │       ├── TagChip.swift              # Effect/mood tag pill
│   │       ├── RatingStars.swift          # Star rating display + interactive
│   │       ├── EmptyStateView.swift       # Empty state with illustration
│   │       └── PotencyDots.swift          # Potency dot indicator
│   │
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/            # App icon
│       ├── StrainHeroes/                  # 15 photorealistic strain images
│       │   ├── golden_teachers.imageset/
│       │   ├── albino_penis_envy.imageset/
│       │   ├── b_plus.imageset/
│       │   ├── liberty_caps.imageset/
│       │   ├── blue_meanie.imageset/
│       │   ├── mazatec.imageset/
│       │   ├── caapi_chacruna.imageset/
│       │   ├── caapi_mimosa.imageset/
│       │   ├── san_pedro.imageset/
│       │   ├── peyote.imageset/
│       │   ├── peruvian_torch.imageset/
│       │   ├── ketamine_iv.imageset/
│       │   ├── ketamine_troche.imageset/
│       │   ├── ketamine_spravato.imageset/
│       │   └── ketamine_im.imageset/
│       ├── Categories/                    # 4 substance category banners
│       ├── Onboarding/                    # 3 onboarding illustrations
│       ├── EmptyStates/                   # 6 empty state watercolors
│       ├── HomeBanners/                   # 8 seasonal banners (unused, available)
│       └── AppStore/                      # 5 App Store screenshot backgrounds
│
├── docs/                          # GitHub Pages (live at xthe-dude.github.io/TripTalk)
│   ├── index.html                 # Landing page
│   ├── privacy.html               # Privacy Policy
│   ├── support.html               # Support page
│   ├── terms.html                 # Terms of Service
│   ├── TAXONOMY.md                # Data taxonomy documentation
│   ├── BROWSE_FILTER_UI.md        # Browse/filter/search documentation
│   └── REPO_STRUCTURE.md          # This file
│
├── audits/
│   └── final/                     # Ship-It Sprint audit reports
│       ├── visual_audit.md
│       ├── motion_audit.md
│       ├── copy_audit.md
│       ├── architecture_audit.md
│       ├── accessibility_audit.md
│       └── ux_fixes_summary.md
│
├── APPSTORE.md                    # App Store listing metadata
├── catalog_export.csv             # Full strain catalog data export
└── .gitignore
```

## Key Files by Layer

### App Entry & Navigation
| File | Role |
|---|---|
| `TripTalkApp.swift` | @main entry, UITabBar appearance config |
| `ContentView.swift` | Root TabView (6 tabs), NavigationStack per tab, age gate + onboarding routing |

### Data Models
| File | Role |
|---|---|
| `Models/Strain.swift` | Primary entity: 15 fields including computed `heroImageName` |
| `Models/Enums.swift` | All enums: SubstanceType, Potency, Difficulty, EffectTag, BodyFeel, EmotionalTag, MoodTag, TripSetting + Color extensions |
| `Models/Review.swift` | Review model (9 fields) |
| `Models/TripReport.swift` | Trip report model (12 fields) |
| `Models/ServiceCenter.swift` | Service center model |

### State Management & Persistence
| File | Role |
|---|---|
| `ViewModels/AppState.swift` | **Central @Observable singleton.** Holds all strains, reviews, reports, services, bookmarks, tips. Computed filtering properties. UserDefaults persistence (Codable encode/decode). @MainActor for Swift 6 safety. |

### Networking / Auth Layer
| File | Role |
|---|---|
| **NONE** | No networking layer exists. App is fully offline with static mock data. No API calls, no auth, no tokens. |

### Caching
| File | Role |
|---|---|
| **UserDefaults only** | AppState persists bookmarks, reviews, trip reports, age verification, and onboarding state to UserDefaults via Codable. No disk cache, no image cache, no CoreData, no SwiftData. |

### Data Seeding
| File | Role |
|---|---|
| `Data/MockData.swift` | Static seed data. 15 strains, ~20 trip reports, ~30 reviews, ~10 service centers. All hardcoded. Intended to be replaced by backend in v2. |

### Main Views (6 tabs)
| Tab | File | Content |
|---|---|---|
| 0 Home | `Views/Home/HomeView.swift` | Featured strain, tip of day, quick links, recent reports |
| 1 Explore | `Views/Explore/ExploreView.swift` | Curated sections, search, horizontal cards |
| 2 Catalog | `Views/Catalog/CatalogListView.swift` | Full catalog, filters, substance grouping |
| 3 Reviews | `Views/Reviews/ReviewsFeedView.swift` | Review feed, sort, effect filter |
| 4 Services | `Views/Services/ServicesListView.swift` | Service directory, search, filters |
| 5 Profile | `Views/Profile/ProfileView.swift` | Bookmarks, history, settings, crisis resources |

### Detail Views
| File | Content |
|---|---|
| `Views/Catalog/StrainDetailView.swift` | Full strain detail: hero image, stats, intensity charts, effects, reports, reviews |
| `Views/Catalog/SubstanceDetailView.swift` | Substance category overview |
| `Views/Services/ServiceDetailView.swift` | Service center detail |

### Design System (Components)
| File | Role |
|---|---|
| `ThemeColors.swift` | Full color palette: ttPrimary, ttSecondary, ttTertiary, ttAccent, ttGlow, ttCardBg, ttVisual, ttBody, ttEmotional, ttSpiritual, + Color.forEffect() |
| `GradientBackground.swift` | Reusable gradient background view |
| `ThemedCard.swift` | `.darkGlassCard()` ViewModifier — frosted glass card styling |
| `EmptyStateView.swift` | Reusable empty state with optional illustration |

---

## Build Settings

| Setting | Value |
|---|---|
| **Deployment Target** | iOS 17.0 |
| **Swift Version** | 5 |
| **Bundle ID** | com.triptalk.app |
| **Product Name** | TripTalk |
| **Marketing Version** | 1.0 |
| **Build Number** | 2 (needs increment for next upload) |
| **Target Devices** | iPhone only (TARGETED_DEVICE_FAMILY = 1) |
| **Development Team** | Michael Oehlrich |

## Dependencies

**ZERO external dependencies.**

| Category | Status |
|---|---|
| Swift Package Manager | No `Package.swift`, no packages |
| CocoaPods | No `Podfile` |
| Carthage | No `Cartfile` |
| Frameworks | SwiftUI (system), Foundation (system) only |
| Third-party SDKs | None |
| Analytics | None |
| Crash reporting | None |
| Networking | None |
| Image loading | None (all images are local assets) |
| Database | None (UserDefaults only) |

The app is 100% self-contained with zero third-party code. All 37 Swift files are first-party.
