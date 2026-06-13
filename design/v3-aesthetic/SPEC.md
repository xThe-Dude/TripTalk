# TripTalk v3 — Aesthetic Alignment Spec (Website → App)

**Goal:** Make the app feel like the same premium editorial "field guide" brand as the
website. This is a **visual reskin at the design-token layer only**.

## HARD CONSTRAINTS (do not violate)
- **NO content changes.** No copy edits, no new/removed text.
- **NO layout changes.** Same elements in the same positions/order on every screen.
- **NO functionality changes.** No new features, no behavior changes, no nav restructure.
- This is **token-layer + component-style only**. If a change would move/add/remove an
  element or alter a flow, DO NOT make it.

## The core move: de-gloss
The website earns "premium" through restraint; the app currently spends it on effects
(teal→navy→purple gradients, 5+ accent colors, heavy glossy glass cards, glow).
Strip the gloss, keep the bones.

## Design tokens (the target system)

### Color (exact targets)
- **Background:** matte charcoal `#0E1419` (cool navy undertone), near-flat. At most a
  *very* subtle radial vignette. **Remove the teal/navy/purple gradient entirely.**
- **Primary text / cream:** `#F2EDE4`
- **Secondary/muted gray text:** `#A9AEB2`
- **Single accent — champagne gold:** `#D9C8A0` (richer variant `#C9B583` for rules/dots).
  Gold is the ONLY "primary action / emphasis" color.
- **Crisis red:** `#E8484C` — reserved STRICTLY for crisis affordances. No decorative red.
- **Demote teal:** allowed only as a subtle *selected-state* tint, never as a glow or
  background gradient. Remove green/blue/purple as accent roles.

### Typography
- **Serif (Fraunces, already wired in `TTType.swift`)** for brand moments: screen titles,
  section headers, entry/variety names. Aim for the high-contrast Canela/Tiempos feel.
- **Sans** for body, labels, metadata, captions.
- Keep the existing `TTTypeStyle` roles; this is about *applying serif to the right roles*,
  not adding new type tokens.

### Surfaces / cards
- Replace heavy glossy `DarkGlassCard` / `DarkGlassCardElevated` treatment with
  **hairline-keyline surfaces**: 1px subtle stroke, near-transparent fill, no heavy glow.
- Editorial **list rows** (catalog, reports) get a thin **gold left accent rule** +
  hairline dividers instead of stacked filled cards.

### Navigation bar (explicit ask from Cole)
- The bottom tab bar must read as a **distinct fixed layer**, separated from scroll content:
  - Slightly **darker surface** under the tabs (~`#090D11`).
  - A **champagne-gold hairline top border** at low opacity marking content/chrome edge.
  - Subtle upward shadow so content reads as scrolling *under* it.
  - Active tab = gold icon+label; inactive = muted cream. Reduce gloss/glow.

### Icons
- Quick-link icons → **monochrome thin-line** (not colorful glowing circles).
- Consistent stroke weight, minimal fills, do not rely on color alone.

## Implementation approach (global-first)
Change the **shared design layer** so every screen inherits the new look at once:
1. `Views/Components/ThemeColors.swift` — color tokens + `GradientBackground` + the
   `DarkGlassCard`/`DarkGlassCardElevated` modifiers.
2. `GradientBackground` → matte charcoal (kill the multi-stop gradient).
3. `DesignSystem/TTType.swift` — ensure serif roles map to the brand moments.
4. Tab bar surface/separator (likely `ContentView.swift` TabView styling).
5. Then spot-fix per-screen ONLY where a screen hardcodes a gloss/color that the tokens
   don't reach (e.g. inline gradients, colorful chips) — without moving anything.

## Verification
- After changes, **the app must still build** (Cole builds in Xcode GUI — xcodebuild is
  broken here; the worker must NOT attempt to build/run).
- Diff should be dominated by token/style files. Per-screen edits must be style-only —
  no moved/added/removed views, no copy changes.
- Compare against `mockups/` (home, catalog, trip_reports) and `reference/` website shots.

## STATUS

### Phase 1 — Global token layer (DONE)
- `GradientBackground.swift`: teal/indigo/blue gradient + glowing orbs → matte charcoal
  `#0E1419` + one subtle warm vignette. (kept `intensity` API)
- `ThemeColors.swift`:
  - `ttGlow` retuned teal → champagne gold (collapses emphasis to one accent).
  - `ttAccent` set to exact `#D9C8A0`; `ttSheetBg` to charcoal.
  - meter/tag colors (`ttVisual`/`ttBody`/`ttEmotional`) muted to gold/teal/sand
    (kills the purple→pink "dashboard" meters).
  - `DarkGlassCard` / `DarkGlassCardElevated` → hairline-keyline surfaces
    (thin stroke, near-transparent fill, removed `.ultraThinMaterial` + glow shadows).
    All modifier names/APIs preserved — every call site unchanged.
- `ContentView.swift`: bottom tab bar now a distinct fixed layer — darker surface
  (`#090D11`) + champagne-gold hairline top border via `UITabBarAppearance`.
- `Views/Home/HomeView.swift` (visual-only): quick-link colorful glow circles →
  monochrome thin-line gold; gradient wordmark → solid cream; spotlight banner
  bottom-stop matched to new charcoal. (`quickLink` signature preserved.)
- Typography needed NO change — `TTType.swift` already serif-led (Fraunces) for
  display/pageHead/section/cardTitle from Phase 1 of the v3 build.

### Phase 2 — Per-screen inline cleanup (TODO, not started)
These screens hardcode `[.teal, .green]` button gradients / teal accents that the global
tokens do NOT reach. Style-only swaps to gold, no layout/content/behavior changes:
- `Views/Auth/SignInView.swift` (sign-in gradient button + teal links)
- `Views/Auth/PasswordResetView.swift`
- `Views/AgeGate/AgeGateView.swift`
- `Views/Launch/LaunchScreenView.swift`
- `Views/Catalog/StrainDetailView.swift`, `SubstanceDetailView.swift`, `CatalogListView.swift`
- `Views/Components/AvatarPickerView.swift`, `CrisisButton.swift`
- `Views/Journal/JournalEntryDetailView.swift`

## Reference assets in this folder
- `mockups/` — approved target look (home with nav separator, catalog, trip reports)
- `reference/` — website screenshots (hero, substance index, fundamentals)
