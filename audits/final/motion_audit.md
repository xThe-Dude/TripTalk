# TripTalk — Motion Engineering Audit
**Date:** 2026-03-15
**Auditor:** Senior Motion Engineer
**Scope:** All Swift view files in `TripTalk/Views/`, `TripTalk/Views/Components/`, and `TripTalk/ViewModels/AppState.swift`
**iOS Target:** 17+

---

## Executive Summary

The motion foundation is solid — `AnimatedAppearance`, `PressEffect`, and the `Haptics` enum are well-structured and most of the UI has reduce-motion awareness. However, there are **2 P0 bugs** that will cause visible jank or broken gesture state on every device, **8 P1 defects** covering missing reduce-motion guards, broken transitions, and animation composition errors, and **8 P2 polish gaps**.

---

## P0 — Critical (Visible Bug / Runtime Jank)

---

### P0-1: `AnimatedAppearance` re-triggers every time a lazy cell scrolls back into view

**File:** `TripTalk/Views/Components/ThemeColors.swift:111–122`
**Callers:** `CatalogListView.swift:87`, `ReviewsFeedView.swift:51`, `ServicesListView.swift:53`, `ExploreView.swift:54,71,88`

**What's wrong:**
`AnimatedAppearance` stores its trigger in `@State private var appeared = false`. SwiftUI's `LazyVStack` destroys view instances when they scroll off-screen and recreates them when they scroll back. Each recreation resets the `@State`, so `appeared` is `false` again, and the `.onAppear` fires the slide-up + fade-in animation every time the item re-enters the viewport. On the Reviews, Services, and Catalog tabs — which all use `LazyVStack` — every row flashes and slides up every time the user scrolls back up.

```swift
// ThemeColors.swift — the @State resets on every LazyVStack cell recreation
struct AnimatedAppearance: ViewModifier {
    @State private var appeared = false   // ← reset on LazyVStack cell destroy
    ...
    .onAppear { appeared = true }         // ← fires again after scroll-back
}
```

**Fix:**
Apply `.animateIn()` only to the non-lazy section containers, not to individual `LazyVStack` cells. For per-item stagger inside a `LazyVStack`, the flag must live outside the lazy cell — pass a stable `id` into `animateIn` and store appeared IDs in a parent `@State Set<AnyHashable>`:

```swift
// Option A — only animate section-level containers, not LazyVStack rows
// CatalogListView: remove .animateIn() per-row; animate the category group header instead
// ReviewsFeedView: remove .animateIn() per-row; animate the LazyVStack container once
// ServicesListView: same

// Option B — if per-item stagger is required, add appeared tracking to the parent view:
// @State private var appearedIDs: Set<UUID> = []
// .animateIn(id: strain.id, appearedIDs: $appearedIDs)
// The modifier checks the set rather than @State, so it survives LazyVStack recycling
```

---

### P0-2: `PressEffect` `DragGesture` locks `isPressed = true` during scroll

**File:** `TripTalk/Views/Components/ThemeColors.swift:126–140`
**Callers:** Every `.pressEffect()` site inside a `ScrollView` — `HomeView.swift:99`, `OnboardingView.swift:99`, `AgeGateView.swift:65`, `StrainDetailView.swift:148`, `SubstanceDetailView.swift:171`, `ServiceDetailView.swift:120`

**What's wrong:**
`PressEffect` uses `DragGesture(minimumDistance: 0)` to detect press-down. In a `ScrollView`, when the user taps-and-begins-to-scroll, UIScrollView's gesture recognizer cancels the `DragGesture` mid-flight. SwiftUI's `DragGesture.onEnded` is **not called** when the gesture is cancelled by the system scroll recognizer — only `.onChanged` was called. This leaves `isPressed = true` indefinitely, so the button stays scaled to 0.97 until the next tap. On cards inside a `ScrollView` this happens on nearly every scroll-began-on-a-card interaction.

```swift
// ThemeColors.swift:134–137
.simultaneousGesture(
    DragGesture(minimumDistance: 0)
        .onChanged { _ in isPressed = true }
        .onEnded { _ in isPressed = false }   // ← never called on scroll-cancel
)
```

**Fix:**
Replace `PressEffect` ViewModifier with a `ButtonStyle`. SwiftUI's `ButtonStyle` receives `configuration.isPressed` which is correctly managed by UIKit's gesture system and resets on scroll-cancel:

```swift
struct PressEffectButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect((!reduceMotion && configuration.isPressed) ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
```

Apply as `.buttonStyle(PressEffectButtonStyle())` on `Button` views instead of stacking `.pressEffect()` on top of `.buttonStyle(.plain)`. All current `.pressEffect()` call sites already wrap a `Button`, so this is a direct substitution.

---

## P1 — Significant (Broken Animation / Reduce Motion Gap / Quality Regression)

---

### P1-1: Success overlay transition silently no-ops — overlay appears instantly

**Files:** `TripTalk/Views/Reviews/WriteReviewView.swift:153–155`, `TripTalk/Views/Reviews/WriteTripReportView.swift:257–258`

**What's wrong:**
Both submission flows set `showSuccessOverlay = true` directly without `withAnimation`:

```swift
// WriteReviewView.swift:153–155
showSuccess = true
showSuccessOverlay = true   // ← no withAnimation context
Haptics.success()
```

SwiftUI only drives a `.transition()` when the state change happens inside an active animation transaction. Without `withAnimation`, the `ZStack` is inserted instantly with no transition — the overlay snaps in. The `.animation(.spring(...), value: showSuccessOverlay)` modifier on the `ZStack` lives inside the `if showSuccessOverlay` block, so it doesn't exist at insertion time and cannot drive the transition. Separately, `.scaleEffect(showSuccessOverlay ? 1.0 : 0.5)` on the checkmark icon always evaluates to `1.0` inside the block (the view only exists when `showSuccessOverlay == true`), making that line a no-op.

**Fix:**

```swift
// In submitReview() / submitReport():
withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.7)) {
    showSuccessOverlay = true
}
```

Remove the now-redundant `.animation(..., value: showSuccessOverlay)` from the `ZStack`. Add `@Environment(\.accessibilityReduceMotion) private var reduceMotion`.

---

### P1-2: Double opacity animation in `ExploreView` sections produces compound fade

**File:** `TripTalk/Views/Explore/ExploreView.swift:54–108`

**What's wrong:**
Section containers have `.animateIn(delay: X)` making them start at `opacity: 0`, AND each `MiniStrainCard` inside also has `.animateIn(delay: 0.1 + index * 0.03)`. Because `AnimatedAppearance` sets opacity to 0 on both levels, each item's effective rendered opacity = outer × inner. Items appear much darker during the fade-in and the transition takes longer to reach full brightness, creating a visually confusing non-linear ramp.

```swift
// ExploreView.swift:46–60
sectionView("Popular Varieties") {
    HStack {
        ForEach(...) { index, strain in
            MiniStrainCard(strain: strain)
                .animateIn(delay: 0.1 + Double(index) * 0.03)  // inner opacity 0→1
        }
    }
}
.animateIn(delay: 0.1)   // outer opacity also 0→1 simultaneously
```

**Fix:**
Remove `.animateIn()` from the individual `MiniStrainCard` items inside `ExploreView`'s horizontal scroll sections. Keep only the section-level `.animateIn(delay:)`. If per-item stagger is desired, apply it at one level only — the items OR the section, never both.

---

### P1-3: `IntensityChartRow` bar fill animation ignores reduce motion

**File:** `TripTalk/Views/Catalog/StrainDetailView.swift:370`

**What's wrong:**
```swift
RoundedRectangle(cornerRadius: 4)
    .fill(color)
    .frame(width: geo.size.width * value / 5.0)
    .animation(.easeOut(duration: 0.6), value: value)  // ← no reduce motion guard
```

At 0.6s, this is the longest animation in the app. It plays on every `StrainDetailView` open and ignores `accessibilityReduceMotion`.

**Fix:**

```swift
// Add to IntensityChartRow:
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// Change the modifier:
.animation(reduceMotion ? .none : .easeOut(duration: 0.6), value: value)
```

---

### P1-4: `bookmarkBounce` uses `DispatchQueue.main.asyncAfter` — doesn't cancel, ignores reduce motion

**Files:** `StrainDetailView.swift:175–179`, `SubstanceDetailView.swift:198–203`, `ServiceDetailView.swift:141–146`

**What's wrong:**
All three detail views reset the bookmark scale using a raw GCD timer:

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    bookmarkBounce = false   // ← fires even if view was dismissed
}
```

Three issues:
1. The timer fires even after the view is dismissed, mutating state on a deallocated context.
2. `bookmarkBounce = false` is set without `withAnimation`, relying on the view-level `.animation` modifier while `bookmarkBounce = true` used `withAnimation` — inconsistent transaction handling.
3. No reduce motion check: `scaleEffect(bookmarkBounce ? 1.3 : 1.0)` should not scale at all under reduce motion.

**Fix:** Replace the GCD timer with a `Task` (automatically cancelled on view dismissal) and add a reduce motion guard:

```swift
Button {
    appState.toggleSavedStrain(strain.id)
    Haptics.medium()
    guard !reduceMotion else { return }
    bookmarkBounce = true
} label: {
    Image(systemName: ...)
        .scaleEffect(bookmarkBounce ? 1.3 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bookmarkBounce)
}
.onChange(of: bookmarkBounce) { _, newValue in
    guard newValue else { return }
    Task {
        try? await Task.sleep(for: .milliseconds(300))
        bookmarkBounce = false
    }
}
```

Remove the `withAnimation` wrapper from the `bookmarkBounce = true` line — the view-level `.animation` modifier handles the transaction.

---

### P1-5: `ContentView` applies `.animation` to the entire `TabView` body

**File:** `TripTalk/ContentView.swift:49`

**What's wrong:**
```swift
TabView(selection: $state.selectedTab)
    ...
    .animation(.easeInOut(duration: 0.2), value: appState.selectedTab)
```

This animation modifier wraps all tab content in the same transaction when `selectedTab` changes, causing a crossfade of the entire view hierarchy on every tab switch. This competes with NavigationStack push/pop animations and with SwiftUI's native tab presentation behavior. On iOS 17, `TabView` already has a built-in content transition — adding an explicit `.animation` on the wrapper produces a double-animation.

**Fix:**
Remove the `.animation` modifier entirely. The native `TabView` tab-switch is already appropriate. If a custom visual is wanted, apply `TabView.transition` or override per-tab using `.tabItem` appearance hooks — but do not animate the entire `TabView` wrapper.

---

### P1-6: `AgeGateView` `withAnimation {}` has no reduce motion guard

**File:** `TripTalk/Views/AgeGate/AgeGateView.swift:52`

**What's wrong:**
```swift
withAnimation { ageVerified = true }
```

This fires SwiftUI's default crossfade regardless of Reduce Motion. When `ageVerified` flips, `TripTalkApp`'s `ZStack` transitions from `AgeGateView` to `ContentView` with a `.easeInOut(duration: 0.35)` animation.

**Fix:**

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// In button action:
withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.35)) {
    ageVerified = true
}
```

---

### P1-7: `TripTalkApp` launch and onboarding transitions ignore reduce motion

**File:** `TripTalk/TripTalkApp.swift:22–24, 39–41`

**What's wrong:**
```swift
// Onboarding → AgeGate
withAnimation {
    showOnboarding = false     // ← no reduce motion check
}

// Launch screen dismiss
withAnimation(.easeOut(duration: 0.5)) {
    showLaunch = false         // ← no reduce motion check
}
```

The launch dismiss is the first animation every user sees. At 0.5s it's already at the edge of acceptable splash duration; with Reduce Motion enabled it should be instant.

**Fix:**

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

withAnimation(reduceMotion ? .none : .easeOut(duration: 0.5)) {
    showLaunch = false
}
withAnimation(reduceMotion ? .none : .default) {
    showOnboarding = false
}
```

Note: `@Environment` requires the `reduceMotion` property to be added at the `App` body level, which is supported in SwiftUI.

---

### P1-8: `ProfileView` stagger delays are non-monotonic and five sections pile at t=0.4s

**File:** `TripTalk/Views/Profile/ProfileView.swift:41–277`

**What's wrong:**
`ProfileView` uses a regular `VStack` (not lazy), so all child views are instantiated at once and all `.onAppear` handlers fire simultaneously. The declared delays are non-sequential:

| Section | Delay |
|---|---|
| Name/avatar | 0.1 |
| Saved Varieties | 0.2 |
| My Trip Reports | 0.3 |
| Saved Substances | **0.4** |
| Saved Services | **0.35** ← appears after 0.4 in source but animates before |
| My Reviews | **0.35** ← duplicate of Saved Services |
| Settings | **0.4** ← 4th section with this delay |
| Info | **0.4** |
| Crisis Resources | **0.4** |
| About | **0.4** |

"Saved Services" (0.35) animates before "Saved Substances" (0.4) even though it's rendered below it in the UI, creating a bottom-before-top wave. Five sections all animate in simultaneously at t=0.4s, defeating the stagger. Total cascade = 0.4s delay + 0.4s duration = 0.8s — too long for a frequently-visited screen.

**Fix:** Use a strict sequential stagger with 0.05–0.07s intervals, cap total at ~0.35s, and omit `animateIn` on sections that are below the fold (users won't see them on initial load):

```
avatar: 0.05, Saved Varieties: 0.10, My Trip Reports: 0.15,
Saved Substances: 0.20, Saved Services: 0.25, My Reviews: 0.25,
Settings: 0.30, Info/Crisis/About: no animateIn
```

---

## P2 — Polish / Minor Quality

---

### P2-1: Quick Link buttons in `HomeView` have no haptic feedback

**File:** `TripTalk/Views/Home/HomeView.swift:231–258`

The four circular quick-link buttons (`Varieties`, `Services`, `Safety`, `Community`) produce no haptic on tap. Every other primary tap in the app provides feedback (`ReviewsFeedView` filter chips → `Haptics.selection()`, bookmark buttons → `Haptics.medium()`, submit → `Haptics.success()`).

**Fix:** Add `Haptics.selection()` as the first line inside each `quickLink` button's `action` closure.

---

### P2-2: `SubstanceTypePill` filter taps in `CatalogListView` have no haptic

**File:** `TripTalk/Views/Catalog/CatalogListView.swift:131`

`SubstanceTypePill` invokes its `action` closure with no haptic. Compare to `ReviewsFeedView.swift:34,37` where filter tag taps call `Haptics.selection()`.

**Fix:** Add `Haptics.selection()` as the first statement inside `SubstanceTypePill.action`.

---

### P2-3: `GeometryReader` inside `IntensityBar` adds extra layout passes in list context

**File:** `TripTalk/Views/Components/TripReportCard.swift:113–126`

Each `TripReportCard` contains 3 `IntensityBar` components, each using a `GeometryReader` inside a `.frame(height: 6)` to compute bar fill width. `TripReportCard` appears in `HomeView` (3 cards) and inside `StrainDetailView`. Three `GeometryReader` instances per card trigger an extra layout pass per card. For `HomeView`'s 3 hardcoded cards this is negligible; if the pattern scales to a `LazyVStack` in future this becomes meaningful.

**Fix:** Replace the fill-width `GeometryReader` with `containerRelativeFrame` (iOS 17):

```swift
// IntensityBar body — replace GeometryReader with:
ZStack(alignment: .leading) {
    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
    RoundedRectangle(cornerRadius: 3)
        .fill(color)
        .containerRelativeFrame(.horizontal) { width, _ in
            width * CGFloat(value) / 5.0
        }
}
.frame(height: 6)
```

---

### P2-4: `LaunchScreenView` uses `.easeIn` for a fade-in — perceptually slow start

**File:** `TripTalk/Views/Launch/LaunchScreenView.swift:47`

```swift
withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
```

`.easeIn` accelerates into the end value. For a fade-in from invisible, this means the logo is imperceptible for the first ~40% of the duration before becoming visible. The splash reads as sluggish. The `TripTalkApp` dismiss already correctly uses `.easeOut` — matching the reveal to the same curve makes the full sequence symmetric.

**Fix:** Change to `.easeOut(duration: 0.5)`.

---

### P2-5: `InteractiveRatingStars` specifies the spring animation twice

**File:** `TripTalk/Views/Components/RatingStars.swift:38–42`

```swift
.animation(.spring(response: 0.2, dampingFraction: 0.6), value: rating)  // view-level
.onTapGesture {
    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {  // redundant
        rating = index
    }
}
```

The `withAnimation` sets the transaction; the view-level `.animation` modifier immediately overrides that transaction. They currently agree, so there's no visible issue — but if they ever diverge, behavior is undefined.

**Fix:** Remove `withAnimation(...)` from the tap gesture. Keep only the view-level `.animation` modifier.

---

### P2-6: `ServiceDetailView` hero missing `.visualEffect` parallax — inconsistent with other detail views

**File:** `TripTalk/Views/Services/ServiceDetailView.swift:13–46`

`StrainDetailView:237` and `SubstanceDetailView:48` both apply:

```swift
.visualEffect { content, proxy in
    content.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3))
}
```

`ServiceDetailView`'s structurally identical hero `ZStack` lacks this modifier. The three detail views feel inconsistent in scroll behavior.

**Fix:** Add the identical `.visualEffect` modifier to `ServiceDetailView`'s hero `ZStack` after `.ignoresSafeArea(edges: .top)`.

---

### P2-7: `ShimmerModifier` has no reduce motion guard

**File:** `TripTalk/Views/Components/ThemeColors.swift:158–176`

`ShimmerModifier` runs `.repeatForever(autoreverses: false)` with no reduce motion check. It is currently unused, but if `.shimmer()` is applied to any loading skeleton in the future it will violate Reduce Motion expectations and keep a `LinearGradient` animating indefinitely.

**Fix:** Add the guard before any usage appears:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

func body(content: Content) -> some View {
    if reduceMotion { return AnyView(content) }
    return AnyView(
        content
            .overlay(...)
            // ... rest of shimmer implementation
    )
}
```

---

### P2-8: `OnboardingView` page swipe has no reduce motion consideration

**File:** `TripTalk/Views/Onboarding/OnboardingView.swift:110`

`TabView` with `.tabViewStyle(.page)` uses a horizontal swipe animation between pages. iOS does not disable this in response to the SwiftUI `\.accessibilityReduceMotion` environment value.

**Fix:** Read reduce motion and switch to `.automatic` (crossfade) when enabled:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

TabView(selection: $currentPage) { ... }
    .tabViewStyle(reduceMotion ? .automatic : .page(indexDisplayMode: .always))
```

Replace the swipe dots with a custom step indicator when using `.automatic` style.

---

## Summary Table

| ID | Priority | File | Line(s) | Category |
|---|---|---|---|---|
| P0-1 | **P0** | `ThemeColors.swift` | 111–122 | `AnimatedAppearance` re-triggers in `LazyVStack` |
| P0-2 | **P0** | `ThemeColors.swift` | 126–140 | `PressEffect` locks `isPressed` during scroll |
| P1-1 | P1 | `WriteReviewView.swift`, `WriteTripReportView.swift` | 154–155, 257–258 | Success overlay transition silently skipped |
| P1-2 | P1 | `ExploreView.swift` | 54–108 | Double nested `.animateIn()` compounds opacity |
| P1-3 | P1 | `StrainDetailView.swift` | 370 | Bar fill animation ignores reduce motion |
| P1-4 | P1 | `StrainDetailView.swift`, `SubstanceDetailView.swift`, `ServiceDetailView.swift` | 175–179, 198–203, 141–146 | `DispatchQueue` timer; no cancel; no reduce motion |
| P1-5 | P1 | `ContentView.swift` | 49 | `.animation` on `TabView` causes crossfade jank |
| P1-6 | P1 | `AgeGateView.swift` | 52 | `withAnimation` missing reduce motion guard |
| P1-7 | P1 | `TripTalkApp.swift` | 22–24, 39–41 | Launch/onboarding transitions ignore reduce motion |
| P1-8 | P1 | `ProfileView.swift` | 41–277 | Non-monotonic stagger; 5 sections pile at t=0.4s |
| P2-1 | P2 | `HomeView.swift` | 231–258 | Missing haptic on Quick Link buttons |
| P2-2 | P2 | `CatalogListView.swift` | 131 | Missing haptic on `SubstanceTypePill` |
| P2-3 | P2 | `TripReportCard.swift` | 113–126 | `GeometryReader` per intensity bar in list cells |
| P2-4 | P2 | `LaunchScreenView.swift` | 47 | `.easeIn` for fade-in is perceptually slow |
| P2-5 | P2 | `RatingStars.swift` | 38–42 | Redundant double animation specification |
| P2-6 | P2 | `ServiceDetailView.swift` | 13–46 | Missing `.visualEffect` parallax on hero |
| P2-7 | P2 | `ThemeColors.swift` | 158–176 | `ShimmerModifier` has no reduce motion guard |
| P2-8 | P2 | `OnboardingView.swift` | 110 | Page swipe not reduce-motion aware |

---

## What's Working Well

- `AnimatedAppearance` correctly reads `accessibilityReduceMotion` and suppresses the y-offset on reduce motion. The `.easeOut(duration: 0.4).delay(delay)` curve is appropriate.
- `PressEffect` correctly gates the scale effect behind `reduceMotion`. The 0.97 scale is subtle and correct.
- `LaunchScreenView` is a clean reference implementation for the reduce motion pattern.
- `Haptics` enum is well-structured. `selection()`, `medium()`, and `success()` are placed at semantically appropriate moments across the app.
- Delay capping at `min(delay, 0.3)` in `CatalogListView`, `ReviewsFeedView`, and `ServicesListView` prevents absurdly long waits for late list items — the right instinct.
- `.visualEffect` parallax on hero images in `StrainDetailView` and `SubstanceDetailView` is implemented correctly using the iOS 17 native API.
- `InteractiveRatingStars` spring + haptic feedback feels tight and responsive.
- All sheets use `.presentationDetents` and `.presentationBackground` consistently, deferring to system-managed sheet animation.
