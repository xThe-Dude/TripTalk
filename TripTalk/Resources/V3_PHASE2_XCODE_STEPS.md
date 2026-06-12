# V3 Phase 2 — Xcode Integration Steps

> Branch: `v3/phase2-local-store`
> Date: 2026-06-12

These are the manual steps you must complete in **Xcode** after pulling this
branch. The code compiles correctly; these steps wire the new files into the
Xcode target so they participate in the build.

---

## 1. Add new files to the `TripTalk` target

Open `TripTalk.xcodeproj` in Xcode, then **File → Add Files to "TripTalk"…**
(or drag-and-drop into the Project Navigator). Ensure **"Add to targets: TripTalk"**
is checked for each file below.

| File | Group in Navigator |
|------|--------------------|
| `TripTalk/Models/JournalEntry.swift` | Models |
| `TripTalk/Services/JournalStore.swift` | Services |
| `TripTalk/Services/JournalAudioStorage.swift` | Services |

> **Quick check:** After adding, select each file in the Navigator →
> File Inspector (right panel) → confirm "Target Membership → TripTalk" is ticked.

---

## 2. iOS Deployment Target — already OK

The project's `IPHONEOS_DEPLOYMENT_TARGET` is **17.0**, which is the minimum
required for SwiftData (`import SwiftData`, `@Model`, `ModelContainer`).
**No change needed.**

If you ever see the error
`'SwiftData' is only available in macOS 14 / iOS 17 or newer`,
bump the deployment target in:
**Project → TripTalk → Deployment Info → iOS → 17.0**

---

## 3. CloudKit / iCloud — nothing to do

`JournalStore` configures its `ModelConfiguration` with:

```swift
cloudKitDatabase: .none
```

This means:
- No iCloud entitlement is needed for the journal.
- The existing `TripTalk.entitlements` file does **not** need a
  `com.apple.developer.icloud-services` or `com.apple.developer.icloud-container-identifiers` key.
- Data is stored only in the app's on-disk Application Support directory.

---

## 4. No new Swift Package dependencies

Phase 2 uses only:
- `SwiftData` (system framework, iOS 17+)
- `Foundation` (already linked)
- `Observation` (system framework, iOS 17+)

No `Package.swift` or SPM changes required.

---

## 5. Wiring `JournalStore` into the app (future — Phase 3 UI)

When Phase 3 adds journal UI, inject `JournalStore` as an environment object
from the scene root in `TripTalkApp.swift`:

```swift
// Example — add when building Phase 3 views
@State private var journalStore = JournalStore()

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(journalStore)
    }
}
```

No changes to `TripTalkApp.swift` are required for Phase 2 (data layer only).

---

## Summary

| Step | Action | Status |
|------|--------|--------|
| Add 3 Swift files to TripTalk target | Manual in Xcode | **TODO** |
| iOS 17 deployment target | Already set | OK |
| CloudKit entitlement | Not needed | OK |
| SPM dependencies | None new | OK |
