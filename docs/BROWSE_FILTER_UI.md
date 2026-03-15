# TripTalk — Browse, Filter & Search Behaviors

## Catalog Tab (CatalogListView)

**Primary strain browsing experience.**

- **Search bar**: Free-text input at top. Filters `Strain.name` via `localizedCaseInsensitiveContains`. Real-time (keystroke-by-keystroke), no submit button.
- **Substance type pills**: Horizontal scroll row below search. 5 pills: All, Psilocybin, Ayahuasca, Mescaline, Ketamine. Single-select toggle — tap active pill to deselect back to "All".
- **Results layout**: Grouped by SubstanceType. Each category gets:
  - AI-generated hero banner image header (80pt tall, rounded corners)
  - Category icon + label overlay
  - Strain cards listed below in LazyVStack
- **Filter sheet** (CatalogFilterSheet, via toolbar button):
  - Potency filter (Mild / Moderate / Strong / Very Strong)
  - Difficulty filter (Beginner / Intermediate / Experienced)
  - Effect filter (15 effect tags)
  - All optional, all combinable with search + substance type
- **Filter logic**: AND across all active filters. A strain must match ALL active criteria.
- **Empty state**: Custom watercolor illustration + "No Results — Try adjusting your filters or search terms"

## Explore Tab (ExploreView)

**Curated discovery experience.**

- **Search bar**: Same behavior as Catalog — filters strain names, real-time
- **When not searching**, shows 3 curated horizontal sections:
  - "Lower Intensity" — strains with `difficulty == .beginner`
  - "Highest Rated" — all strains sorted by `averageRating` descending
  - "Most Reviewed" — all strains sorted by `reviewCount` descending
- **Each section**: Horizontal ScrollView of MiniStrainCard thumbnails (compact card with image, name, substance type pill)
- **When searching**: Switches to vertical list of matching StrainCards
- Tapping any card → NavigationLink to StrainDetailView

## Reviews Tab (ReviewsFeedView)

**Community reviews feed.**

- **Sort picker**: Segmented control at top with 3 options:
  - Most Recent (default) — sorted by `date` descending
  - Highest Rated — sorted by `rating` descending
  - Lowest Rated — sorted by `rating` ascending
- **Effect filter chips**: Horizontal scroll of effect tag pills below sort picker. Options: All, Spiritual Experience, Introspection, Euphoria, Creativity, Empathy. Single-select toggle.
- **Filter logic**: Sort is always applied. Effect filter is AND with sort — shows only reviews tagged with selected effect, in the chosen sort order.
- **Empty state**: Custom illustration when no reviews match filter

## Services Tab (ServicesListView)

**Harm reduction service directory.**

- **Search bar**: Filters by `ServiceCenter.name` OR `ServiceCenter.city` via `localizedCaseInsensitiveContains`. Real-time.
- **Filter sheet** (ServicesFilterSheet, via toolbar button):
  - Filter by service offering type
- **Results**: Vertical list of ServiceCards in LazyVStack
- **Empty state**: Custom illustration when no services match

## Strain Detail View (StrainDetailView)

**No search/filter — single entity view.** Displays:
- Hero image (260pt, photorealistic AI-generated)
- Stats bar: Potency (dot indicator), Difficulty, Onset, Duration
- Intensity chart: Visual / Body / Emotional bars (0-5 scale)
- Effects tags (colored by domain)
- Body Feel tags
- Emotional Profile tags
- Associated trip reports
- Associated reviews
- About section with description
- Crisis disclaimer footer

## Profile Tab (ProfileView)

**No search.** Shows:
- Bookmarked strains (horizontal scroll)
- User's trip reports
- User's reviews
- Settings, legal links, crisis resources

## Search Behavior Summary

| Tab | Searches | Fields | Method | Debounce |
|---|---|---|---|---|
| Catalog | Strains | name | localizedCaseInsensitiveContains | None (real-time) |
| Explore | Strains | name | localizedCaseInsensitiveContains | None (real-time) |
| Services | Services | name, city | localizedCaseInsensitiveContains | None (real-time) |
| Reviews | — | No search | Sort + filter only | — |
| Home | — | No search | — | — |
| Profile | — | No search | — | — |

## Filter Combination Rules

All filters use AND logic:
- Catalog: search text AND substance type AND potency AND difficulty AND effect
- Services: search text AND offering type
- Reviews: sort order AND effect tag
- Clearing any filter immediately updates results (reactive via @Observable)
