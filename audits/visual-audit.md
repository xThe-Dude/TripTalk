# TripTalk Visual Design Audit
**Date:** 2026-03-09  
**Auditor:** Lily (Senior Visual Designer)  
**Severity Scale:** 🔴 Critical | 🟠 Major | 🟡 Minor | 🔵 Polish

---

## Executive Summary

The app has a **strong foundation** — the dark glass card system, gradient backgrounds, and design token architecture are well-conceived. The serif + teal + gold palette creates genuine premium feel. However, there are **consistency gaps** that separate this from a Calm/Headspace tier product. Key issues: hardcoded colors bypassing tokens, inconsistent spacing rhythm, duplicated card styling instead of using modifiers, and missing micro-interactions.

**Findings:** 5 Major, 9 Minor, 8 Polish

---

## 1. Design Token Consistency

### 🟠 Hardcoded `Color.teal` used instead of `Color.ttGlow` throughout
**File:** Multiple files (SubstanceCard.swift:12, ReviewCard.swift:8, TripReportCard.swift:27, ServiceCard.swift:14)
**Issue:** `Color.teal` is used directly ~25+ times across the codebase instead of `Color.ttGlow` (which equals `.teal`). If the accent glow color ever changes, you'd need to hunt through every file.
**Impact:** Token system is undermined. Changing the glow accent requires a full codebase sweep.
**Fix:** Global find-replace `Color.teal` → `Color.ttGlow` everywhere it's used as the accent glow. Keep `Color.teal` only where it's intentionally a different semantic (e.g., the gradient in buttons uses `.teal` as a specific gradient stop — these should become a `Color.ttButtonGradientStart` token).

### 🟠 Hardcoded `.purple`, `.green`, `.pink` in IntensityBar and TripReportCard
**File:** TripReportCard.swift:62-64, WriteTripReportView.swift:78-96
**Issue:** `IntensityBar(label: "Visual", value: ..., color: .purple)` uses system `.purple` instead of `Color.ttVisual`. Same for `.green` vs `Color.ttBody` and `.pink` vs `Color.ttEmotional`.
**Impact:** The contextual color tokens (`ttVisual`, `ttBody`, `ttEmotional`) exist but aren't used where they should be. The system `.purple` is different from the custom `ttVisual` purple.
**Fix:**
```swift
// TripReportCard.swift:62-64
IntensityBar(label: "Visual", value: report.visualIntensity, color: .ttVisual)
IntensityBar(label: "Body", value: report.bodyIntensity, color: .ttBody)
IntensityBar(label: "Emotion", value: report.emotionalIntensity, color: .ttEmotional)

// WriteTripReportView.swift sliders
Slider(value: $visualIntensity, in: 0...5, step: 1).tint(.ttVisual)
Slider(value: $bodyIntensity, in: 0...5, step: 1).tint(.ttBody)
Slider(value: $emotionalIntensity, in: 0...5, step: 1).tint(.ttEmotional)
```

### 🟡 Hardcoded `.blue` used inconsistently
**File:** ServiceCard.swift:10 (`.blue.opacity(0.8)`), SubstanceCard.swift:11, verified badge uses `.blue` (ServiceCard.swift:18, ServiceDetailView.swift)
**Issue:** `.blue` appears as gradient stops and verified badge color but has no design token. Is this intentional blue or should it be a token?
**Impact:** No single source of truth for the blue accent.
**Fix:** Add `static let ttBlue = Color.blue` or better, `static let ttVerified = Color.blue` for semantic clarity.

---

## 2. Typography Scale

### 🟡 Section headers inconsistently use `.title2` vs `.title3`
**File:** ExploreView.swift:53 uses `.title2` for section headers, HomeView.swift:97 uses `.title3`, ProfileView.swift uses `.title3`
**Issue:** Explore uses `.title2` for section headers ("Popular Varieties") while Home and Profile use `.title3`. Both are section-level headers at the same hierarchy.
**Impact:** Typography hierarchy breaks between tabs — Explore feels "louder" than Home.
**Fix:** Standardize all section headers to `.title3` with `.serif` and `.bold`. Reserve `.title2` for page-level headers only.

### 🔵 Missing typography token system
**File:** ThemeColors.swift (no typography tokens)
**Issue:** Colors have tokens but typography doesn't. Each view manually specifies `.font(.system(.title3, design: .serif, weight: .bold))` — ~20 repetitions across the codebase.
**Impact:** If you want to change the section header style, you touch 15+ files. Calm and Headspace use strict type scales.
**Fix:** Add a `Typography` enum or View extension:
```swift
extension Font {
    static let ttLargeTitle = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let ttTitle = Font.system(.title2, design: .serif, weight: .bold)
    static let ttSectionHeader = Font.system(.title3, design: .serif, weight: .bold)
    static let ttHeadline = Font.system(.headline, design: .serif)
    static let ttBody = Font.body
    static let ttCaption = Font.caption
}
```

---

## 3. Spacing Rhythm

### 🟠 Inconsistent VStack spacing across similar views
**File:** HomeView.swift:20 (`spacing: 24`), ExploreView.swift:14 (`spacing: 20`), CatalogListView.swift:14 (`spacing: 12`), ServicesListView.swift:11 (`spacing: 4`)
**Issue:** Top-level ScrollView VStack spacing varies wildly: 24, 20, 12, and 4 across the four main list views. These are structurally identical (search bar + list).
**Impact:** Density feels different on each tab. Services feels cramped, Home feels airy. Inconsistent rhythm.
**Fix:** Standardize to `spacing: 16` or `spacing: 20` for all main list views. Use `spacing: 24` only for Home (editorial layout) and `spacing: 16` for list views.

### 🟡 ServicesListView has `spacing: 4` — too tight
**File:** ServicesListView.swift:11
**Issue:** The outer VStack uses `spacing: 4` which means the search bar, location label, and card list are nearly touching.
**Impact:** Feels cramped compared to every other tab. Breaks the visual rhythm.
**Fix:** Change to `spacing: 12` to match CatalogListView, or `spacing: 16` for more breathing room.

### 🟡 ReviewsFeedView missing `.padding(.horizontal)` on the sort picker's container
**File:** ReviewsFeedView.swift:25-31
**Issue:** The Picker has `.padding(.horizontal)` but the filter chips ScrollView adds its own `.padding(.horizontal)` inside the HStack. The LazyVStack has `.padding(.horizontal)`. Spacing between sort picker and filter chips is only `spacing: 10` (parent VStack).
**Impact:** Minor — works but vertical rhythm between segments (sort → filter → list) could be tighter.
**Fix:** Consider `spacing: 12` for the outer VStack for consistency.

---

## 4. Card Styles

### 🟠 MiniStrainCard manually recreates darkGlassCard instead of using the modifier
**File:** ExploreView.swift:140-160 (MiniStrainCard)
**Issue:** MiniStrainCard manually applies `.background(RoundedRectangle... .fill(Color.white.opacity(0.07))... .ultraThinMaterial)`, `.clipShape`, `.overlay(stroke)`, and `.shadow` — this is a copy-paste of `DarkGlassCard` but without using the modifier. The modifier also applies `.padding()` which may not be desired here, but the duplication is a maintenance risk.
**Impact:** If DarkGlassCard styling changes (corner radius, opacity, shadow), MiniStrainCard won't update. Already slightly divergent (no `.padding()` in the manual version).
**Fix:** Either use `.darkGlassCard()` and handle padding differently, or extract the background-only portion into a separate modifier like `.darkGlassBackground()` that doesn't include padding.

### 🔵 ThemedCard wrapper is unused / redundant
**File:** ThemedCard.swift
**Issue:** `ThemedCard` exists as a wrapper that just calls `.darkGlassCard()`, but no view in the codebase uses it. Every view calls `.darkGlassCard()` directly.
**Impact:** Dead code. Adds cognitive overhead when reading the component list.
**Fix:** Delete `ThemedCard.swift` or use it as the canonical way to wrap card content.

---

## 5. Color Usage & Purpose

### 🟡 SubstanceCard accent bar always uses `Color.teal` while StrainCard uses `strain.parentSubstance.color`
**File:** SubstanceCard.swift:8, StrainCard.swift:8
**Issue:** StrainCard's left accent bar is colored by substance type (contextual), but SubstanceCard always uses `.teal` regardless of substance category. The two cards appear side by side in SubstanceDetailView.
**Impact:** SubstanceCard feels generic. A psilocybin substance card has the same teal bar as a ketamine one.
**Fix:** Use the substance's category color for the accent bar, similar to how StrainCard does it.

### 🔵 EmptyStateView button uses `Color.ttAccent` but CTA buttons elsewhere use teal→blue gradient
**File:** EmptyStateView.swift:44
**Issue:** The action button in EmptyStateView uses flat `Color.ttAccent` background, but every other CTA button (AgeGateView, StrainDetailView, SubstanceDetailView, ServiceDetailView) uses `LinearGradient(colors: [.teal, .blue.opacity(0.8)])`.
**Impact:** EmptyState CTAs feel flat compared to the rest of the app. Minor inconsistency.
**Fix:** Use the same teal→blue gradient for consistency, or make the gradient a reusable modifier `.ttPrimaryButton()`.

---

## 6. Visual Hierarchy

### 🟡 HomeView "Community Stats" section has weak visual weight
**File:** HomeView.swift:132-139
**Issue:** The community stats bar ("X trip reports • Y varieties • Growing daily") is wrapped in `.darkGlassCard()` which gives it equal visual weight to the tip of the day and quick links. It's footer-level content in a card-level container.
**Impact:** The page doesn't have a clear visual "fade out" at the bottom. Everything has equal presence.
**Fix:** Remove `.darkGlassCard()` from the stats line. Just use plain text with reduced opacity, or a simple divider above it.

### 🔵 ProfileView has too many animated sections with staggered delays up to 0.85s
**File:** ProfileView.swift (delays: 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.85)
**Issue:** 9 sections with staggered animation means the last section doesn't appear until ~1.25s after navigation. On a fast scroll, content may still be animating in.
**Impact:** Feels sluggish. Calm/Headspace cap stagger at ~0.4s total.
**Fix:** Cap max delay at 0.4s. Use `delay: min(Double(index) * 0.05, 0.4)` or animate sections in batches.

---

## 7. Icon Consistency

### 🟡 Quick link icons use `.title3` but tab bar icons are system default size
**File:** HomeView.swift:148
**Issue:** Quick link circle icons use `.title3` for SF Symbols. Tab bar uses default sizing. The profile avatar uses `.system(size: 70)`. There's no consistent icon size scale.
**Impact:** Minor — each context naturally has different sizes. But within quick links, `.title3` is fine.
**Fix:** Document icon sizes per context: tab bar (default), cards (.title3/.title2 for hero), quick links (.title3), inline (.caption/.caption2).

### 🔵 Verified badge icon is `.caption` in ServiceCard but unsized in ServiceDetailView
**File:** ServiceCard.swift:18, ServiceDetailView.swift:32
**Issue:** ServiceCard uses `.font(.caption)` for the checkmark.seal.fill, but ServiceDetailView doesn't specify a size (inherits from parent `.title2`), making it much larger.
**Impact:** The verified badge jumps in size between list and detail, breaking the visual connection.
**Fix:** Add `.font(.body)` or `.font(.title3)` to the detail view badge for proportional but not oversized rendering.

---

## 8. Gradient Background Usage

### 🔵 All views correctly use `GradientBackground()` — no flat backgrounds detected
**File:** All view files
**Issue:** None — every view uses `GradientBackground()` or `GradientBackground(intensity: .immersive)` appropriately.
**Impact:** N/A — this is well-implemented.
**Fix:** N/A. ✅

---

## 9. Dark Mode Edge Cases

### 🟡 Form/TextEditor background may flash white on older iOS
**File:** WriteReviewView.swift, WriteTripReportView.swift, CatalogFilterSheet.swift
**Issue:** `.scrollContentBackground(.hidden)` is used correctly, but `TextEditor` has a known iOS bug where it briefly shows a white background before the custom styling applies. The `.listRowBackground(Color.white.opacity(0.05))` is correctly applied.
**Impact:** Potential brief white flash in text editors on iOS 16. iOS 17+ is fine.
**Fix:** Wrap TextEditor in a ZStack with the dark background explicitly behind it:
```swift
TextEditor(text: $body_)
    .scrollContentBackground(.hidden)
    .foregroundStyle(Color.ttPrimary)
```

### 🔵 Segmented picker in ReviewsFeedView uses system styling
**File:** ReviewsFeedView.swift:26-30
**Issue:** `.pickerStyle(.segmented)` uses the system segmented control which has its own background. `.tint(Color.ttAccent)` helps but the segment background is still system-gray on dark mode.
**Impact:** The segmented picker looks "system" while everything else looks custom. Breaks the premium glass aesthetic.
**Fix:** Replace with a custom segmented picker using HStack + buttons + darkGlassCard styling, or accept the system look (Spotify does this).

---

## 10. Premium Feel — Gaps vs Calm/Headspace/Spotify

### 🟠 No micro-animations on cards
**File:** All card components
**Issue:** Cards appear with `animateIn` (fade + slide) but have no hover/touch feedback beyond `pressEffect` on buttons. Calm uses subtle parallax on cards. Headspace uses spring animations on selection.
**Impact:** The app feels static once loaded. Premium apps have constant subtle motion.
**Fix:** Add subtle scale animation on card tap (already have `pressEffect` — apply it to NavigationLink-wrapped cards too). Consider adding a subtle shimmer/gradient animation on the featured card.

### 🔵 No skeleton/loading states
**File:** All list views
**Issue:** Pull-to-refresh just waits 0.5s with no visual feedback. No skeleton loading states. Calm shows animated placeholder cards during load.
**Impact:** The `.refreshable` feels fake — there's no visual indication of loading.
**Fix:** Add a `SkeletonCard` component that shows pulsing placeholder shapes matching card layout.

### 🔵 No haptic feedback on card navigation
**File:** CatalogListView, ExploreView, ServicesListView
**Issue:** Tapping a card to navigate has no haptic. Only star rating, buttons, and bookmarks have haptics. Headspace gives light haptic on every navigation.
**Impact:** Navigation feels less tactile than premium competitors.
**Fix:** Add `Haptics.light()` via `.simultaneousGesture` or in NavigationLink wrapper.

### 🔵 Featured card could use animated gradient border
**File:** HomeView.swift (featured variety section)
**Issue:** The featured spotlight uses `darkGlassCardElevated` which has a static gradient border. Calm's featured cards use slow-rotating gradient borders (conic gradient animation).
**Impact:** The featured card doesn't feel as "alive" as competitors' hero content.
**Fix:** Add a slow-rotating `AngularGradient` overlay on the elevated card border:
```swift
.overlay(
    RoundedRectangle(cornerRadius: 20)
        .stroke(
            AngularGradient(colors: [glowColor, .clear, glowColor], center: .center)
                .rotationEffect(.degrees(rotation)),
            lineWidth: 1
        )
)
// Animate rotation 0→360 over ~8 seconds
```

### 🔵 No "pull-down to reveal" search pattern
**File:** HomeView.swift
**Issue:** Home has no search. Explore and Catalog have search bars always visible. Spotify/Apple Music hide search behind a pull-down gesture for cleaner initial state.
**Impact:** Minor — visible search is fine for utility apps. But it eats vertical space on Explore.
**Fix:** Consider collapsible search on Explore that reveals on pull-down or scroll-up.

### 🔵 Tab bar could be more custom
**File:** ContentView.swift
**Issue:** The tab bar uses UIKit appearance with blur effect — good. But competitors use fully custom tab bars with animated selection indicators (Spotify's bounce, Calm's glow).
**Impact:** The tab bar is the most "system iOS" part of the app. It works but doesn't feel bespoke.
**Fix:** Consider a custom tab bar with a glow indicator under the selected tab, matching the glass aesthetic.

### 🔵 No empty state illustrations
**File:** EmptyStateView.swift
**Issue:** Empty states use SF Symbols with a radial glow — nice. But Calm/Headspace use custom illustrations or Lottie animations for empty states.
**Impact:** Empty states feel functional rather than delightful.
**Fix:** Phase 2 — add custom illustrations or animated SF Symbols (iOS 17 symbol effects).

---

## Summary by Priority

| Priority | Count | Action |
|----------|-------|--------|
| 🟠 Major | 5 | Fix in next sprint — token consistency, spacing, card duplication |
| 🟡 Minor | 9 | Fix soon — typography scale, section spacing, icon sizing |
| 🔵 Polish | 8 | Backlog — micro-animations, loading states, custom tab bar |

### Top 5 Quick Wins (High Impact, Low Effort)
1. **Replace hardcoded `.purple`/`.green`/`.pink` with `ttVisual`/`ttBody`/`ttEmotional`** — 5 min
2. **Standardize section header font to `.title3`** — 10 min
3. **Fix ServicesListView `spacing: 4` → `spacing: 16`** — 1 min
4. **Replace `Color.teal` → `Color.ttGlow` globally** — 15 min (careful grep)
5. **Cap ProfileView animation delays at 0.4s** — 2 min
