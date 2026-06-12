# v3 Phase 1 — Xcode Required Steps

Branch: `v3/phase1-design-system`

---

## 1. Add Fraunces font files to the app target

The two variable font files are already on disk at:

```
TripTalk/Resources/Fonts/Fraunces-VariableFont.ttf
TripTalk/Resources/Fonts/Fraunces-Italic-VariableFont.ttf
```

**In Xcode:**
1. In the Project Navigator, select the `TripTalk/Resources/Fonts/` group.
2. If the files are not already showing with a target membership tick:
   - Select `Fraunces-VariableFont.ttf` → File Inspector (⌥⌘1) → Target Membership → tick **TripTalk**.
   - Repeat for `Fraunces-Italic-VariableFont.ttf`.
3. If the files are not in the Project Navigator at all, drag them from Finder into the group and tick **Copy items if needed** + **TripTalk** target.

---

## 2. UIAppFonts (Fonts provided by application)

`UIAppFonts` has been added directly to `TripTalk/Info.plist` (which is a supplemental plist merged at build time):

```xml
<key>UIAppFonts</key>
<array>
    <string>Fraunces-VariableFont.ttf</string>
    <string>Fraunces-Italic-VariableFont.ttf</string>
</array>
```

**Because `GENERATE_INFOPLIST_FILE = YES` is set in both build configurations**, Xcode merges `TripTalk/Info.plist` into the auto-generated plist. The `UIAppFonts` entries in that file should be picked up automatically. No additional Xcode GUI step is required for this item — but if the fonts are still not found at runtime, you can also add them via:

- Project → TripTalk target → **Info** tab → **Custom iOS Target Properties** → **+** → `Fonts provided by application` → add both `.ttf` filenames.

---

## 3. Verify font registration at runtime

In any view you can temporarily add:

```swift
// Debug: list registered Fraunces fonts
for family in UIFont.familyNames.sorted() {
    if family.contains("Fraunces") {
        print("Family: \(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            print("  \(name)")
        }
    }
}
```

`TTType.swift` uses `UIFont(name: "Fraunces", size: 17) != nil` to check availability and falls back to system serif automatically if the font is missing.

---

## 4. Files changed in this commit

### New files (must be in TripTalk target)
| File | Notes |
|------|-------|
| `TripTalk/DesignSystem/TTType.swift` | Typography token system — Fraunces + system scale |
| `TripTalk/DesignSystem/TTDesign.swift` | Spacing, radius, icon size tokens + `TTHairline` |

> **Xcode step:** If `TripTalk/DesignSystem/` did not previously exist in the project, drag the folder into the Project Navigator and confirm both files are added to the **TripTalk** target.

### Modified files (typography-only, no logic changes)
| File | Calls migrated |
|------|----------------|
| `TripTalk/Views/Home/HomeView.swift` | 6 |
| `TripTalk/Views/Launch/LaunchScreenView.swift` | 2 |
| `TripTalk/Views/AgeGate/AgeGateView.swift` | 2 |
| `TripTalk/Views/Onboarding/OnboardingView.swift` | 2 |
| `TripTalk/Views/Profile/ProfileView.swift` | 2 |
| `TripTalk/Views/Catalog/SubstanceDetailView.swift` | 7 |
| `TripTalk/Views/Catalog/StrainDetailView.swift` | 7 |
| `TripTalk/Views/Catalog/CatalogListView.swift` | 1 |
| `TripTalk/Views/Catalog/StrainCard.swift` | 1 |
| `TripTalk/Views/Reviews/WriteReviewView.swift` | 2 |
| `TripTalk/Views/Reviews/WriteTripReportView.swift` | 2 |
| `TripTalk/Views/Reviews/ReviewCard.swift` | 1 |
| `TripTalk/Views/Reviews/TripReportCard.swift` | 1 |
| `TripTalk/Views/Auth/SignInView.swift` | 1 |
| `TripTalk/Views/Auth/PasswordResetView.swift` | 1 |
| `TripTalk/Views/Services/ServiceDetailView.swift` | 5 |
| `TripTalk/Views/Services/ServiceCard.swift` | 1 |
| `TripTalk/Views/Explore/ExploreView.swift` | 3 |
| `TripTalk/Views/Components/CommunityPhotosView.swift` | 1 |
| `TripTalk/Views/Components/CrisisButton.swift` | 2 |
| `TripTalk/Views/Components/SubstanceCard.swift` | 1 |
| `TripTalk/Views/Components/AvatarPickerView.swift` | 1 |
| `TripTalk/Views/Components/EmptyStateView.swift` | 2 |
| `TripTalk/Info.plist` | Added `UIAppFonts` array |

**Not migrated (intentional):**
- `TripTalk/Views/Components/RatingStars.swift` — uses `.font(.system(size: size))` where `size` is a dynamic parameter passed by caller; no fixed TTType token applies.

---

## 5. Type mapping reference

| Old call | TTType token |
|----------|-------------|
| `.system(.largeTitle, design: .serif, weight: .bold)` — launch/app title | `.ttDisplay` |
| `.system(.largeTitle, design: .serif, weight: .bold)` — page heading | `.ttPageHead` |
| `.system(.title, design: .serif, weight: .bold)` | `.ttSection` |
| `.system(.title2, design: .serif, weight: .bold)` | `.ttCardTitle` |
| `.system(.title3, design: .serif, weight: .bold)` | `.ttCardTitle` |
| `.system(.headline, design: .serif)` | `.ttCardTitle` |
| `.system(.subheadline, design: .serif, weight: .semibold)` | `.ttMetadata` |
| `.system(.caption, design: .serif, weight: .bold/.semibold)` | `.ttEyebrow` or `.ttCaption` |
| `.system(size: 70–80)` — hero emoji | `.ttIconHero` (72 pt) |
| `.system(size: 56–60)` — large feature emoji | `.ttIconXL` (60 pt) |
| `.system(size: 50)` — medium-large emoji | `.ttIconLg50` (50 pt) |
| `.system(size: 48)` — medium-large emoji | `.ttIconLg` (48 pt) |
| `.system(size: 32)` — medium emoji | `.ttIconMd` (32 pt) |
| `.system(size: 16, weight: .semibold)` — icon in button | `.ttEyebrow` |
