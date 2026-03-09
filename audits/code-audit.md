# TripTalk Code Audit

**Date:** 2026-03-09  
**Auditor:** Lily (Senior iOS Engineer)  
**Scope:** AppState, app lifecycle, theme system, major views

---

### [HIGH] God Object — AppState owns everything
**File:** `ViewModels/AppState.swift`  
**Issue:** AppState holds all data, all filters, all persistence, all computed properties. Every view depends on it, meaning any mutation triggers observation updates across the entire app. This is a scalability and performance bottleneck.  
**Fix:** Split into focused observable objects: `CatalogState`, `ProfileState`, `ReviewState`, etc. Pass only what each view needs via `.environment()`.

---

### [HIGH] Duplicate user data appended on every launch
**File:** `ViewModels/AppState.swift` (lines in `loadPersistedData`)  
**Issue:** `tripReports` and `reviews` start with `MockData` values, then `loadPersistedData()` unconditionally appends user-saved items. If a user-created item's ID collides or data grows, there's no dedup. More critically, `persistAll()` only saves `userTripReports`/`userReviews` but the combined arrays are what views read — on restart, mock + persisted merge again, potentially re-appending.  
**Fix:** Either persist the full arrays, or keep user data strictly separate and merge with dedup (e.g., `Set`-based ID check).

---

### [HIGH] `persistAll()` called on every single mutation
**File:** `ViewModels/AppState.swift`  
**Issue:** Toggling a bookmark serializes *all* saved IDs, reviews, reports, and jurisdiction to UserDefaults synchronously. This is wasteful and will degrade with data growth.  
**Fix:** Persist only the changed key, or debounce writes (e.g., `DispatchWorkItem` with 0.5s delay).

---

### [MEDIUM] Computed filtered properties re-evaluated on any AppState change
**File:** `ViewModels/AppState.swift`  
**Issue:** `filteredSubstances`, `filteredStrains`, `filteredServices`, `sortedReviews` are computed properties on an `@Observable` class. With Observation, any access to these triggers re-computation whenever *any* tracked property changes — not just filter-related ones.  
**Fix:** Move filter state + computed results into dedicated `@Observable` objects scoped to the views that use them.

---

### [MEDIUM] StrainDetailView is a 336-line monolith
**File:** `Views/Catalog/StrainDetailView.swift`  
**Issue:** Hero section, stats bar, intensity chart, effects, body feel, emotional profile, about, photos, trip reports, and toolbar are all in one `body`. Hard to maintain and hurts SwiftUI diffing performance.  
**Fix:** Extract sections into subviews: `StrainHeroView`, `StrainStatsBar`, `StrainEffectsSection`, `StrainTripReportsSection`, etc.

---

### [MEDIUM] ProfileView has excessive staggered animations
**File:** `Views/Profile/ProfileView.swift`  
**Issue:** 9 separate `.animateIn()` modifiers with delays from 0.1 to 0.85s. Each creates its own `@State` bool + animation. On a profile with data, this fires many independent animations on appear, which is CPU-heavy and visually slow.  
**Fix:** Use a single `@State` trigger with a stagger computed from index, or use `List` with built-in animation. Cap at 3-4 animated sections max.

---

### [MEDIUM] `onChange(of: selectedJurisdiction)` calls `updateJurisdiction` redundantly
**File:** `Views/Profile/ProfileView.swift`  
**Issue:** The `Picker` is bound to `$state.selectedJurisdiction`, so the property is already set when `onChange` fires. Then `updateJurisdiction()` sets it *again* and calls `persistAll()`. The setter is redundant.  
**Fix:** Replace `onChange` with a `didSet` on `selectedJurisdiction` in AppState, or just call `persistAll()` directly in `onChange`.

---

### [MEDIUM] UITabBar.appearance() called inside `.onAppear`
**File:** `ContentView.swift`  
**Issue:** `UITabBar.appearance()` is a global mutation that affects all tab bars. Calling it in `onAppear` means it runs every time the view appears, not just once. It's also a UIKit appearance proxy — mixing this with SwiftUI can cause issues on re-renders.  
**Fix:** Move to `init()` of the `App` struct or use the SwiftUI `.toolbarBackground()` modifier on `TabView` (iOS 16+).

---

### [MEDIUM] `DispatchQueue.main.asyncAfter` for launch screen timing
**File:** `TripTalkApp.swift`  
**Issue:** Using GCD for a 1.8s delay is fragile — not cancellable, not tied to any lifecycle. If the app backgrounds during launch, the animation still fires.  
**Fix:** Use `Task { try? await Task.sleep(for: .seconds(1.8)) }` with proper cancellation, or tie to `@State` with `.task` modifier.

---

### [LOW] `return nil ?? .teal` — nonsensical nil coalescing
**File:** `Views/Catalog/StrainDetailView.swift` (line ~325)  
**Issue:** `return nil ?? .teal` compiles but is confusing. It's just `return .teal`.  
**Fix:** Replace with `return .teal`.

---

### [LOW] Quick Links in HomeView are non-functional
**File:** `Views/Home/HomeView.swift`  
**Issue:** The "Varieties", "Services", "Safety", "Community" quick links are just `VStack` with icons — no `Button` or `NavigationLink`. They're decorative only.  
**Fix:** Wire them to actual navigation (e.g., switch tab or push a view), or remove them to avoid confusing users.

---

### [LOW] `refreshable` does nothing meaningful
**File:** `Views/Home/HomeView.swift`, `Views/Explore/ExploreView.swift`  
**Issue:** Both views have `.refreshable { try? await Task.sleep(for: .seconds(0.5)) }` — a fake delay with no actual data refresh. Users pull-to-refresh and nothing happens.  
**Fix:** Either implement actual refresh logic or remove `.refreshable` entirely.

---

### [LOW] Haptic generators not pre-prepared
**File:** `Views/Components/ThemeColors.swift` (`Haptics` enum)  
**Issue:** Each call creates a new `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator` and immediately fires. Apple recommends calling `.prepare()` ahead of time for responsive feedback.  
**Fix:** Use shared, pre-prepared generator instances (e.g., static lets with lazy init).

---

### [LOW] Potency dots duplicated across 3+ views
**File:** `StrainDetailView.swift`, `ProfileView.swift`, `MiniStrainCard` (ExploreView.swift)  
**Issue:** The `ForEach(1...4)` potency dot pattern with accessibility label is copy-pasted in at least 3 places.  
**Fix:** Extract into a `PotencyDots(potency: Potency)` reusable component.

---

**Summary:** 14 findings — 3 high, 6 medium, 5 low. The biggest concern is AppState acting as a god object; splitting it will improve performance, testability, and maintainability. The duplicate-on-load persistence bug should be fixed before shipping.
