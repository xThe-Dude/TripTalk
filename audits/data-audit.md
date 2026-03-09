# TripTalk Data Layer Audit
**Date:** 2026-03-09  
**Auditor:** Data Architecture Review (Lily subagent)

---

## Summary

The data layer is solid for a v1 app. Models are clean, mock data is high-quality, and the UserDefaults persistence approach is appropriate for the current scope. There are **3 critical**, **5 medium**, and **6 low** severity findings.

---

## Critical Findings

### [CRITICAL] Missing Codable on `SubstanceType`, `BodyFeel`, `EmotionalTag` enums
**File:** Models/Enums.swift
**Issue:** `SubstanceType`, `BodyFeel`, and `EmotionalTag` are missing `Codable` conformance. `Strain` uses all three but isn't `Codable` itself yet. If you ever persist strains (saved strains → UserDefaults), this will crash at encode time. More immediately, `TripReport.strainId` is a UUID, so it works—but `Strain` can't round-trip through JSON.
**Impact:** Blocks future Strain persistence; inconsistent with other enums that do have Codable
**Fix:** Add `Codable` to all three enums:
```swift
enum SubstanceType: String, CaseIterable, Identifiable, Codable { ... }
enum BodyFeel: String, CaseIterable, Identifiable, Codable { ... }
enum EmotionalTag: String, CaseIterable, Identifiable, Codable { ... }
```

### [CRITICAL] `Substance` is not Codable — breaks persistence and backend migration
**File:** Models/Substance.swift
**Issue:** `Substance` has a `[Jurisdiction: JurisdictionStatus]` dictionary property. Dictionary keys must be `String` or `Int` for automatic Codable synthesis. `Jurisdiction` is a `String`-backed enum, so `[Jurisdiction: JurisdictionStatus]` won't auto-synthesize. You'll need custom `CodingKeys` or convert to `[String: String]`.
**Impact:** Cannot persist substances, cannot decode from Supabase JSON without custom work
**Fix:** Either (a) change to `[String: JurisdictionStatus]` and convert at access time, or (b) add custom `Codable` conformance with `encode`/`decode` methods that map through `rawValue`.

### [CRITICAL] Duplicate data on load — user content appended to mock data every launch
**File:** ViewModels/AppState.swift:init → loadPersistedData()
**Issue:** `loadPersistedData()` appends `userTripReports` and `userReviews` to the already-initialized `tripReports` (which starts as `MockData.tripReports`) and `reviews`. This is correct on first load. **But** if MockData IDs are ever non-deterministic (they use `UUID()` in trip reports!), you can't deduplicate. Currently mock trip reports use `UUID()` — meaning their IDs change every launch, so you can't detect "already in the list."
**Impact:** Currently benign because mock trip report IDs aren't persisted. But if you ever persist all trip reports or add server sync, you'll get duplicates.
**Fix:** Give mock trip reports stable UUIDs (like you did for strains/substances/services), or filter duplicates on load:
```swift
tripReports.append(contentsOf: reports.filter { r in !tripReports.contains { $0.id == r.id } })
```

---

## Medium Findings

### [MEDIUM] No validation on Review.rating range
**File:** Models/Review.swift
**Issue:** `rating` is `Int` with no bounds enforcement. Nothing prevents `rating: 0`, `rating: -1`, or `rating: 99`.
**Impact:** UI may render incorrectly (e.g., star display). Invalid data could be persisted.
**Fix:** Add a clamping init or use `@Clamped` property wrapper:
```swift
let rating: Int // should be 1...5
// In init: self.rating = max(1, min(5, rating))
```

### [MEDIUM] TripReport.strainId has no referential integrity
**File:** Models/TripReport.swift
**Issue:** `strainId` is a bare `UUID` with no guarantee the strain exists. Users could submit a trip report, then if strain data changes (mock data refresh, backend migration), the report points to nothing.
**Impact:** `tripReportsFor(strain:)` silently returns empty; strain detail views could show "0 reports" for reports that exist but are orphaned.
**Fix:** For v1, add a helper to detect orphans:
```swift
var orphanedTripReports: [TripReport] {
    let strainIDs = Set(strains.map(\.id))
    return tripReports.filter { !strainIDs.contains($0.strainId) }
}
```
For v2 with Supabase, use foreign key constraints.

### [MEDIUM] Review has both substanceID and serviceID — ambiguous ownership
**File:** Models/Review.swift
**Issue:** A review can have both `substanceID` and `serviceID` set (or neither). This creates ambiguity: is it a substance review, a service review, or both? The mock data has reviews with both set (e.g., "Life-changing experience at Rocky Mountain" has both psilocybinID and serviceID1).
**Impact:** If you filter "reviews for this service," you also get substance-tagged reviews. This is arguably intentional (reviewed both the substance and the service in one review), but it makes counting and attribution messy.
**Fix:** Consider whether this is intentional. If reviews should belong to one entity, use an enum:
```swift
enum ReviewTarget: Codable {
    case substance(UUID)
    case service(UUID)
}
```
If dual-tagging is intentional, document it clearly and ensure both detail views handle it.

### [MEDIUM] `toggleHelpful` and `reportReview` don't persist
**File:** ViewModels/AppState.swift
**Issue:** `toggleHelpful()` and `reportReview()` mutate `reviews[]` in memory but don't call `persistAll()`. These changes are lost on relaunch.
**Impact:** User sees their "helpful" vote disappear on next launch
**Fix:** Add `persistAll()` at the end of both methods. But note: you're only persisting `userReviews`, not all reviews. You'd need a separate mechanism to track "which reviews the user marked helpful" — probably a `Set<UUID>` stored separately.

### [MEDIUM] `helpfulCount` increment has no toggle-off / double-tap protection
**File:** ViewModels/AppState.swift
**Issue:** Every call to `toggleHelpful()` increments the count. There's no tracking of whether the current user already marked it helpful. Users can spam the count.
**Impact:** Inflated helpful counts; poor UX
**Fix:** Track `helpfulReviewIDs: Set<UUID>` in AppState, persist it, and toggle instead of always incrementing.

---

## Low Findings

### [LOW] `Strain` and `ServiceCenter` not Codable
**File:** Models/Strain.swift, Models/ServiceCenter.swift
**Issue:** Neither conforms to `Codable`. Not needed today since only user-generated content is persisted, but blocks any future persistence or API integration.
**Impact:** Migration friction when adding Supabase
**Fix:** Add `Codable` conformance now while the models are simple. Fix the enum Codable gaps first (see CRITICAL #1).

### [LOW] `averageRating` and `reviewCount` are static on models
**File:** Models/Substance.swift, Models/Strain.swift, Models/ServiceCenter.swift
**Issue:** `averageRating` and `reviewCount` are hardcoded `let` properties. When users add reviews, these don't update. The UI will show stale counts.
**Impact:** Misleading review counts; user adds review but count stays at "89"
**Fix:** Compute these from actual reviews in AppState:
```swift
func averageRating(for substanceID: UUID) -> Double {
    let relevant = reviews.filter { $0.substanceID == substanceID }
    guard !relevant.isEmpty else { return 0 }
    return Double(relevant.map(\.rating).reduce(0, +)) / Double(relevant.count)
}
```

### [LOW] `distanceMiles` is hardcoded on ServiceCenter
**File:** Models/ServiceCenter.swift
**Issue:** `distanceMiles` is a static `Int`. Should be computed from user location.
**Impact:** Shows wrong distance; not useful for sorting by proximity
**Fix:** For v1, acceptable. For v2, compute from CoreLocation and remove from model.

### [LOW] Mock data trip reports use `UUID()` — non-deterministic IDs
**File:** Data/MockData.swift:tripReports
**Issue:** Unlike substances/strains/services which have stable hardcoded UUIDs, trip reports use `UUID()`. Every launch generates new IDs.
**Impact:** Can't reference mock trip reports by ID; complicates testing and deep linking
**Fix:** Create stable IDs like the other entities: `static let tripReport1ID = UUID(uuidString: "20000000-...")!`

### [LOW] `SubstanceType` vs `SubstanceCategory` naming confusion
**File:** Models/Enums.swift
**Issue:** Two similar enums: `SubstanceCategory` (psychedelic/empathogen/dissociative) and `SubstanceType` (psilocybin/ayahuasca/mescaline/ketamine/other). Substance uses `category`, Strain uses `parentSubstance: SubstanceType`. The naming doesn't make the hierarchy clear.
**Impact:** Developer confusion; no runtime bug
**Fix:** Rename for clarity: `SubstanceCategory` → `SubstanceClass`, or `SubstanceType` → `SubstanceName`/`SubstanceKind`. Or add doc comments explaining the hierarchy.

### [LOW] No `strainId` on Review — can't review individual strains
**File:** Models/Review.swift
**Issue:** Reviews link to `substanceID` and `serviceID` but not `strainId`. TripReports link to strains. If a user wants to leave a simple star-rating review (not a full trip report) for a strain, there's no mechanism.
**Impact:** Inconsistent — strains only have trip reports, not reviews. May confuse users.
**Fix:** Either add `strainId: UUID?` to Review, or decide that strains only get trip reports (and document this).

---

## Architecture Assessment

### UserDefaults for v1: ✅ Correct Call
- User data volume is small (saved IDs, handful of reviews/reports)
- No relationships to maintain across tables
- Simple encode/decode with Codable
- **Migrate when:** >100 user reports, need search/query, need sync, or need relational integrity

### @Observable: ✅ Right Pattern
- Clean, modern (iOS 17+)
- No race conditions in current single-threaded UI usage
- **Watch for:** If you add background data loading (e.g., API calls), mutations must happen on `@MainActor`. Consider adding `@MainActor` to the class:
```swift
@MainActor @Observable class AppState { ... }
```

### Filter Performance: ✅ Fine for Now
- All filters are O(n) linear scans — appropriate for <100 items
- `filteredStrains` applies up to 5 filters in sequence — still O(n) per filter, O(5n) total = O(n)
- No O(n²) issues detected
- **Watch for:** `localizedCaseInsensitiveContains` is expensive per-call. If catalog grows to 1000+, pre-compute lowercased names.

### Supabase Migration Difficulty: **Medium**
What needs to change:
1. All models need `Codable` (partially done)
2. Replace `[Jurisdiction: JurisdictionStatus]` with a junction table or JSONB column
3. Replace `MockData` init with async fetch calls
4. `AppState` needs async loading states (loading/loaded/error)
5. User data (reviews, trip reports) → Supabase insert instead of UserDefaults
6. Computed stats (averageRating, reviewCount) → SQL aggregates or materialized views
7. `savedXxxIDs` → user_favorites table

**Estimated effort:** 2-3 days for a clean migration if Codable gaps are fixed first.
