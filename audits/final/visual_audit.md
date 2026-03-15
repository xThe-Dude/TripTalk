# TripTalk — Visual Design Audit
**Date:** 2026-03-14
**Auditor:** Senior Visual Designer
**Scope:** 26 Swift view files + component library

---

## Summary

The codebase has a strong, coherent dark-glass theme anchored by `ThemeColors.swift` and `DarkGlassCard`. The biggest risks are (a) primary CTA button gradient inconsistency that breaks brand trust across onboarding/detail views, (b) three different hero heights across detail views creating a jarring navigation experience, and (c) `MiniStrainCard` silently duplicating card styling code that will drift over time. Typography hierarchy is mostly solid; spacing is slightly looser in some list views. Color discipline is ~85% there — a handful of hardcoded system colors remain.

---

## P0 — Critical

### P0-1: `MiniStrainCard` duplicates `DarkGlassCard` styling verbatim
**File:** `ExploreView.swift` — lines 218–238
**What's wrong:** `MiniStrainCard` manually copies the entire `DarkGlassCard` modifier — `fill(Color.white.opacity(0.07))`, `.ultraThinMaterial`, gradient stroke `Color.white.opacity(0.2)→0.05`, `shadow(radius: 12, y: 6)` — instead of calling `.darkGlassCard()`. If the card surface ever changes (opacity, corner radius, stroke), this card will silently look different from every other card in the app.
**Fix:** Remove the manual `.background`/`.clipShape`/`.overlay`/`.shadow` chain and replace with `.darkGlassCard()`. Note: `cornerRadius: 16` matches `DarkGlassCard`'s 16, so the call is a 1-for-1 swap.

---

### P0-2: Three different hero heights across detail views
**Files:**
- `StrainDetailView.swift` line 203/234 → `height: 260`
- `SubstanceDetailView.swift` line 33 → `height: 240`
- `ServiceDetailView.swift` line 19 → `height: 220`

**What's wrong:** Navigating from a `ServiceCard` → `ServiceDetailView` → back → `StrainDetailView` produces a visual jump of up to 40 pt between hero areas. All three are conceptually "entity detail heroes" and should share the same height to reinforce hierarchy consistency.
**Fix:** Standardize to `260` (the largest, which belongs to the most media-rich detail). Update `SubstanceDetailView` from `240` → `260` and `ServiceDetailView` from `220` → `260`.

---

### P0-3: Primary CTA button gradient is inconsistent across the app
**Files:**
- `StrainDetailView.swift` line 142 → `[.teal, .blue.opacity(0.8)]`
- `SubstanceDetailView.swift` line 165 → `[.teal, .blue.opacity(0.8)]`
- `ServiceDetailView.swift` line 114 → `[.teal, .blue.opacity(0.8)]`
- `AgeGateView.swift` line 59 → `[.teal, .blue.opacity(0.8)]`
- `OnboardingView.swift` line 91 → `[.teal, .green.opacity(0.8)]`  ← different

**What's wrong:** The brand ends its teal gradient in `.blue` in four places but in `.green` in the first screen the user ever sees (Onboarding). This is a trust-breaking inconsistency: the app looks different the moment you get past onboarding.
**Fix:** Decide on one canonical CTA gradient and extract it. Recommended: `[.teal, .green.opacity(0.8)]` (green aligns better with the app's nature/wellness brand and matches `GradientBackground`'s teal/green orbs). Update all four `[.teal, .blue.opacity(0.8)]` instances. Then define a shared `View` extension or `ButtonStyle` so this never drifts again.

---

## P1 — High

### P1-1: `ExploreView` section headers use `.title2` — all other views use `.title3`
**File:** `ExploreView.swift` line 155
**What's wrong:** `sectionView(_:)` applies `.system(.title2, design: .serif, weight: .bold)` while every detail view section header (StrainDetail, SubstanceDetail, ServiceDetail, ProfileView, HomeView) uses `.title3`. The mismatch makes Explore section labels visually heavier and more prominent than equivalent labels inside detail views — backwards hierarchy.
**Fix:** Change `.title2` → `.title3` on line 155.

---

### P1-2: Section header color inconsistency — `.ttSectionHeader` vs `.ttPrimary`
**Files:**
- `ProfileView.swift` line 318 → `Color.ttSectionHeader` (warm grey-green, lighter)
- `StrainDetailView.swift` lines 19, 32, 45, 60, 74, 107 → `Color.ttPrimary` (cream)
- `SubstanceDetailView.swift` lines 71, 84, 99, 123, 140 → `Color.ttPrimary`
- `ServiceDetailView.swift` lines 64, 76, 97 → `Color.ttPrimary`
- `HomeView.swift` lines 133, 163 → `Color.ttPrimary`

**What's wrong:** Profile section titles render noticeably dimmer than equivalent-level section titles in every other view. `.ttSectionHeader` = `Color(red: 0.85, green: 0.88, blue: 0.85)` vs `.ttPrimary` = `Color(red: 0.95, green: 0.94, blue: 0.91)`. Users who bookmark a strain in Profile then open it in StrainDetail will see the "Effects" header shift in brightness.
**Fix:** Standardize all `section header` Text to `Color.ttPrimary`. `ttSectionHeader` is appropriate for Form section headers (filter/write sheets) where the iOS system chrome reduces emphasis — keep it there.

---

### P1-3: `ServiceCard` and `SubstanceCard` use hardcoded teal→blue icon gradients
**Files:**
- `ServiceCard.swift` line 14 → `LinearGradient(colors: [.teal, .blue.opacity(0.8)])`
- `SubstanceCard.swift` line 21 → `LinearGradient(colors: [.teal, .blue.opacity(0.8)])`

**What's wrong:** Both card icon backgrounds use a hardcoded gradient not tied to any theme token. If the brand gradient changes (see P0-3), these won't update. Additionally `.teal` here should be `Color.ttGlow` (which is defined as `Color.teal`) to at least go through the theme indirection.
**Fix:** Replace inline gradients with the canonical CTA gradient resolved in P0-3, or define a dedicated `iconGradient` extension on `LinearGradient` in `ThemeColors.swift`.

---

### P1-4: `ProfileView` avatar icon uses a flat gradient — inconsistent with other hero icons
**File:** `ProfileView.swift` line 27–29
**What's wrong:** The avatar `person.circle.fill` uses `LinearGradient(colors: [.teal, .blue.opacity(0.8)])` (the teal→blue variant). All other large hero icons (SubstanceDetailView, ServiceDetailView, OnboardingView icon glows) use teal→green, and all use the teal-→-indigo brand colors. This is also an instance of the P0-3 gradient inconsistency at the largest icon in the profile hero area.
**Fix:** Align with the canonical gradient decided in P0-3.

---

### P1-5: `TripReportCard` "Would repeat" label uses raw `.green`
**File:** `TripReportCard.swift` line 78
**What's wrong:** `.foregroundStyle(.green)` uses a system color with no theme token. On some backgrounds or in future dark mode variants, system `.green` can render quite saturated against the muted card surface. `Color.ttBody` (defined as `Color(red: 0.3, green: 0.8, blue: 0.55)`) is the app's themed green and is appropriately desaturated.
**Fix:** Replace `.green` with `Color.ttBody` at line 78.

---

### P1-6: `AgeGateView` age disclosure text uses `.opacity(0.6)` on `ttPrimary` — should use `ttSecondary`
**File:** `AgeGateView.swift` line 48–49
**What's wrong:** `Text("TripTalk is for adults 21 and older.").font(.headline).foregroundStyle(Color.ttPrimary).opacity(0.6)` applies a runtime opacity modifier to the primary color, effectively fabricating an ad-hoc secondary style. The result is visually indistinguishable from `ttSecondary` but is semantically inconsistent and will produce different results under other animations (`.scaleEffect` + opacity interactions, for example).
**Fix:** Remove `.opacity(0.6)` and replace `Color.ttPrimary` with `Color.ttSecondary`.

---

### P1-7: `SubstanceDetailView` `jurisdictionColor` uses raw system colors
**File:** `SubstanceDetailView.swift` lines 226–233
**What's wrong:** `jurisdictionColor` returns `.green`, `.red`, `.blue`, `.orange` — raw system colors. System `.green` and `.red` are highly saturated and clash with the muted glass card surfaces. At minimum they should be opacity-tinted or use semantic tokens. `.blue` for `medicalOnly` is especially problematic as it matches the verified badge's `.blue` from `ServiceCard`.
**Fix:** Map to tinted, themed variants: `legal → Color.ttBody` (themed green), `illegal → Color.red.opacity(0.8)`, `medicalOnly → Color.ttGlow.opacity(0.9)`, `decriminalized → Color.ttAccent`, `underReview → Color.orange.opacity(0.8)`. Or define a new `ttLegal`, `ttIllegal` token set in `ThemeColors.swift`.

---

### P1-8: `ServiceDetailView` hero uses hardcoded `.teal.opacity(0.8)` instead of `Color.ttGlow`
**File:** `ServiceDetailView.swift` line 15
**What's wrong:** `LinearGradient(colors: [.teal.opacity(0.8), Color(red: 0.05, green: 0.12, blue: 0.22)])` duplicates the same raw `.teal` that `ttGlow` already abstracts. `SubstanceDetailView` uses its own `heroColor` computed property (line 29) which at least checks type, but `ServiceDetailView` just hardcodes teal.
**Fix:** Replace `.teal.opacity(0.8)` with `Color.ttGlow.opacity(0.8)`.

---

## P2 — Low

### P2-1: Outer `VStack` spacing is inconsistent across tab root views
**What's wrong:**
- `HomeView.swift` line 33 → `VStack(spacing: 24)`
- `ExploreView.swift` line 10 → `VStack(spacing: 20)`
- `CatalogListView.swift` line 12 → `VStack(spacing: 12)`
- `ReviewsFeedView.swift` line 19 → `VStack(spacing: 10)`

The tightest (ReviewsFeed at 10) feels cramped vs Home (24). For list-heavy views that benefit from rhythm, 16 is a good middle-ground default.
**Fix:** Set ReviewsFeedView outer spacing to `16` and CatalogListView to `16`.

---

### P2-2: Search bar bottom padding inconsistency
**Files:**
- `ServicesListView.swift` line 24 → `.padding(.bottom, 8)` after search bar
- `CatalogListView.swift` line 24 → no bottom padding after search bar
- `ExploreView.swift` line 22 → no bottom padding after search bar

**What's wrong:** Services search bar has extra breathing room; the others don't. Minor visual inconsistency when switching between tabs.
**Fix:** Add `.padding(.bottom, 8)` after the search bar in `CatalogListView` and `ExploreView` to match Services.

---

### P2-3: `HomeView` quicklink `color: .blue` and `color: .orange` are raw system colors
**File:** `HomeView.swift` lines 144, 148
**What's wrong:** `color: .blue` for "Services" and `color: .orange` for "Safety" use raw system colors. While contextually sensible, they don't go through theme tokens. If the theme ever gains a `ttWarning` or `ttServices` token, these won't automatically update.
**Fix:** Low urgency, but consider defining `Color.ttWarning = Color.orange.opacity(0.9)` in ThemeColors and using it for the Safety link.

---

### P2-4: `AgeGateView` hero icon uses flat fill instead of teal gradient
**File:** `AgeGateView.swift` lines 27–29
**What's wrong:** `leaf.circle.fill` is colored with flat `Color.ttPrimary` (cream). Every other large hero icon in the app uses a teal gradient. The first screen users see after launch has the least visually impactful icon.
**Fix:** Apply `LinearGradient(colors: [.teal, .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)` to the icon (consistent with OnboardingView icon style at line 54–59).

---

### P2-5: `ServiceCard` verified checkmark uses raw `.blue` — same color as `medicalOnly` jurisdiction
**File:** `ServiceCard.swift` line 27
**What's wrong:** `Image(systemName: "checkmark.seal.fill").foregroundStyle(.blue)` shares the exact same color as the `medicalOnly` jurisdiction status in `SubstanceDetailView`. Two semantically different concepts rendered identically.
**Fix:** Either use `Color.ttGlow` (teal, on-brand) for verified, or `Color.ttAccent` (gold). Teal is recommended as it matches the brand checkmark color used in `ServiceDetailView` offerings list.

---

### P2-6: `ProfileView` "My Trip Reports" / "My Reviews" inline items have no explicit font
**File:** `ProfileView.swift` lines 78, 147
**What's wrong:** `Text(strainName)` inside "My Trip Reports" and `Text(review.title)` inside "My Reviews" have `fontWeight(.semibold)` and `foregroundStyle` applied but no `.font(...)` modifier. They inherit the system default (body), which is correct in practice but fragile — if the parent VStack gains a font modifier, these will silently inherit it.
**Fix:** Add `.font(.subheadline)` to both `Text` views to make intent explicit.

---

### P2-7: `SubstanceDetailView` hero height 240 vs `StrainDetailView` 260 for similar content
*(Partially covered in P0-2 — listed here for the specific file reference.)*
**File:** `SubstanceDetailView.swift` line 33
**Fix:** See P0-2.

---

### P2-8: `ReviewCard` flag button uses `Color.orange.opacity(0.7)` — no theme token
**File:** `ReviewCard.swift` line 67
**What's wrong:** Minor — the flag affordance uses an ad-hoc opacity value. Fine semantically, but `Color.ttWarning` (from P2-3 suggestion) would be cleaner.
**Fix:** Low priority; resolved as part of P2-3 token addition.

---

### P2-9: `.tracking` applied inconsistently on section headers in detail views
**What's wrong:** Some `Text("...").font(.system(.title3, design: .serif, weight: .bold))` headers have `.tracking(0.5)` (SubstanceDetailView, ServiceDetailView) and some don't (StrainDetailView). StrainDetail section headers like "Effects", "About", "Trip Reports" have no tracking.
**Files:**
- `StrainDetailView.swift` lines 19, 32, 45, 60, 74, 107 → no `.tracking`
- `SubstanceDetailView.swift` lines 71, 84, 99 → `.tracking(0.5)` ✓

**Fix:** Add `.tracking(0.5)` to all `.title3` serif section headers in `StrainDetailView.swift`.

---

### P2-10: `OnboardingView` non-terminal pages have `Spacer().frame(height: 100)` instead of matching button height
**File:** `OnboardingView.swift` line 103
**What's wrong:** Pages 1 and 2 use a fixed 100pt spacer at the bottom instead of a transparent/hidden button to reserve the exact space the "Get Started" button occupies on page 3. This means the content area shifts slightly when the user swipes to the final page.
**Fix:** Use a 0-opacity version of the button (or a `Color.clear.frame(height:)` matching the actual rendered button height ~54pt + 60pt bottom padding = ~114pt) for pages 1–2.

---

## Reference: Theme Tokens Quick Guide

| Token | Value | Intended Use |
|---|---|---|
| `ttPrimary` | `rgb(0.95, 0.94, 0.91)` | Headings, primary labels |
| `ttSecondary` | `rgb(0.70, 0.75, 0.72)` | Body text, metadata |
| `ttTertiary` | `rgb(0.50, 0.54, 0.52)` | Timestamps, footnotes |
| `ttAccent` | `rgb(0.85, 0.78, 0.55)` | Gold highlights, ratings, CTAs text |
| `ttSectionHeader` | `rgb(0.85, 0.88, 0.85)` | Form section headers (sheets only) |
| `ttGlow` | `Color.teal` | Teal accent, orbs, icons |
| `ttCardBg` | `white.opacity(0.08)` | Card fill baseline |
| `ttSheetBg` | `rgb(0.06, 0.10, 0.15)` | Sheet/modal backgrounds |
| `ttVisual` | `rgb(0.65, 0.45, 0.95)` | Purple — visual effect tags |
| `ttBody` | `rgb(0.30, 0.80, 0.55)` | Green — body/physical tags |
| `ttEmotional` | `rgb(0.90, 0.45, 0.65)` | Pink — emotional effect tags |
| `ttSpiritual` | `rgb(0.85, 0.75, 0.35)` | Gold — spiritual tags |

---

## Issue Count Summary

| Priority | Count |
|---|---|
| P0 Critical | 3 |
| P1 High | 8 |
| P2 Low | 10 |
| **Total** | **21** |
