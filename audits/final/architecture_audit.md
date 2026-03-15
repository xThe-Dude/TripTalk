# TripTalk Architecture Audit
**Date:** 2026-03-15
**Auditor:** Senior SwiftUI Architect
**Scope:** All 38 Swift source files — models, view models, views, components
**iOS Target:** iOS 17+ / Swift 5.9+ (@Observable, Swift Concurrency)

---

## Priority Legend
- **P0** — Crash risk or data-corrupting bug. Fix immediately.
- **P1** — Correctness bug, dead/broken code, or significant maintainability hazard.
- **P2** — Code quality, style, performance, or minor anti-pattern.

---

## P0 — No P0 Issues Found

No force-unwrap crash paths on variable inputs, no unguarded array index accesses, no threading violations that would corrupt data. All force-unwraps in the codebase are on compile-time constant strings (UUIDs, URLs, calendar arithmetic) that cannot fail.

---

## P1 Issues

---

### P1-01 · Dead code: `filteredSubstances` + `catalogCategoryFilter` never used; `resetCatalogFilters` is incomplete
**File:** `AppState.swift` — lines 34, 47–58, 174–180

`filteredSubstances` is a computed property that is never referenced by any view. `CatalogListView` renders only `filteredStrains`. No view navigates to a substances list. `catalogCategoryFilter` (line 34) is the property `filteredSubstances` reads — it is also never bound to any picker, toggle, or UI element.

`resetCatalogFilters()` (lines 174–180) resets `catalogSubstanceTypeFilter`, `catalogPotencyFilter`, `catalogDifficultyFilter`, `catalogEffectFilter`, and `catalogSearchText` — but never resets `catalogCategoryFilter`. This is an incomplete reset that would silently leave stale filter state if the filter were ever wired up.

**Fix:** Delete `catalogCategoryFilter` (line 34), delete the entire `filteredSubstances` block (lines 47–58), and remove the corresponding `catalogCategoryFilter = nil` line from `resetCatalogFilters`. If a substances list view is planned in the future, re-add then.

---

### P1-02 · Dead code: `ExploreSegment` enum is never used
**File:** `Enums.swift` — lines 78–85

```swift
enum ExploreSegment: String, CaseIterable, Identifiable {
    case all = "All"
    case substances = "Substances"
    case services = "Services"
    case articles = "Articles"
    ...
}
```

`ExploreView` has no segment control and does not reference this enum. It is dead code.

**Fix:** Delete the `ExploreSegment` enum. Re-introduce when the segmented explore feature is implemented.

---

### P1-03 · Dead code: `ThemedCard<Content>` struct is never instantiated
**File:** `ThemedCard.swift` — entire file

`ThemedCard` is a generic `View` wrapper whose entire body is one line: `content().darkGlassCard()`. No view in the codebase constructs a `ThemedCard`. All card components call `.darkGlassCard()` directly.

**Fix:** Delete `ThemedCard.swift`.

---

### P1-04 · Dead code: `SubstanceCard` struct is never instantiated
**File:** `SubstanceCard.swift` — entire file

`SubstanceCard` is a fully-styled component that is not referenced by any view. `ExploreView` uses `MiniStrainCard`, `CatalogListView` uses `StrainCard`, and detail views don't use card wrappers for substances.

**Fix:** Delete `SubstanceCard.swift`, or wire it up if a substances list view is planned.

---

### P1-05 · Dead code: `ShimmerModifier` and `shimmer()` are defined but never called
**File:** `ThemeColors.swift` — lines 158–182

`ShimmerModifier` is a complete `ViewModifier` with `@State private var phase`, a repeating animation, and an `onAppear`. The `shimmer()` view extension method is registered. Neither is referenced anywhere in the codebase.

**Fix:** Delete `ShimmerModifier` (lines 158–176) and the `shimmer()` extension (lines 178–182). Re-introduce when skeleton loaders are needed.

---

### P1-06 · Dead code: `JurisdictionStatus.color` returns `String` strings that are never read
**File:** `Enums.swift` — lines 30–38

```swift
var color: String {
    switch self {
    case .legal: return "green"
    case .decriminalized: return "yellow"
    ...
    }
}
```

This property returns plain `String`s ("green", "yellow") that don't map to any SwiftUI `Color` initializer. `SubstanceDetailView` computes its own `jurisdictionColor(_ status:) -> Color` locally and does not call `.color` at all. The `String`-returning property is dead code.

**Fix:** Either delete the property, or replace it with a proper `Color` return and remove the local duplication in `SubstanceDetailView`:

```swift
var color: Color {
    switch self {
    case .legal:        return .green
    case .decriminalized: return .ttAccent
    case .medicalOnly:  return .blue
    case .illegal:      return .red
    case .underReview:  return .orange
    }
}
```

---

### P1-07 · Dead/broken UI: "See all N reports" button has an empty action
**File:** `StrainDetailView.swift` — lines 123–131

```swift
if reports.count > 3 {
    Button {
        // ← EMPTY — no action
    } label: {
        Text("See all \(reports.count) reports")
```

This button is rendered and tappable but does nothing. Users see it, tap it, and experience a broken interaction. This is a P1 because it produces visible broken behaviour.

**Fix:** Either implement navigation to a full trip-reports list, or hide the button behind a `#if DEBUG` or remove it entirely until the destination view exists.

---

### P1-08 · Duplicate logic: `effectColor(for:)` copy-pasted into two views
**Files:**
- `SubstanceDetailView.swift` — lines 235–247
- `StrainDetailView.swift` — lines 337–348

Both views contain the identical 12-line `private func effectColor(for effectName: String) -> Color` with four keyword arrays and four color returns. Any future change to the mapping must be made in two places.

**Fix:** Extract to `ThemeColors.swift` as a top-level function (or `Color` extension):

```swift
// In ThemeColors.swift
func effectColor(for effectName: String) -> Color {
    let lower = effectName.lowercased()
    if ["visual","color","geometric","pattern","fractal","hallucin","distortion","trails","synesthesia"]
        .contains(where: { lower.contains($0) }) { return .ttVisual }
    if ["body","tingling","warmth","nausea","energy","sedat","relax","heavy","light"]
        .contains(where: { lower.contains($0) }) { return .ttBody }
    if ["euphori","empathy","love","anxiety","fear","joy","bliss","peace","connect"]
        .contains(where: { lower.contains($0) }) { return .ttEmotional }
    if ["spirit","transcend","ego","mystical","cosmic","unity","dissolv"]
        .contains(where: { lower.contains($0) }) { return .ttSpiritual }
    return .ttGlow
}
```

---

### P1-09 · `FlowLayout.layout()` runs twice per render pass — no cache used
**File:** `SubstanceDetailView.swift` — lines 251–290

`FlowLayout` declares `cache: inout ()` (empty tuple — no storage). Both `sizeThatFits` and `placeSubviews` each call the private `layout()` method independently. The wrapping algorithm runs twice per render. SwiftUI's `Layout` protocol provides a typed cache exactly to prevent this.

**Fix:** Provide a typed cache:

```swift
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    struct Cache {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        cache.size = result.size
        cache.positions = result.positions
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for (i, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + cache.positions[i].x,
                                     y: bounds.minY + cache.positions[i].y),
                          proposal: .unspecified)
        }
    }
    // layout() private helper unchanged
}
```

---

### P1-10 · Tight mock-data coupling: `substanceType` computed via hardcoded UUID switch
**File:** `SubstanceDetailView.swift` — lines 9–17

```swift
private var substanceType: SubstanceType? {
    switch substance.id {
    case MockData.psilocybinID: return .psilocybin
    case MockData.ayahuascaID:  return .ayahuasca
    ...
    default: return nil   // ← silent fallthrough
    }
}
```

This silently returns `nil` for any substance not in the hardcoded list. The `Substance` model should carry this information directly.

**Fix:** Add `let substanceType: SubstanceType?` to the `Substance` model and set it in `MockData`. Remove this computed property from the view.

---

### P1-11 · Dead state: `showSuccess` Form section is always hidden behind the overlay
**Files:**
- `WriteReviewView.swift` — lines 14, 77–83, 153–154
- `WriteTripReportView.swift` — lines 21, 174–180, 256–257

Both submit functions do:
```swift
showSuccess = true        // triggers in-form label row
showSuccessOverlay = true // triggers full-screen overlay
```
The full-screen `showSuccessOverlay` overlay immediately covers the form, making the in-form `showSuccess` label section permanently invisible. It is dead UI.

**Fix:** Remove `showSuccess` and its conditional `Section { Label("…submitted!") }` block from both views. Keep only `showSuccessOverlay`.

---

### P1-12 · Wrong URL: "Terms of Service" links to Community Guidelines page
**File:** `ProfileView.swift` — lines 180, 206

"Community Guidelines" (line 180) and "Terms of Service" (line 206) both link to:
```
https://xthe-dude.github.io/TripTalk/support.html
```
"Privacy Policy" (line 193) correctly points to `privacy.html`. Terms of Service needs its own URL.

**Fix:**
```swift
// Line 206 — update to the correct URL:
Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/terms.html")!) {
```

---

### P1-13 · Fragile: `Strain.heroImageName` switches on a display-string property
**File:** `Strain.swift` — lines 20–38

```swift
var heroImageName: String {
    switch name {
    case "Golden Teachers": return "golden_teachers"
    ...
    default: return "golden_teachers"  // ← silent fallback
    }
}
```

Renaming a strain, adding a new one, or a typo in the name silently falls through to `"golden_teachers"` with no compiler warning.

**Fix:** Add `let imageName: String` as a stored property on `Strain` and set it directly in `MockData`. Delete the `heroImageName` computed switch.

---

### P1-14 · `AppState` is missing `@MainActor` — Swift 6 concurrency hazard
**File:** `AppState.swift` — line 3

`AppState` is an `@Observable` class that owns all mutable state consumed by SwiftUI views. Without `@MainActor` isolation:
- Swift 6 strict concurrency mode will emit warnings/errors on all cross-actor accesses
- The `loadPersistedData()` called from `init()` runs synchronously on the calling thread (always main in practice, but not enforced)
- Any `Task {}` that captures `appState` and mutates it runs off the main actor without this annotation

**Fix:**
```swift
@Observable
@MainActor
final class AppState {
    ...
}
```

---

### P1-15 · `UITabBar.appearance()` side effect inside `ContentView.init()`
**File:** `ContentView.swift` — lines 7–13

Configuring global UIKit appearance inside a view `init()` is a side-effectful initializer. SwiftUI may re-initialize views in previews or on state changes, running this block multiple times. The canonical location for UIKit appearance configuration is the app entry point.

**Fix:** Move the entire appearance block to `TripTalkApp.init()`:
```swift
@main
struct TripTalkApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(white: 0, alpha: 0.45)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    ...
}
// Remove ContentView.init() entirely.
```

---

### P1-16 · Redundant double-mutation on `selectedJurisdiction` in two views
**Files:**
- `ServicesFilterSheet.swift` — lines 28, 35–37
- `ProfileView.swift` — lines 165, 171–173

Both views bind a `Picker` directly to `$state.selectedJurisdiction` via `@Bindable` (which already writes the value), then have an `onChange` that calls `appState.updateJurisdiction(appState.selectedJurisdiction)` — which sets the same value again and then saves it.

The property is written twice per change. The only real work in `updateJurisdiction` is `saveJurisdiction()`. This will break if `updateJurisdiction` ever gains non-idempotent side effects.

**Fix:** Remove the `onChange` + `updateJurisdiction` calls. Add persistence via a `didSet`-equivalent in AppState:
```swift
// In AppState.swift — add a dedicated setter method and call it from the Picker's Binding:
Picker("", selection: Binding(
    get: { appState.selectedJurisdiction },
    set: { appState.updateJurisdiction($0) }
)) { ... }
// No onChange needed — updateJurisdiction handles the save.
```

---

## P2 Issues

---

### P2-01 · `AppState` imports `SwiftUI` but uses no SwiftUI types
**File:** `AppState.swift` — line 1

`AppState` only uses `Foundation` types (`UUID`, `UserDefaults`, `JSONEncoder/Decoder`, `Date`). The `import SwiftUI` is unnecessary.

**Fix:** Replace `import SwiftUI` with `import Foundation`.

---

### P2-02 · `AppState` is a monolith — too many responsibilities
**File:** `AppState.swift` — entire file (243 lines)

`AppState` manages: all catalog data, all service data, all review data, all strain/trip-report data, all saved-item bookmarks, jurisdiction selection, tab selection, catalog filter state (6 properties), services filter state (2 properties), review sort state, and all persistence. This is a god object.

Recommended split (non-breaking, no UserDefaults key changes needed):
- `AppState` — tab selection, jurisdiction, navigation
- `CatalogViewModel` — strains, filter state, `filteredStrains`
- `ServicesViewModel` — services, filter state, `filteredServices`
- `ReviewsViewModel` — reviews, sort/filter state, `sortedReviews`
- `ProfileViewModel` — saved IDs, `userReviews`, `userTripReports`, persistence

Each child can be `@Observable` stored as `@State` properties in `TripTalkApp` and injected via separate `@Environment` keys.

---

### P2-03 · Heavy filter/sort chains computed inside `body` in ExploreView and HomeView
**Files:**
- `ExploreView.swift` — lines 49, 66, 83, 113
- `HomeView.swift` — line 168

Sorting and filtering `appState.strains` and `appState.tripReports` inline inside `body` closures means they re-run on every render triggered by any `@Observable` access:

```swift
// ExploreView.swift:49
appState.strains.sorted { $0.reviewCount > $1.reviewCount }.prefix(6)

// HomeView.swift:168
appState.tripReports.sorted { $0.date > $1.date }.prefix(3)
```

**Fix:** Add to `AppState` (or child view models) as named computed properties:
```swift
var popularStrains: [Strain] {
    strains.sorted { $0.reviewCount > $1.reviewCount }.prefix(6).map { $0 }
}
var recentTripReports: [TripReport] {
    tripReports.sorted { $0.date > $1.date }.prefix(3).map { $0 }
}
```

---

### P2-04 · `Dictionary(grouping:)` computed inside `CatalogListView.body`
**File:** `CatalogListView.swift` — lines 50–51

```swift
let grouped = Dictionary(grouping: appState.filteredStrains, by: \.parentSubstance)
let orderedTypes = SubstanceType.allCases.filter { grouped[$0] != nil }
```

These run on every `body` evaluation. With mock data this is invisible, but the pattern is wrong for any dataset that scales.

**Fix:** Move to a computed property on AppState:
```swift
var strainsByType: [(SubstanceType, [Strain])] {
    let grouped = Dictionary(grouping: filteredStrains, by: \.parentSubstance)
    return SubstanceType.allCases.compactMap { type in
        guard let strains = grouped[type], !strains.isEmpty else { return nil }
        return (type, strains)
    }
}
```

---

### P2-05 · `allOfferings` recomputed on every `ServicesFilterSheet.body` evaluation
**File:** `ServicesFilterSheet.swift` — lines 7–9

```swift
private var allOfferings: [String] {
    Array(Set(appState.services.flatMap { $0.offerings })).sorted()
}
```

This flat-maps, deduplicates, and sorts on every `body` render. The offerings list never changes at runtime.

**Fix:** Move to `AppState` as a computed property so the value is memoized between renders by `@Observable` access tracking.

---

### P2-06 · `DispatchQueue.main.asyncAfter` for animation resets — use Swift Concurrency
**Files:**
- `SubstanceDetailView.swift` — lines 200–203
- `StrainDetailView.swift` — lines 177–179
- `ServiceDetailView.swift` — lines 143–145
- `WriteReviewView.swift` — line 156
- `WriteTripReportView.swift` — line 259

All five sites use `DispatchQueue.main.asyncAfter` while the rest of the app uses `Task { try? await Task.sleep(...) }` (e.g. `TripTalkApp.swift:38`). The `asyncAfter` closures cannot be cancelled if the view dismisses before the timer fires (the dismiss call then targets an already-dismissed sheet).

**Fix:**
```swift
// Bookmark animation reset
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(300))
    bookmarkBounce = false
}

// Auto-dismiss after success
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(1500))
    dismiss()
}
```

---

### P2-07 · `GeometryReader` in `StrainDetailView.heroSection` needed only for image width
**File:** `StrainDetailView.swift` — lines 197–239

`heroSection` wraps a full-width hero image in a `GeometryReader` solely to obtain `geo.size.width` for `frame(width: geo.size.width, height: 260)`. Since the image fills the full scroll view width, a simpler frame achieves the same result without the extra layout pass.

**Fix:**
```swift
private var heroSection: some View {
    ZStack(alignment: .bottom) {
        Image(strain.heroImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .clipped()
        // gradient overlay and text stack — unchanged
    }
    .frame(height: 260)
    .clipped()
    .ignoresSafeArea(edges: .top)
    .visualEffect { content, proxy in
        content.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3))
    }
}
```

---

### P2-08 · `GeometryReader` inside `IntensityBar` and `IntensityChartRow` — extra layout pass per card
**Files:**
- `TripReportCard.swift` — lines 113–121 (`IntensityBar`)
- `StrainDetailView.swift` — lines 362–370 (`IntensityChartRow`)

Both use `GeometryReader` to compute a proportional bar width. `IntensityBar` appears inside `TripReportCard`, which is rendered in `LazyVStack` in both `HomeView` and `ExploreView`. The `GeometryReader` causes an extra layout pass for every visible card.

**Fix:** Use a `ZStack(alignment: .leading)` with a `.scaleEffect` on the fill, or use iOS 17's `containerRelativeFrame`:
```swift
// IntensityBar body — remove GeometryReader:
ZStack(alignment: .leading) {
    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
    GeometryReader { geo in
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: geo.size.width * CGFloat(value) / 5.0)
    }
}
.frame(height: 6)
// Above: keep GeometryReader but apply .frame(height: 6) outside it
// to give it a definite size before layout — eliminates the ambiguous height pass
```

---

### P2-09 · `OnboardingView`: unnecessary `GeometryReader` for full-screen background image
**File:** `OnboardingView.swift` — lines 19–25

```swift
GeometryReader { geo in
    Image(page.backgroundImage)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: geo.size.width)
        .clipped()
}
.ignoresSafeArea()
```

The `GeometryReader` is used only to get `geo.size.width`. With `.ignoresSafeArea()` and `contentMode: .fill`, the image already fills the full screen without needing explicit width.

**Fix:**
```swift
Image(page.backgroundImage)
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .clipped()
```

---

### P2-10 · `WriteReviewView`: `body_` variable name hack
**File:** `WriteReviewView.swift` — line 12

```swift
@State private var body_: String = ""
```

`body_` is an unconventional workaround for the `body` naming conflict. SwiftUI has no collision between a stored `@State` property and the `body` computed property.

**Fix:** Rename to a descriptive name:
```swift
@State private var reviewText: String = ""
```

---

### P2-11 · `SubstanceTypePill`: `type` as a parameter name shadows Swift keyword
**File:** `CatalogListView.swift` — line 126

```swift
struct SubstanceTypePill: View {
    let type: SubstanceType?
```

`type` is a Swift keyword. The compiler accepts it as a stored property name but SwiftLint flags it and it surprises readers.

**Fix:** Rename to `substanceType`.

---

### P2-12 · Force-unwrapped `URL(string:)` in ProfileView and AgeGateView
**Files:**
- `ProfileView.swift` — lines 180, 193, 206, 225, 244
- `AgeGateView.swift` — line 85

The strings are compile-time constants so these cannot crash, but force-unwraps on `URL` are flagged by SwiftLint and set a bad precedent.

**Fix:** Centralise into a `Links` namespace:
```swift
enum Links {
    static let communityGuidelines = URL(string: "https://xthe-dude.github.io/TripTalk/support.html")!
    static let privacyPolicy       = URL(string: "https://xthe-dude.github.io/TripTalk/privacy.html")!
    static let terms               = URL(string: "https://xthe-dude.github.io/TripTalk/terms.html")!
    static let crisis988           = URL(string: "tel:988")!
    static let fireside            = URL(string: "tel:6232737654")!
}
```

---

### P2-13 · Force-unwraps on `UUID(uuidString:)` and `Calendar.date(byAdding:)` in MockData
**File:** `MockData.swift` — lines 5–31, 57, 156

All are safe (hardcoded valid UUID strings; `Calendar.date(byAdding: .day, ...)` never returns nil for day arithmetic), but they pattern-match the risk surface of real force unwraps and are flagged by any linter.

**Fix:**
```swift
// UUIDs — add a helper:
private static func uuid(_ s: String) -> UUID { UUID(uuidString: s)! }

// Calendar:
func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now) ?? now }
```

---

### P2-14 · Duplicate harm-reduction tip in `HomeView.tips`
**File:** `HomeView.swift` — lines 13 and 23

Two entries have nearly identical opening sentences:
- Line 13: `"Integration is as important as the experience itself. Take time to reflect."`
- Line 23: `"Integration is as important as the experience itself. Give yourself time to process."`

With 14 tips and a day-of-year rotation, users encounter both within two weeks.

**Fix:** Replace one with a distinct tip on a different topic (e.g. on the value of a trip sitter, or on substance interactions).

---

### P2-15 · `ProfileView`: age-verification reset writes to `UserDefaults` directly, bypassing `@AppStorage`
**File:** `ProfileView.swift` — lines 280–291

```swift
Button(role: .destructive) {
    UserDefaults.standard.set(false, forKey: "ageVerified")
}
```

The key `"ageVerified"` is also backed by `@AppStorage("ageVerified")` in `TripTalkApp`. Both target the same store so the reset works, but there are two write sites for the same key. There is also no confirmation dialog before executing the irreversible action.

**Fix:** Inject the `@AppStorage` binding or use a `updateAgeVerified(false)` method. Add a `.confirmationDialog` before the reset.

---

### P2-16 · `TripTalkApp`: `showOnboarding: Bool?` tri-state creates a momentary blank screen
**File:** `TripTalkApp.swift` — lines 9, 17–26, 36

`showOnboarding` is `nil` on first launch and for the first frame of `onAppear`, so the `ZStack` contains no active branch — just `LaunchScreenView` at `zIndex(1)`. This is invisible in practice but fragile: if launch timing ever shortens, users could see a black screen briefly.

**Fix:** Use an explicit enum state:
```swift
enum FlowState { case launching, onboarding, ageGate, main }
@State private var flowState: FlowState = .launching

// In body: switch on flowState directly instead of Bool?
```

---

## Summary Table

| ID | Priority | File | Lines | Issue |
|----|----------|------|-------|-------|
| P1-01 | P1 | AppState.swift | 34, 47–58, 174–180 | `filteredSubstances` + `catalogCategoryFilter` dead; reset incomplete |
| P1-02 | P1 | Enums.swift | 78–85 | `ExploreSegment` enum unused |
| P1-03 | P1 | ThemedCard.swift | all | `ThemedCard<Content>` never instantiated |
| P1-04 | P1 | SubstanceCard.swift | all | `SubstanceCard` never instantiated |
| P1-05 | P1 | ThemeColors.swift | 158–182 | `ShimmerModifier` / `shimmer()` unused |
| P1-06 | P1 | Enums.swift | 30–38 | `JurisdictionStatus.color: String` is dead — returns plain strings, never read |
| P1-07 | P1 | StrainDetailView.swift | 123–131 | "See all N reports" button has empty action `{}` |
| P1-08 | P1 | SubstanceDetailView.swift + StrainDetailView.swift | 235–247, 337–348 | `effectColor(for:)` duplicated |
| P1-09 | P1 | SubstanceDetailView.swift | 251–290 | `FlowLayout.layout()` called twice per pass — no cache |
| P1-10 | P1 | SubstanceDetailView.swift | 9–17 | `substanceType` computed via hardcoded MockData UUID switch |
| P1-11 | P1 | WriteReviewView.swift, WriteTripReportView.swift | 14/77–83, 21/174–180 | `showSuccess` Form section always hidden by overlay — dead UI |
| P1-12 | P1 | ProfileView.swift | 180, 206 | "Terms of Service" URL same as "Community Guidelines" |
| P1-13 | P1 | Strain.swift | 20–38 | `heroImageName` switches on display string — silent fallback |
| P1-14 | P1 | AppState.swift | 3–4 | Missing `@MainActor` — Swift 6 concurrency hazard |
| P1-15 | P1 | ContentView.swift | 7–13 | `UITabBar.appearance()` in `View.init()` |
| P1-16 | P1 | ServicesFilterSheet.swift, ProfileView.swift | 35–37, 171–173 | Redundant double-mutation on `selectedJurisdiction` |
| P2-01 | P2 | AppState.swift | 1 | Unnecessary `import SwiftUI` |
| P2-02 | P2 | AppState.swift | all | God object — too many responsibilities |
| P2-03 | P2 | ExploreView.swift, HomeView.swift | 49/66/83/113, 168 | Sort/filter chains in `body` |
| P2-04 | P2 | CatalogListView.swift | 50–51 | `Dictionary(grouping:)` in `body` |
| P2-05 | P2 | ServicesFilterSheet.swift | 7–9 | `allOfferings` recomputed every render |
| P2-06 | P2 | SubstanceDetail, StrainDetail, ServiceDetail, WriteReview, WriteTripReport | 201, 178, 144, 156, 259 | `DispatchQueue.main.asyncAfter` — use `Task.sleep` |
| P2-07 | P2 | StrainDetailView.swift | 197–239 | `GeometryReader` for hero image width — unnecessary |
| P2-08 | P2 | TripReportCard.swift, StrainDetailView.swift | 113–121, 362–370 | `GeometryReader` in intensity bars inside `LazyVStack` |
| P2-09 | P2 | OnboardingView.swift | 19–25 | `GeometryReader` for full-screen bg image — unnecessary |
| P2-10 | P2 | WriteReviewView.swift | 12 | `body_` variable naming hack |
| P2-11 | P2 | CatalogListView.swift | 126 | `let type` parameter shadows Swift keyword |
| P2-12 | P2 | ProfileView.swift, AgeGateView.swift | 180/193/206/225/244, 85 | Force-unwrapped `URL(string:)!` |
| P2-13 | P2 | MockData.swift | 5–31, 57, 156 | Force-unwraps on UUID/Calendar |
| P2-14 | P2 | HomeView.swift | 13, 23 | Duplicate harm-reduction tip |
| P2-15 | P2 | ProfileView.swift | 280–291 | Direct `UserDefaults.set` bypasses `@AppStorage`; no confirm dialog |
| P2-16 | P2 | TripTalkApp.swift | 9 | `Bool?` tri-state creates momentary blank screen |

---

## What's Done Well

- **`@Observable` throughout** — No `ObservableObject`/`@Published` remnants. The macro is applied correctly and consistently.
- **`@Bindable var state = appState` in body** — The correct iOS 17+ idiom for creating bindings from an observed object is used consistently across all sheets and forms.
- **`@Environment(AppState.self)` injection** — Consistent across all 15+ consuming views.
- **`NavigationStack` + `navigationDestination(for:)`** — Type-safe value-based navigation is used throughout. No deprecated `NavigationLink(destination:)` API.
- **`LazyVStack` in all list contexts** — `ReviewsFeedView`, `CatalogListView`, `ServicesListView`, and `ExploreView` search results all use `LazyVStack`, correctly deferring off-screen view materialisation.
- **Accessibility coverage** — `accessibilityElement(children:)`, `accessibilityLabel`, `accessibilityAddTraits`, and `accessibilityAdjustableAction` (on `InteractiveRatingStars`) are thorough and consistent throughout.
- **`AnimatedAppearance` and `PressEffect` respect `accessibilityReduceMotion`** — Good inclusive design. `LaunchScreenView` also reads this environment value.
- **`Haptics` enum with pre-instantiated generators** — Generators are allocated once as `static let` properties, avoiding latency from repeated allocation at call sites.
- **UserDefaults persistence pattern** — `JSONEncoder/Decoder` for UUID sets and Codable arrays, with graceful silent failure via `try?`. Deduplication logic when merging persisted user reviews with mock data (AppState lines 201–212) correctly prevents duplicates on reload.
- **No real crash surface** — All force-unwraps in production code paths are on compile-time constant strings. There are no guarded array accesses with variable indices.
