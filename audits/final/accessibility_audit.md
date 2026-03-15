# TripTalk Accessibility Audit — WCAG 2.1 AA & iOS HIG
**Auditor:** Senior Accessibility Engineer
**Date:** 2026-03-15
**Scope:** All Swift files in `TripTalk/Views/` and `TripTalk/Views/Components/`
**Standard:** WCAG 2.1 Level AA + Apple Human Interface Guidelines

---

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| P0 — Critical (blocks VoiceOver users entirely) | 5 | ❌ Must fix before ship |
| P1 — High (significantly degrades experience) | 13 | ⚠️ Fix before ship |
| P2 — Medium (polish, WCAG advisory) | 14 | 🔶 Fix in next sprint |

---

## P0 — Critical

These issues make core features completely inaccessible to VoiceOver users.

---

### P0-1 · ReviewCard — Helpful/Flag/Share buttons swallowed by `.combine`
**File:** `Views/Components/ReviewCard.swift:84–85`

**What's wrong:** `.accessibilityElement(children: .combine)` at line 84, combined with an explicit `.accessibilityLabel` at line 85, collapses the entire card into a single VoiceOver element. The three interactive children — the "Helpful" `Button`, "Flag" `Button`, and `ShareLink` — are permanently hidden. VoiceOver users cannot mark reviews helpful, report them, or share them. These are the primary social interaction actions.

Additionally, the combined label omits `review.body` entirely — the actual review text is inaccessible.

**Fix:** Use `.accessibilityCustomActions` instead:
```swift
// Remove:
// .accessibilityElement(children: .combine)
// .accessibilityLabel(...)

// Add to outer HStack:
.accessibilityElement(children: .ignore)
.accessibilityLabel(
    "\(review.authorName), \"\(review.title)\". \(review.body). " +
    "Rated \(review.rating) out of 5 stars. " +
    "\(review.helpfulCount) people found this helpful."
)
.accessibilityCustomActions([
    AccessibilityCustomAction("Mark helpful") { onHelpful?(); return true },
    AccessibilityCustomAction("Flag review") { onReport?(); return true }
])
```

---

### P0-2 · TripReportCard — Share button swallowed by `.combine`
**File:** `Views/Components/TripReportCard.swift:94–95`

**What's wrong:** Same pattern as P0-1. `.accessibilityElement(children: .combine)` hides the `ShareLink` button inside. The combined label also omits intensity data (Visual/Body/Emotional), leaving the most quantitative content of trip reports inaccessible.

**Fix:**
```swift
.accessibilityElement(children: .ignore)
.accessibilityLabel(
    "\(report.authorName)'s trip report" +
    (!strainName.isEmpty ? " on \(strainName)" : "") +
    ", rated \(report.rating) out of 5 stars" +
    ", \(report.setting.rawValue) setting" +
    ", visual intensity \(report.visualIntensity) of 5" +
    ", body intensity \(report.bodyIntensity) of 5" +
    ", emotional intensity \(report.emotionalIntensity) of 5" +
    (report.wouldRepeat ? ", would repeat" : "") +
    ". \(report.highlights)"
)
// Expose ShareLink outside the ignore scope, or use a custom action:
.accessibilityCustomActions([
    AccessibilityCustomAction("Share trip report") { /* trigger share */ return true }
])
```

---

### P0-3 · PotencyDots — Zero accessibility annotation on the component
**File:** `Views/Components/PotencyDots.swift:9–18`

**What's wrong:** `PotencyDots` has no accessibility modifiers of any kind. VoiceOver focuses each individual 3–10pt circle, producing an incoherent stream of unlabeled shape elements. While several call sites add their own labels via `.accessibilityElement(children: .ignore).accessibilityLabel(...)`, the component has no fallback — any future use that omits a call-site override will silently expose raw circles.

**Fix:** Add a self-describing default at the component level:
```swift
var body: some View {
    HStack(spacing: 3) { ... }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Potency: level \(level) of \(maxLevel)")
}
```
Call sites that need richer text (e.g., "Potency: Medium, level 2 of 4") can override with `.accessibilityLabel(...)` after the view.

---

### P0-4 · TagChip with `.onTapGesture` — Missing `.isButton` trait; appears static to VoiceOver
**Files:**
- `Views/Reviews/WriteTripReportView.swift:58–63` (ExperienceType chips)
- `Views/Reviews/WriteTripReportView.swift:113–120` (MoodTag chips)
- `Views/Reviews/WriteReviewView.swift:50–56` (EffectTag chips)
- `Views/Reviews/ReviewsFeedView.swift:33–38` (filter chips)

**What's wrong:** `TagChip` has `.accessibilityLabel` and `.accessibilityAddTraits(isSelected ? .isSelected : [])` but never adds `.isButton`. When these chips are activated by `.onTapGesture`, VoiceOver announces them as static text — users have no indication they are interactive. The `.isSelected` trait is also meaningless without the `.isButton` trait establishing the element as actionable.

**Fix:** Add `.isButton` unconditionally in `TagChip.swift`:
```swift
// In TagChip.swift — replace:
.accessibilityAddTraits(isSelected ? .isSelected : [])
// with:
.accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
```
At call sites using `.onTapGesture`, also add an `accessibilityHint`:
```swift
TagChip(text: type.rawValue, isSelected: selectedExperienceTypes.contains(type))
    .onTapGesture { ... }
    .accessibilityHint(selectedExperienceTypes.contains(type) ? "Double-tap to deselect" : "Double-tap to select")
```

---

### P0-5 · StrainDetailView statsBar — "Level", "Onset", "Duration" cells unlabeled
**File:** `Views/Catalog/StrainDetailView.swift:261–308`

**What's wrong:** The statsBar contains four stat cells. Only the "Potency" cell (lines 244–257) is correctly wrapped with `.accessibilityElement(children: .ignore)` and `.accessibilityLabel`. The other three — "Level" (difficulty), "Onset", and "Duration" — have no such wrapper. VoiceOver reads them as a confusing stream: "Level", then a raw SF Symbol name like "exclamationmark.circle.fill", then "Intermediate" — three separate focus stops with no semantic connection.

**Fix:**
```swift
// "Level" cell (after line 273):
.accessibilityElement(children: .ignore)
.accessibilityLabel("Experience level: \(strain.difficulty.rawValue)")

// "Onset" cell (after line 289):
.accessibilityElement(children: .ignore)
.accessibilityLabel("Onset: \(strain.onset)")

// "Duration" cell (after line 307):
.accessibilityElement(children: .ignore)
.accessibilityLabel("Duration: \(strain.duration)")
```

---

## P1 — High

---

### P1-1 · ShimmerModifier — Infinite animation with no `reduceMotion` check
**File:** `Views/Components/ThemeColors.swift:158–176`

**What's wrong:** `ShimmerModifier` uses `.animation(.linear(duration: 1.2).repeatForever(autoreverses: false))` with no `@Environment(\.accessibilityReduceMotion)` guard. This loops forever regardless of the system Reduce Motion setting. The existing `AnimatedAppearance` and `PressEffect` in the same file correctly check `reduceMotion` — `ShimmerModifier` is the sole exception. WCAG 2.3.3 and Apple's guidelines require animation to stop when Reduce Motion is enabled.

**Fix:**
```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if !reduceMotion {
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.08), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: phase)
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
                    }
                }
            )
            .clipped()
            .onAppear { if !reduceMotion { phase = 300 } }
    }
}
```

---

### P1-2 · Parallax `visualEffect` scroll — No `reduceMotion` check
**Files:** `Views/Catalog/StrainDetailView.swift:237–239`, `Views/Catalog/SubstanceDetailView.swift:48–50`

**What's wrong:** Both hero sections apply `.visualEffect { content, proxy in content.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3)) }` for parallax. This is continuous motion synchronized with scroll, which is not gated on `accessibilityReduceMotion`. Vestibular-sensitive users will experience discomfort on every scroll interaction.

**Fix:**
```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// In heroSection:
let heroImage = Image(strain.heroImageName)
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(width: geo.size.width, height: 260)
    .clipped()

if reduceMotion {
    heroImage
} else {
    heroImage.visualEffect { content, proxy in
        content.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3))
    }
}
```

---

### P1-3 · ttTertiary color — Fails WCAG AA contrast on glass card surfaces
**File:** `Views/Components/ThemeColors.swift:10`

**What's wrong:** `ttTertiary = Color(red: 0.5, green: 0.54, blue: 0.52)` (≈ `#808A85`) is used for timestamps, review dates, "N reports" counts, and disclaimer captions. Against the glass card background (`.ultraThinMaterial` + `white.opacity(0.07)` over the dark gradient ≈ `#1A2B38`), the contrast ratio is approximately **3.9:1** — below the WCAG AA minimum of **4.5:1** for normal-weight text below 18pt. Affected: `ReviewCard.swift:28`, `TripReportCard.swift:28`, `StrainCard.swift:64`, `ServicesListView.swift:31`, and all detail views.

**Fix:** Increase luminance slightly:
```swift
// Current: (0.5, 0.54, 0.52) ≈ 3.9:1 on cards
// Fix: (0.62, 0.66, 0.64) ≈ 4.7:1 on cards
static let ttTertiary = Color(red: 0.62, green: 0.66, blue: 0.64)
```
Verify with a real-device contrast tool against the rendered background.

---

### P1-4 · Bookmark buttons — No `accessibilityLabel` or state description
**Files:**
- `Views/Catalog/StrainDetailView.swift:172–186`
- `Views/Catalog/SubstanceDetailView.swift:195–209`
- `Views/Services/ServiceDetailView.swift:138–153`

**What's wrong:** All bookmark buttons render `Image(systemName: savedIDs.contains(id) ? "bookmark.fill" : "bookmark")` with no `.accessibilityLabel`. VoiceOver reads "bookmark" or "bookmark fill" — the user can't determine what is being saved, nor the current state. There is also no `.accessibilityAddTraits(.isSelected)` when bookmarked, and no announcement on state change.

**Fix (StrainDetailView example):**
```swift
Button { ... } label: {
    Image(systemName: appState.savedStrainIDs.contains(strain.id) ? "bookmark.fill" : "bookmark")
        .foregroundStyle(Color.ttPrimary)
        .scaleEffect(bookmarkBounce ? 1.3 : 1.0)
}
.accessibilityLabel(appState.savedStrainIDs.contains(strain.id)
    ? "Remove \(strain.name) from saved"
    : "Save \(strain.name)")
.accessibilityAddTraits(appState.savedStrainIDs.contains(strain.id) ? .isSelected : [])
```
Apply the same pattern in the Substance and Service detail views.

---

### P1-5 · Share and Filter toolbar buttons — No `accessibilityLabel`
**Files:**
- Share: `StrainDetailView.swift:168–170`, `SubstanceDetailView.swift:191–193`, `ServiceDetailView.swift:134–137`
- Filter: `CatalogListView.swift:104–110`, `ServicesListView.swift:70–77`

**What's wrong:** Share buttons contain only `Image(systemName: "square.and.arrow.up")`. VoiceOver reads the raw SF Symbol description. Filter buttons contain only `Image(systemName: "line.3.horizontal.decrease.circle")` — VoiceOver reads something like "line 3 horizontal decrease circle, button," which is meaningless.

**Fix:**
```swift
// Share (StrainDetailView):
ShareLink(item: strainShareText) {
    Image(systemName: "square.and.arrow.up").foregroundStyle(Color.ttPrimary)
}
.accessibilityLabel("Share \(strain.name)")

// Filter (CatalogListView):
Button { showFilter = true } label: {
    Image(systemName: "line.3.horizontal.decrease.circle").foregroundStyle(Color.ttPrimary)
}
.accessibilityLabel("Filter catalog")
.accessibilityHint("Opens filter options")

// Filter (ServicesListView):
.accessibilityLabel("Filter services")
.accessibilityHint("Opens filter options")
```

---

### P1-6 · Systematic missing `.isHeader` trait on all section headings
**Files:** Every view with section titles:
- `Views/Home/HomeView.swift:36–37, 132–133, 161–162`
- `Views/Explore/ExploreView.swift:154–157` (the `sectionView` helper title)
- `Views/Services/ServiceDetailView.swift:64–66, 77–79, 96–98`
- `Views/Catalog/SubstanceDetailView.swift:71–73, 83–85, 99–101, 122–124, 140–142`
- `Views/Catalog/StrainDetailView.swift:18–19, 31–32, 45–46, 59–60, 71–73, 104–106, 319`
- `Views/Profile/ProfileView.swift:315–319` (the `profileSection` helper title)

**What's wrong:** VoiceOver's rotor "Headings" navigation is one of the most common strategies for blind users on long pages. None of the section title `Text` elements carry `.accessibilityAddTraits(.isHeader)`, so users must swipe through every element individually to navigate between sections.

**Fix (representative — apply everywhere):**
```swift
Text("About")
    .font(.system(.title3, design: .serif, weight: .bold))
    .foregroundStyle(Color.ttPrimary)
    .accessibilityAddTraits(.isHeader)
```
The highest-leverage fix is to add the trait inside the `sectionView` helper in `ExploreView` and `profileSection` in `ProfileView` — one change propagates to all call sites.

---

### P1-7 · Success overlays — No VoiceOver announcement; transition not `reduceMotion`-gated
**Files:** `Views/Reviews/WriteReviewView.swift:113–138`, `Views/Reviews/WriteTripReportView.swift:208–233`

**What's wrong:** After submission, a success overlay fades/scales in then auto-dismisses in 1.5 seconds. VoiceOver focus remains on the now-disabled submit button and no accessibility notification is posted — VoiceOver users receive zero feedback that submission succeeded. The `.transition(.scale.combined(with: .opacity))` + `.animation(.spring(...))` is also not gated on `reduceMotion`.

**Fix:**
```swift
// In submitReport() / submitReview():
UIAccessibility.post(
    notification: .announcement,
    argument: "Trip report submitted. Thank you for sharing your experience."
)

// On the overlay ZStack:
@Environment(\.accessibilityReduceMotion) private var reduceMotion
// ...
.transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
.animation(
    reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.7),
    value: showSuccessOverlay
)
```

---

### P1-8 · OnboardingView — Background images not hidden; page icons not hidden; title not `.isHeader`
**File:** `Views/Onboarding/OnboardingView.swift`

**What's wrong:**
1. `Image(page.backgroundImage)` (line 20) is a full-screen decorative photo with no `.accessibilityHidden(true)`. VoiceOver encounters it before the page content.
2. `Image(systemName: page.icon)` (line 51) is decorative — the title and subtitle convey all meaning. Not hidden.
3. `Text(page.title)` (line 62) is the primary heading of each page but has no `.isHeader` trait.
4. No per-page announcement of position (e.g., "Page 1 of 3"). VoiceOver users don't know there are more pages or when they've reached the last one with the "Get Started" button.

**Fix:**
```swift
// Background image:
Image(page.backgroundImage)
    .resizable()
    .accessibilityHidden(true)

// Page icon:
Image(systemName: page.icon)
    .accessibilityHidden(true)

// Page title:
Text(page.title)
    .font(.system(.largeTitle, design: .serif, weight: .bold))
    .accessibilityAddTraits(.isHeader)

// Per-page container — announce page position:
ZStack { ... }
    .tag(index)
    .accessibilityLabel("Page \(index + 1) of \(pages.count): \(page.title). \(page.subtitle)")
    .accessibilityElement(children: .contain)
```

---

### P1-9 · ProfileView Jurisdiction Picker — Empty label
**File:** `Views/Profile/ProfileView.swift:165`

**What's wrong:** `Picker("", selection: $state.selectedJurisdiction)` uses an empty string as the label. VoiceOver announces: *"[blank], popup button"*. Users don't know what this control does until after they open it.

**Fix:**
```swift
Picker("Jurisdiction", selection: $state.selectedJurisdiction) {
    ForEach(Jurisdiction.allCases) { j in
        Text(j.rawValue).tag(j)
    }
}
```

---

### P1-10 · Custom TextEditor placeholder — Duplicated in accessibility tree
**Files:** `Views/Reviews/WriteTripReportView.swift:126–136, 140–150`, `Views/Reviews/WriteReviewView.swift:35–44`

**What's wrong:** The `ZStack` pattern places a visible `Text(placeholder)` behind a `TextEditor`. VoiceOver announces the placeholder `Text` as a separate static element, then announces the `TextEditor` — effectively reading the same placeholder text twice and confusing users about which element is the editable field.

**Fix:**
```swift
ZStack(alignment: .topLeading) {
    if field.isEmpty {
        Text("Describe the highlights...")
            .foregroundStyle(Color.ttSecondary.opacity(0.5))
            .padding(.top, 8)
            .accessibilityHidden(true)  // TextEditor already describes its empty state
    }
    TextEditor(text: $field)
        .foregroundStyle(Color.ttPrimary)
        .frame(minHeight: 80)
        .accessibilityLabel("Highlights")  // Add explicit label since placeholder is hidden
}
```

---

### P1-11 · AgeGateView — Decorative elements in accessibility tree; title missing `.isHeader`
**File:** `Views/AgeGate/AgeGateView.swift:14–35`

**What's wrong:**
- The decorative `Circle()` glow (lines 14–25) and `Image(systemName: "leaf.circle.fill")` (line 27) appear in the accessibility tree with no labels. VoiceOver focuses each individually.
- `Text("TripTalk")` (line 32) is the screen's primary heading but has no `.isHeader` trait.
- The most important statement — "TripTalk is for adults 21 and older." (line 45) — has `.opacity(0.6)` applied at the view level. While this passes contrast at headline size, the `.opacity` modifier can interact with glass backgrounds unpredictably on older displays.

**Fix:**
```swift
// Wrap decorative ZStack:
ZStack { Circle()... Image(systemName: "leaf.circle.fill")... }
    .accessibilityHidden(true)

// Heading:
Text("TripTalk")
    .accessibilityAddTraits(.isHeader)

// Age restriction text — use foreground opacity instead of view opacity:
Text("TripTalk is for adults 21 and older.")
    .font(.headline)
    .foregroundStyle(Color.ttPrimary.opacity(0.7))
    // Remove: .opacity(0.6)
```

---

### P1-12 · EmptyStateView — Decorative images exposed; title not `.isHeader`
**File:** `Views/Components/EmptyStateView.swift:22–56`

**What's wrong:**
- `Image(imageName)` (line 23): atmospheric illustration with no `accessibilityHidden(true)` — VoiceOver focuses it and reads nothing useful.
- `Image(systemName: icon)` (line 42): decorative icon — the `title` and `subtitle` already provide full context.
- `Text(title)` (line 54): the primary heading of each empty state, but has no `.isHeader` trait.

**Fix:**
```swift
Image(imageName)
    .resizable()
    ...
    .accessibilityHidden(true)

Image(systemName: icon)
    ...
    .accessibilityHidden(true)

Text(title)
    .font(.system(.title3, design: .serif, weight: .bold))
    .foregroundStyle(Color.ttPrimary)
    .accessibilityAddTraits(.isHeader)
```

---

### P1-13 · Crisis Resource `tel:` links — No hint that a phone call will be placed
**File:** `Views/Profile/ProfileView.swift:225–261`

**What's wrong:** `Link(destination: URL(string: "tel:988")!)` and the Fireside Project link both immediately dial a phone number on activation. VoiceOver announces only the visible label text ("988 Suicide & Crisis Lifeline", "Fireside Project"). For safety-critical resources, users must know what physical action will occur before they activate.

**Fix:**
```swift
Link(destination: URL(string: "tel:988")!) { HStack { ... } }
    .accessibilityHint("Double-tap to call 988")

Link(destination: URL(string: "tel:6232737654")!) { HStack { ... } }
    .accessibilityHint("Double-tap to call the Fireside Project psychedelic peer support line")
```

---

## P2 — Medium

---

### P2-1 · TagChip minimum tap target — 28pt is below the 44pt HIG minimum
**File:** `Views/Components/TagChip.swift:18`

`.frame(minHeight: 28)` produces a 28pt minimum interactive height for all chips used with `.onTapGesture`. Apple HIG requires 44×44pt minimum. Users with motor impairments may routinely miss the target.

**Fix:** Expand the hit area without changing visual size:
```swift
.frame(minHeight: 28)
.contentShape(Rectangle().inset(by: -8))  // expands hit area to ~44pt without visual change
```
Or increase `minHeight` to 44 and adjust internal padding to maintain the compact look.

---

### P2-2 · `InteractiveRatingStars` — Spring animation not `reduceMotion`-gated
**File:** `Views/Components/RatingStars.swift:37–41`

`.scaleEffect` driven by `.animation(.spring(...), value: rating)` and the `withAnimation(.spring(...))` in the tap handler are not conditioned on `accessibilityReduceMotion`. Add `@Environment(\.accessibilityReduceMotion)` and conditionally skip the animation.

---

### P2-3 · `IntensityChartRow` bar-fill animation not `reduceMotion`-gated
**File:** `Views/Catalog/StrainDetailView.swift:370`

`.animation(.easeOut(duration: 0.6), value: value)` on the progress bar fill. Should check `accessibilityReduceMotion`.

---

### P2-4 · HomeView "Learn more" NavigationLink — Vague label
**File:** `Views/Home/HomeView.swift:88–98`

`Text("Learn more")` with no `accessibilityLabel`. VoiceOver announces "Learn more, link" with no context about what is being linked. After focus has moved away from the featured variety name, this is unintelligible.

**Fix:**
```swift
NavigationLink(value: featured) { Text("Learn more") ... }
.accessibilityLabel("Learn more about \(featured.name)")
```

---

### P2-5 · HomeView "Safety" quick link — No hint about alert behavior
**File:** `Views/Home/HomeView.swift:148–150`

The "Safety" quick link triggers an in-app `Alert` with crisis phone numbers, while the other quick links navigate to tabs. The different behavior isn't communicated to VoiceOver users.

**Fix:**
```swift
quickLink(icon: "shield.fill", label: "Safety", color: .orange) { showSafetyAlert = true }
    .accessibilityHint("Shows crisis support resources and phone numbers")
```

---

### P2-6 · Search bar magnifying glass icons not hidden
**Files:** `CatalogListView.swift:15`, `ExploreView.swift:13`, `ServicesListView.swift:14`

Decorative `Image(systemName: "magnifyingglass")` in custom search bars. The `TextField` placeholder already communicates the search context — the icon is pure visual chrome.

**Fix:**
```swift
Image(systemName: "magnifyingglass")
    .foregroundStyle(Color.ttSecondary)
    .accessibilityHidden(true)
```

---

### P2-7 · Decorative icons in content lists not hidden
**Files:**
- `Views/Services/ServiceDetailView.swift:83` — `checkmark.circle.fill` in offerings (text follows)
- `Views/Catalog/SubstanceDetailView.swift:105` — `exclamationmark.triangle.fill` in safety notes (text follows)
- `Views/Services/ServiceDetailView.swift:21–23` — large hero icon
- `Views/Catalog/SubstanceDetailView.swift:35–37` — large hero icon

All are purely visual. VoiceOver reads raw symbol names before the actual text content.

**Fix:** Add `.accessibilityHidden(true)` to each.

---

### P2-8 · LaunchScreenView — Decorative icon not hidden
**File:** `Views/Launch/LaunchScreenView.swift:24–33`

`Image(systemName: "leaf.circle.fill")` is decorative. The whole screen should read as a single announcement.

**Fix:**
```swift
Image(systemName: "leaf.circle.fill")
    .accessibilityHidden(true)

// Wrap the VStack as a combined announcement:
VStack(spacing: 20) { ... }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("TripTalk")
```

---

### P2-9 · MiniStrainCard combined label — Omits potency and substance type
**File:** `Views/Explore/ExploreView.swift:239–240`

`.accessibilityLabel("\(strain.name), rated \(String(format: "%.1f", strain.averageRating)) stars")` omits substance type and potency. The `PotencyDots` inside the card has its own label, but the parent's explicit `.combine` label overrides it.

**Fix:**
```swift
.accessibilityLabel(
    "\(strain.name), \(strain.parentSubstance.rawValue), " +
    "\(strain.potency.rawValue) potency, " +
    "rated \(String(format: "%.1f", strain.averageRating)) stars"
)
```

---

### P2-10 · ProfileView avatar — Icon and glow in accessibility tree
**File:** `Views/Profile/ProfileView.swift:12–30`

`Image(systemName: "person.circle.fill")` and the surrounding `Circle()` glow have no labels and are not hidden. The glow `Circle` is entirely decorative; the icon conveys generic "profile" context already provided by the navigation title.

**Fix:**
```swift
ZStack {
    Circle().fill(RadialGradient(...))
        .accessibilityHidden(true)
    Image(systemName: "person.circle.fill")
        .accessibilityHidden(true)  // "Profile" is in the nav title
}
```

---

### P2-11 · Decorative `chevron.right` images not hidden in ProfileView rows
**File:** `Views/Profile/ProfileView.swift:58, 103, 128, 239, 257`

`Image(systemName: "chevron.right")` in `NavigationLink` rows. VoiceOver reads "chevron right" after each row label. SwiftUI's `NavigationLink` already announces the "link" trait — the chevron is visual decoration.

**Fix:** Add `.accessibilityHidden(true)` to each chevron.

---

### P2-12 · StrainDetailView "See all N reports" button — Empty action
**File:** `Views/Catalog/StrainDetailView.swift:123–130`

Button has an empty action `{}`. VoiceOver announces a button that does nothing when activated.

**Fix:** Implement the navigation to a full reports list, or remove the button entirely until the feature is implemented.

---

### P2-13 · Community photo placeholders — Unlabeled icons
**File:** `Views/Catalog/StrainDetailView.swift:94–96`

`Image(systemName: "photo")` overlaid on placeholder tiles. VoiceOver reads "photo" for each of up to 6 tiles with no context.

**Fix:**
```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 8) {
        ForEach(0..<min(6, strain.communityPhotoCount), id: \.self) { _ in
            RoundedRectangle(cornerRadius: 10)
                ...
                .overlay { Image(systemName: "photo").accessibilityHidden(true) }
        }
    }
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("\(strain.communityPhotoCount) community photos")
```

---

### P2-14 · PotencyDots — Color is the only differentiator for active vs. inactive dots (WCAG 1.4.1)
**File:** `Views/Components/PotencyDots.swift:12–15`

Active dots use `activeColor`; inactive dots use `Color.white.opacity(0.15)`. Color is the sole visual means of conveying potency level. WCAG 1.4.1 (Use of Color, Level A) requires a non-color differentiator.

**Fix:** Add a size or opacity difference:
```swift
Circle()
    .fill(i <= level ? activeColor : Color.white.opacity(0.15))
    .frame(
        width: i <= level ? dotSize : dotSize * 0.75,
        height: i <= level ? dotSize : dotSize * 0.75
    )
```
This makes active dots visibly larger than inactive ones regardless of color perception.

---

## Confirmed Accessible — No Action Required

The following patterns were reviewed and are correctly implemented:

| Element | Pattern | Status |
|---------|---------|--------|
| `RatingStars` (display) | `.accessibilityElement(children: .ignore)` + `.accessibilityLabel("X out of Y stars")` | ✅ |
| `InteractiveRatingStars` | `.accessibilityAdjustableAction` increment/decrement with haptics | ✅ |
| `AnimatedAppearance` | `@Environment(\.accessibilityReduceMotion)` check | ✅ |
| `PressEffect` | `@Environment(\.accessibilityReduceMotion)` check | ✅ |
| `LaunchScreenView` fade-in | `@Environment(\.accessibilityReduceMotion)` check | ✅ |
| `ServiceCard` | `.accessibilityElement(children: .combine)` with rich label including verified status and distance | ✅ |
| `SubstanceCard` | `.accessibilityElement(children: .combine)` with name, category, rating | ✅ |
| `StrainCard` | `.accessibilityElement(children: .combine)` with name, substance, potency, rating, report count | ✅ |
| `IntensityChartRow` | `.accessibilityElement(children: .ignore)` + `.accessibilityLabel("X intensity: Y out of 5")` | ✅ |
| `IntensityBar` | `.accessibilityElement(children: .ignore)` + `.accessibilityLabel("X intensity: Y out of 5")` | ✅ |
| `TagChip` `.isSelected` trait | Present — pair with `.isButton` fix (P0-4) to complete | 🔧 |
| `GradientBackground` in `.background {}` | SwiftUI excludes `.background` modifier content from accessibility tree | ✅ |
| Native `Alert` buttons | Fully VoiceOver accessible; crisis resources in `AgeGateView` and `HomeView` alerts | ✅ |
| Form/Picker (native) | `CatalogFilterSheet`, `ServicesFilterSheet` use native SwiftUI pickers — screen reader handles | ✅ |
