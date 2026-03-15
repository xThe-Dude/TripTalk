# TripTalk UX Fixes Summary
**Date:** 2026-03-15
**Scope:** P0 and P1 fixes from visual_audit.md, motion_audit.md, and copy_audit.md

---

## Visual Fixes

### P0-1 · MiniStrainCard manual DarkGlassCard duplication
**File:** `ExploreView.swift`
Replaced manual `.background` / `.clipShape` / `.overlay` / `.shadow` chain on `MiniStrainCard` with `.darkGlassCard()`. Card styling is now tied to the canonical modifier and will update automatically if `DarkGlassCard` changes.

### P0-2 · Hero height standardization
**Files:** `SubstanceDetailView.swift`, `ServiceDetailView.swift`
- `SubstanceDetailView`: `height: 240` → `height: 260`
- `ServiceDetailView`: `height: 220` → `height: 260`
All three entity-detail heroes now share the canonical 260 pt height from `StrainDetailView`.

### P0-3 · CTA button gradient unification
**Files:** `StrainDetailView.swift`, `SubstanceDetailView.swift`, `ServiceDetailView.swift`, `AgeGateView.swift`
Changed all four `[.teal, .blue.opacity(0.8)]` CTA gradients to `[.teal, .green.opacity(0.8)]`, matching `OnboardingView` — the first screen the user sees.

### P1-1 · ExploreView section header font size
**File:** `ExploreView.swift`
`sectionView()` font changed from `.system(.title2, ...)` → `.system(.title3, ...)` to match all other section headers in the app.

### P1-2 · ProfileView section header color
**File:** `ProfileView.swift`
`profileSection()` header changed from `Color.ttSectionHeader` → `Color.ttPrimary`, matching `StrainDetailView`, `SubstanceDetailView`, `ServiceDetailView`, and `HomeView`.

### P1-3 · ServiceCard and SubstanceCard icon gradients
**Files:** `ServiceCard.swift`, `SubstanceCard.swift`
Icon background gradients changed from `[.teal, .blue.opacity(0.8)]` → `[.teal, .green.opacity(0.8)]` to match the canonical CTA gradient.

### P1-4 · ProfileView avatar gradient
**File:** `ProfileView.swift`
Avatar `person.circle.fill` gradient changed from `[.teal, .blue.opacity(0.8)]` → `[.teal, .green.opacity(0.8)]`.

### P1-5 · TripReportCard "Would repeat" raw `.green`
**File:** `TripReportCard.swift`
`.foregroundStyle(.green)` → `.foregroundStyle(Color.ttBody)` — uses the app's themed green token.

### P1-6 · AgeGateView disclosure text opacity
**File:** `AgeGateView.swift`
Removed `.opacity(0.6)` from the age disclosure text and changed `Color.ttPrimary` → `Color.ttSecondary`, using a proper semantic token rather than a runtime opacity fabrication.

### P1-7 · SubstanceDetailView jurisdictionColor raw system colors
**File:** `SubstanceDetailView.swift`
Mapped raw system colors to themed/opacity-modulated variants:
- `.green` → `Color.ttBody`
- `.red` → `Color.red.opacity(0.8)`
- `.blue` → `Color.ttGlow.opacity(0.9)`
- `.orange` → `Color.orange.opacity(0.8)`
- `.ttAccent` unchanged (already themed)

### P1-8 · ServiceDetailView hero hardcoded `.teal`
**File:** `ServiceDetailView.swift`
Changed `.teal.opacity(0.8)` → `Color.ttGlow.opacity(0.8)` in the hero gradient to route through the theme token.

---

## Motion Fixes

### P0-1 · Success overlay entrance never animates
**Files:** `WriteTripReportView.swift`, `WriteReviewView.swift`
- Added `@State private var checkmarkVisible: Bool = false`
- Wrapped `showSuccessOverlay = true` in `withAnimation(.spring(response: 0.4, dampingFraction: 0.7))`
- Replaced `scaleEffect(showSuccessOverlay ? 1.0 : 0.5)` with `scaleEffect(checkmarkVisible ? 1.0 : 0.3)` driven by `.onAppear`/`.onDisappear` on the checkmark image
- Added `.animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: checkmarkVisible)` on the checkmark

### P0-2 · `animateIn` re-fires on LazyVStack cell reuse
**Files:** `CatalogListView.swift`, `ReviewsFeedView.swift`, `ServicesListView.swift`
Removed `.animateIn(delay:)` from every cell inside `LazyVStack` `ForEach` loops. Per-cell `@State var appeared` reset on dealloc caused re-animation on scroll-back. The whole list container retains a single entrance animation naturally.

### P1-1 · Double `animateIn` nesting in ExploreView
**File:** `ExploreView.swift`
Removed `.animateIn(delay:)` from the individual `MiniStrainCard` wrappers inside horizontal `ScrollView` sections. Each `sectionView` container still retains its own `animateIn`, providing one clean entrance per section.

### P1-2 · `bookmarkBounce` reset uses broken `DispatchQueue.asyncAfter`
**Files:** `StrainDetailView.swift`, `SubstanceDetailView.swift`, `ServiceDetailView.swift`
Replaced the entire `bookmarkBounce` state + `withAnimation` + `DispatchQueue.asyncAfter` pattern with `.symbolEffect(.bounce, value:)` on the bookmark image. This is iOS 17+ native, handles timing internally, never fires on a dismissed view, and eliminates the `@State private var bookmarkBounce` variable entirely.

### P1-3 · AgeGateView transition ignores `accessibilityReduceMotion`
**File:** `AgeGateView.swift`
Added `@Environment(\.accessibilityReduceMotion) private var reduceMotion`. Button action now branches: bare `ageVerified = true` when reduce motion is on; `withAnimation(.spring(response: 0.5, dampingFraction: 0.85))` when it's off.

### P1-4 · `GeometryReader` in `IntensityBar` inside list cells
**File:** `TripReportCard.swift`
Replaced `GeometryReader`-based progress bar with `scaleEffect(x:anchor: .leading)` approach — zero layout overhead, GPU-composited, eliminates 3× concurrent `GeometryReader` instances per `TripReportCard`.

---

## Copy Fixes

### P0-1 · Fireside Project tel: link dials wrong number
**Files:** `ProfileView.swift`, `HomeView.swift`
- `ProfileView.swift`: `tel:6232737654` → `tel:6234737433`; display text updated to `"(623) 473-7433"`
- `HomeView.swift` alert message: `"62-FIRESIDE"` → `"(623) 473-7433"`
- `HomeView.swift` alert button: `"Visit fireside-project.org"` → `"Visit firesideproject.org"` (P1-7 fixed here too)

### P0-2 · "Terms of Service" link resolves to support.html
**File:** `ProfileView.swift`
Changed Terms of Service `Link` destination from `.../support.html` to `.../terms.html` so it no longer duplicates the Community Guidelines URL.

### P0-3 · Age-gate consent omits Terms of Service and Privacy Policy
**File:** `AgeGateView.swift`
Updated consent disclosure from a single "Community Guidelines" link to inline links for all three documents: Terms of Service, Privacy Policy, and Community Guidelines. Added missing comma after "By continuing".

### P1-1 · Explicit dosage instruction in Tip of the Day
**File:** `HomeView.swift`
Replaced: `"Start with a lower amount than you think you need. You can always explore deeper next time."`
With: `"Thoroughly research any substance before an experience, and consult a healthcare provider when possible. Preparation is a core harm-reduction practice."`

### P1-2 · "It will pass" discourages crisis help-seeking
**File:** `HomeView.swift`
Replaced: `"If anxiety arises, remember: change your setting, breathe deeply, and it will pass."`
With: `"If anxiety arises, grounding techniques can help: slow your breathing, change your environment, and focus on something familiar. If distress persists or escalates, call the Fireside Project at (623) 473-7433 or dial 988."`

### P1-3 · "Beginner Friendly" encourages inexperienced use
**File:** `ExploreView.swift`
Section header renamed from `"Beginner Friendly"` → `"Lower Intensity"`.

### P1-6 · "Showing services near you" is misleading
**File:** `ServicesListView.swift`
Changed to `"Featured service centers"` — removes false location claim since the app does not use CoreLocation.

### P1-7 · "fireside-project.org" label typo (with hyphen)
**File:** `HomeView.swift`
Button label corrected from `"Visit fireside-project.org"` → `"Visit firesideproject.org"` to match the actual URL the button opens.

---

## Files Modified

| File | Changes |
|------|---------|
| `Views/Explore/ExploreView.swift` | P0-1 MiniStrainCard, P1-1 section font, Motion P1-1 double animateIn, Copy P1-3 section label |
| `Views/Catalog/StrainDetailView.swift` | P0-3 CTA gradient, Motion P1-2 symbolEffect bookmark |
| `Views/Catalog/SubstanceDetailView.swift` | P0-2 hero height, P0-3 CTA gradient, P1-7 jurisdictionColor, Motion P1-2 symbolEffect bookmark |
| `Views/Services/ServiceDetailView.swift` | P0-2 hero height, P0-3 CTA gradient, P1-8 ttGlow hero, Motion P1-2 symbolEffect bookmark |
| `Views/AgeGate/AgeGateView.swift` | P0-3 CTA gradient, P1-6 disclosure text, Motion P1-3 reduceMotion, Copy P0-3 consent text |
| `Views/Profile/ProfileView.swift` | P1-2 section header color, P1-4 avatar gradient, Copy P0-1 Fireside number, Copy P0-2 ToS link |
| `Views/Components/TripReportCard.swift` | P1-5 ttBody green, Motion P1-4 IntensityBar scaleEffect |
| `Views/Components/ServiceCard.swift` | P1-3 icon gradient |
| `Views/Components/SubstanceCard.swift` | P1-3 icon gradient |
| `Views/Home/HomeView.swift` | Copy P0-1 Fireside alert, Copy P1-1 dosage tip, Copy P1-2 anxiety tip, Copy P1-7 URL label |
| `Views/Services/ServicesListView.swift` | Copy P1-6 "near you" text, Motion P0-2 LazyVStack animateIn |
| `Views/Reviews/WriteTripReportView.swift` | Motion P0-1 success overlay animation |
| `Views/Reviews/WriteReviewView.swift` | Motion P0-1 success overlay animation |
| `Views/Catalog/CatalogListView.swift` | Motion P0-2 LazyVStack animateIn |
| `Views/Reviews/ReviewsFeedView.swift` | Motion P0-2 LazyVStack animateIn |

---

## Issues Not Fixed (Intentionally Skipped)

- **Copy P1-4 / P1-5**: B+ and Liberty Caps descriptions — in `MockData.swift` (out of scope per instructions)
- **All P2 issues**: Lower priority, out of scope for this pass
