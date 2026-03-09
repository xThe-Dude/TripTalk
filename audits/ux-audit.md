# TripTalk UX Audit Report
**Date:** 2026-03-09  
**Auditor:** Senior UX Developer (automated)  
**Scope:** All view files, app entry points, and user flows

---

## Summary

**Total findings: 28**  
- CRITICAL: 3  
- HIGH: 8  
- MEDIUM: 10  
- LOW: 7

---

## Findings

### [CRITICAL] Age Gate Has No Real Verification — Single Tap Bypass
**File:** Views/AgeGate/AgeGateView.swift:44-48  
**Issue:** The age gate is a single "I am 21+" button with no verification whatsoever. No date-of-birth entry, no confirmation dialog, nothing. Once tapped, `ageVerified` is permanently set to `true` via `@AppStorage` with no way to re-verify except the hidden reset button buried at the bottom of Profile.  
**Impact:** App Store reviewers may reject this. Provides zero meaningful age verification. A child can tap through in under 1 second.  
**Fix:** Add a date-of-birth picker or at minimum a two-step confirmation ("Are you sure? You must be 21+ to use this app"). Consider requiring DOB entry that calculates age server-side for compliance.

### [CRITICAL] No Data Loss Prevention on Form Dismissal
**File:** Views/Reviews/WriteTripReportView.swift:38 (Cancel button), Views/Reviews/WriteReviewView.swift:69 (Cancel button)  
**Issue:** Both the trip report form (10+ fields) and review form have a "Cancel" button that calls `dismiss()` immediately with no confirmation. If a user accidentally swipes down or taps Cancel after filling out a lengthy trip report, all data is lost instantly.  
**Impact:** Users lose potentially 10+ minutes of thoughtful writing. This is the #1 frustration driver for content-creation apps.  
**Fix:** Add `.interactiveDismissDisabled()` when any field has content. Show a confirmation alert on Cancel: "Discard report? You'll lose your changes."

### [CRITICAL] Quick Links on Home Are Non-Functional Decorations
**File:** Views/Home/HomeView.swift:112-120  
**Issue:** The "Quick Links" section (Varieties, Services, Safety, Community) renders four beautiful icons but they are plain `VStack`s with no tap actions, no `Button`, no `NavigationLink`. They look interactive but do absolutely nothing.  
**Impact:** Users tap these expecting navigation, nothing happens. Breaks trust and feels buggy. This is the most prominent CTA area on the home screen.  
**Fix:** Wire each quick link to the appropriate tab or view: Varieties → Catalog tab, Services → Services tab, Safety → a safety info view or web link, Community → Reviews feed. Use `Button` with tab switching or `NavigationLink`.

---

### [HIGH] Services Filter Sheet Offering Filter Not Applied
**File:** ViewModels/AppState.swift:73-79 (`filteredServices`), Views/Services/ServicesFilterSheet.swift  
**Issue:** `ServicesFilterSheet` lets users select an offering filter (`servicesOfferingFilter`), but `filteredServices` in AppState only filters by search text — it never checks `servicesOfferingFilter`. The filter UI exists but has zero effect.  
**Impact:** Users think they're filtering by offering but results don't change. Complete broken feature.  
**Fix:** Add offering filter logic to `filteredServices`:
```swift
if let offering = servicesOfferingFilter {
    result = result.filter { $0.offerings.contains(offering) }
}
```

### [HIGH] Explore Search and Catalog Search Are Independent and Confusing
**File:** Views/Explore/ExploreView.swift:11 (`@State private var searchText`), ViewModels/AppState.swift:32 (`catalogSearchText`)  
**Issue:** ExploreView has its own local `searchText` state, while CatalogListView uses `appState.catalogSearchText`. If a user searches in Explore, switches to Catalog tab, their search doesn't carry over. If they search in Catalog, go back to Explore, that search is also separate. Two independent search systems for overlapping content.  
**Impact:** Users expect search to be consistent. Searching "psilocybin" in Explore and then switching to Catalog shows no search — feels broken.  
**Fix:** Either unify search state in AppState, or make it clear these are different scopes (e.g., "Search everything" vs "Search catalog"). Consider a global search that spans all content types.

### [HIGH] Hardcoded Location "Fort Collins • 50mi" in Services
**File:** Views/Services/ServicesListView.swift:32  
**Issue:** The location text "Fort Collins • 50mi" is hardcoded. No location permission request, no way to change it, no indication it's a default.  
**Impact:** Users in other cities see "Fort Collins" and think the app is broken or not available in their area. Misleading distance information.  
**Fix:** At minimum, label it as "Default location" with a button to change. Ideally, request location permission and derive city/radius dynamically. If using mock data, at least let users set their city in Profile settings.

### [HIGH] No Empty State for Catalog/Services When Filters Return Zero Results
**File:** Views/Catalog/CatalogListView.swift:40-50, Views/Services/ServicesListView.swift:35-44  
**Issue:** Both CatalogListView and ServicesListView use `LazyVStack` with `ForEach` over filtered results, but neither shows an empty state when filters return no matches. The screen just shows a search bar and blank space.  
**Impact:** Users apply filters, see nothing, and don't know if it's loading, broken, or genuinely empty. No guidance on how to fix (e.g., "Try removing filters").  
**Fix:** Add `if appState.filteredStrains.isEmpty { EmptyStateView(...) }` with a "Reset Filters" action button. The `EmptyStateView` component already supports an action button.

### [HIGH] Trip Report Cards on Home/Explore Are Not Tappable
**File:** Views/Home/HomeView.swift:134-140, Views/Explore/ExploreView.swift:120-125  
**Issue:** `TripReportCard` is rendered in both Home and Explore views but is never wrapped in a `NavigationLink` or `Button`. Users see trip reports but cannot tap to read the full report or navigate to the associated strain.  
**Impact:** Dead-end content. Users see interesting reports but have no way to engage further. Breaks the browse → discover → deep-dive flow.  
**Fix:** Wrap each `TripReportCard` in a `NavigationLink` to either a full trip report detail view (which doesn't exist yet — see below) or at minimum to the associated strain's detail view.

### [HIGH] No Trip Report Detail View Exists
**File:** (missing)  
**Issue:** There is no `TripReportDetailView`. Trip reports are shown as cards with `lineLimit(3)` on highlights text, but there's no way to read the full report, see all moods, safety notes, intention, or experience types.  
**Impact:** The most valuable user-generated content in the app is permanently truncated to 3 lines. Users who write detailed reports can never have them fully read.  
**Fix:** Create a `TripReportDetailView` that shows all fields: full highlights text, safety notes, intention, all moods, experience types, intensity bars, setting, and the associated strain link.

### [HIGH] "See all X reports" Button Does Nothing
**File:** Views/Catalog/StrainDetailView.swift:159-164  
**Issue:** The "See all N reports" button has an empty action closure: `Button { } label: { ... }`. It literally does nothing on tap.  
**Impact:** Users with many reports for a strain can only see the first 3. The button that promises to show more is completely broken.  
**Fix:** Navigate to a filtered list view showing all trip reports for that strain, or expand the list in-place.

### [HIGH] Bookmark Feedback Is Only Visual — No Toast/Confirmation
**File:** Views/Catalog/StrainDetailView.swift:185-190, Views/Catalog/SubstanceDetailView.swift:128-133, Views/Services/ServiceDetailView.swift:115-120  
**Issue:** Bookmarking toggles the icon between `bookmark` and `bookmark.fill` and triggers `Haptics.medium()`, but there's no text confirmation. The icon change in the toolbar is subtle and easy to miss, especially for unbookmarking.  
**Impact:** Users aren't sure if they bookmarked or unbookmarked. No "Added to saved" or "Removed from saved" feedback.  
**Fix:** Add a brief toast/snackbar overlay: "Saved to profile ✓" / "Removed from saved". Even a temporary overlay at the bottom of the screen would suffice.

---

### [MEDIUM] Onboarding Has No Skip Button
**File:** Views/Onboarding/OnboardingView.swift  
**Issue:** The onboarding flow has 3 pages with a TabView page indicator. Only the last page has a "Get Started" button. There's no skip button on pages 1-2. Users must swipe through all pages or figure out they can swipe.  
**Impact:** Returning users who reinstall or impatient users are forced through 3 pages. No way to skip.  
**Fix:** Add a "Skip" button in the top-right corner on all pages that calls `onComplete()`.

### [MEDIUM] ReviewsFeedView Not Accessible from Any Navigation
**File:** Views/Reviews/ReviewsFeedView.swift  
**Issue:** `ReviewsFeedView` exists as a complete view with sorting and filtering, but it's not referenced in `ContentView`'s TabView or any NavigationLink anywhere in the app. It's an orphaned view.  
**Impact:** A fully built feature (community reviews feed with sort/filter) is completely inaccessible to users.  
**Fix:** Either add it as a tab, make it accessible from the Explore page, or link to it from Home's "Community" quick link.

### [MEDIUM] Services Filter Reset Doesn't Reset Jurisdiction
**File:** Views/Services/ServicesFilterSheet.swift:44-46  
**Issue:** The "Reset" button only clears `servicesOfferingFilter = nil` but doesn't reset jurisdiction. If a user changed jurisdiction in the filter sheet, reset won't undo it.  
**Impact:** Inconsistent reset behavior — users expect "Reset" to reset ALL filters shown on the sheet.  
**Fix:** Also reset jurisdiction to default (e.g., `.colorado`) in the reset action, or don't include jurisdiction in the filter sheet if it shouldn't be resettable.

### [MEDIUM] Catalog Filter Reset Doesn't Clear Search Text Immediately
**File:** ViewModels/AppState.swift:122-128, Views/Catalog/CatalogFilterSheet.swift  
**Issue:** `resetCatalogFilters()` clears `catalogSearchText`, but the search field is on the CatalogListView, not the filter sheet. Users who tap "Reset" in the filter sheet won't see the search bar clear since it's behind the sheet. This could be confusing.  
**Impact:** Minor confusion — search text disappears behind the scenes but user doesn't see it happen.  
**Fix:** Either don't reset search text from the filter sheet (keep it separate), or show search text in the filter sheet so reset is visible.

### [MEDIUM] Profile Links Point to example.com Placeholder URLs
**File:** Views/Profile/ProfileView.swift:210-238  
**Issue:** Community Guidelines, Privacy Policy, and Terms of Service all link to `https://example.com/...` — placeholder URLs that show a generic IANA page.  
**Impact:** Users who tap these links see a useless page. Looks unprofessional and potentially problematic for App Store review.  
**Fix:** Replace with actual URLs. The AgeGateView already links to the real support page (`https://xthe-dude.github.io/TripTalk/support.html`). Use consistent, real URLs.

### [MEDIUM] No Swipe-to-Delete for Saved Items in Profile
**File:** Views/Profile/ProfileView.swift:76-100 (saved strains section)  
**Issue:** Saved items in Profile are displayed as NavigationLinks in a VStack, but there's no swipe-to-delete gesture or remove button. Users must navigate into the detail view, find the bookmark icon in the toolbar, and tap it to unsave.  
**Impact:** Managing saved items requires 3+ taps per item instead of a simple swipe. Poor for users with many saved items.  
**Fix:** Add `.swipeActions` with a delete/unsave action to each saved item row, or add an "Edit" mode with remove buttons.

### [MEDIUM] Pull-to-Refresh Is Fake
**File:** Views/Home/HomeView.swift:147, Views/Explore/ExploreView.swift:101, Views/Catalog/CatalogListView.swift:55, Views/Services/ServicesListView.swift:49  
**Issue:** All four scrollable views have `.refreshable` that just does `try? await Task.sleep(for: .seconds(0.5))` — a fake 500ms delay that refreshes nothing. No data is reloaded.  
**Impact:** Users pull to refresh expecting updated content but nothing changes. Deceptive interaction pattern.  
**Fix:** Either remove `.refreshable` entirely (honest), or implement actual data refresh logic when a backend exists. If using mock data, at least randomize the featured strain or tip.

### [MEDIUM] No Keyboard Dismiss Mechanism on Search Fields
**File:** Views/Explore/ExploreView.swift:17-24, Views/Catalog/CatalogListView.swift:20-28, Views/Services/ServicesListView.swift:16-24  
**Issue:** Custom search bars use `TextField` but there's no `.onSubmit`, no clear button (×), and no tap-outside-to-dismiss. The keyboard stays open until the user finds another way to dismiss it.  
**Impact:** Keyboard covers content while browsing search results. No way to clear search quickly.  
**Fix:** Add `.submitLabel(.search)` and `.onSubmit {}`, a clear button when text is non-empty, and `.scrollDismissesKeyboard(.interactively)` on the parent ScrollView.

### [MEDIUM] Helpful/Report Buttons Have No State Feedback
**File:** Views/Components/ReviewCard.swift:59-72  
**Issue:** The "helpful" button increments `helpfulCount` but the button appearance doesn't change to show "you already marked this helpful." Users can tap it infinitely. The "report" button sets `isReported = true` but the card doesn't visually change.  
**Impact:** No feedback that the action worked. Users can spam helpful count. Reported reviews still display identically.  
**Fix:** Track which reviews the user has marked helpful (store in AppState/UserDefaults). Disable or visually change the helpful button after tapping. Show "Reported" state or hide the report button after reporting.

---

### [LOW] Featured Variety Is Always the First Strain
**File:** Views/Home/HomeView.swift:42  
**Issue:** `appState.strains.first` is always the same strain. The "Featured Variety Spotlight" never changes.  
**Impact:** Repeat visitors always see the same featured strain. Feels stale.  
**Fix:** Rotate based on day of year (similar to the tip logic), or randomize with a seed.

### [LOW] Explore "Near You" Doesn't Use Location
**File:** Views/Explore/ExploreView.swift:90-99  
**Issue:** "Near You" section just shows `appState.services.prefix(2)` — the first two services regardless of location.  
**Impact:** Misleading section title. Not actually location-aware.  
**Fix:** Sort by distance if location is available, or rename to "Featured Services."

### [LOW] Community Photos Are Placeholder Rectangles
**File:** Views/Catalog/StrainDetailView.swift:127-142  
**Issue:** "Community Photos" section shows colored rectangles with a photo icon overlay. Not interactive, no upload capability, no real photos.  
**Impact:** Takes up screen real estate with non-functional placeholder content. Sets expectation of a feature that doesn't exist.  
**Fix:** Either remove the section until photos are implemented, or label it as "Coming soon." If keeping placeholders, don't show a count that implies real photos exist.

### [LOW] Inconsistent Navigation Destination Registration
**File:** Views/Home/HomeView.swift (only registers `Strain.self`), Views/Explore/ExploreView.swift (registers Strain, Substance, ServiceCenter), Views/Profile/ProfileView.swift (registers all three)  
**Issue:** HomeView only registers `.navigationDestination(for: Strain.self)`. If a future change adds substance or service links to Home, they won't navigate. Each tab's NavigationStack has different destination registrations.  
**Impact:** Low risk currently, but fragile. Any refactor adding cross-type navigation to Home will silently fail.  
**Fix:** Create a shared navigation destination modifier or ensure all NavigationStacks register all navigable types.

### [LOW] Reset Age Verification Has No Confirmation
**File:** Views/Profile/ProfileView.swift:249-256  
**Issue:** The "Reset Age Verification" button immediately sets `ageVerified = false` with no confirmation dialog. One accidental tap kicks the user out to the age gate.  
**Impact:** User loses their current context and must re-verify. Minor annoyance but preventable.  
**Fix:** Add a confirmation alert: "This will return you to the age verification screen. Continue?"

### [LOW] TextEditor Background Not Transparent on iOS 16
**File:** Views/Reviews/WriteReviewView.swift:45-52, Views/Reviews/WriteTripReportView.swift:107-114  
**Issue:** `TextEditor` in SwiftUI has a default white/system background. The form uses dark glass styling but TextEditor may show a white background on some iOS versions, breaking the dark theme.  
**Impact:** Visual inconsistency in the writing form.  
**Fix:** Add `.scrollContentBackground(.hidden)` to each TextEditor (available iOS 16+).

### [LOW] No Character Count or Length Validation on Text Fields
**File:** Views/Reviews/WriteTripReportView.swift, Views/Reviews/WriteReviewView.swift  
**Issue:** Highlights, safety notes, review body, and title fields have no character limits or counts. Users could submit empty-ish content (single character) or extremely long text.  
**Impact:** Poor content quality; potential layout issues with very long text.  
**Fix:** Add character count labels (e.g., "42/500") and minimum length validation (e.g., 20 chars for body text).

---

## Flow-Level Summary

| Flow | Rating | Key Issues |
|------|--------|------------|
| Onboarding → AgeGate → Home | ⚠️ Weak | Age gate is trivial; no skip on onboarding |
| Home → Explore → Catalog → Strain Detail | 🔴 Broken | Quick links non-functional; trip reports not tappable |
| Strain Detail → Write Trip Report | ⚠️ Risky | No data loss prevention on dismiss; form is thorough |
| Services → Service Detail → Write Review | ⚠️ Risky | Offering filter broken; same dismiss risk |
| Profile → Saved items → Detail views | ✅ Decent | Works but no swipe-to-delete |
| Search flows | ⚠️ Fragmented | Two independent search systems; no keyboard dismiss |
| Filter sheets | ⚠️ Partial | Catalog filters work; services offering filter broken |
| Navigation patterns | ✅ Decent | Consistent back buttons; proper NavigationStack usage |
| Feedback states | 🔴 Weak | Bookmark has no toast; helpful has no state; report has no feedback |
| Error/edge cases | ⚠️ Missing | No empty states for filtered results; fake refresh |
