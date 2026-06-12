# V3 Phase 4 — Xcode Integration Steps

> Branch: `v3/phase4-journal-ui`
> Date: 2026-06-12

These are the manual steps to complete in **Xcode** after pulling this branch.
The Swift files are compile-correct; these steps add them to the TripTalk target
so they participate in the build.

---

## 1. Create the `Journal` group in Xcode

In the Project Navigator, right-click **TripTalk → Views** and choose
**New Group Without Folder** (or **New Group**) → name it `Journal`.

> The folder already exists on disk at `TripTalk/Views/Journal/`.

---

## 2. Add new files to the `TripTalk` target

**File → Add Files to "TripTalk"…** (or drag into the Navigator).
Ensure **"Add to targets: TripTalk"** is checked for each file.

| File path (relative to repo root) | Navigator group |
|-----------------------------------|-----------------|
| `TripTalk/Views/Journal/JournalListView.swift` | Views/Journal |
| `TripTalk/Views/Journal/JournalEntryEditorView.swift` | Views/Journal |
| `TripTalk/Views/Journal/JournalEntryDetailView.swift` | Views/Journal |

> **Quick check:** select each file → File Inspector (right panel) →
> confirm "Target Membership → TripTalk" is ticked.

---

## 3. Modified existing files (already in target — no action needed)

These files were edited in-place and are already members of the TripTalk target:

| File | Change |
|------|--------|
| `TripTalk/ViewModels/AppState.swift` | Added `let journal = JournalStore()` |
| `TripTalk/ContentView.swift` | Added Journal tab (tag 6) |
| `TripTalk/Views/Catalog/StrainDetailView.swift` | Added "Start a Journey" button |

---

## 4. No new dependencies

Phase 4 uses only system frameworks already linked by the project:
- `Foundation` — `UUID`, `Date`
- `SwiftUI` — views
- `SwiftData` — already linked from Phase 2 (JournalStore / JournalEntry)

No SPM, Cocoapods, or framework changes are required.

---

## 5. Journal entry point

The Journal is accessible via **tab 6** (icon: `book.closed.fill`, label: "Journal")
in the main `TabView` in `ContentView`. It can also be opened from any strain's
detail page via the **"Start a Journey"** button in the Trip Reports section.

---

## 6. What Phase 4 adds

### `TripTalk/Views/Journal/JournalListView.swift`
Lists all private on-device journal entries (newest first) via
`appState.journal.fetchAll()`. Each row shows substance name, date, a 1-line
snippet (intention or highlights), and the star rating if set. An empty state
(reusing `EmptyStateView`) is shown when no entries exist. The "+" toolbar button
and empty-state action button both open `JournalEntryEditorView`.

### `TripTalk/Views/Journal/JournalEntryEditorView.swift`
Create/edit form with four init variants:
- `init()` — blank new entry
- `init(prefillSubstanceName:prefillSubstanceId:)` — pre-filled from StrainDetailView
- `init(entry:)` — edit mode (populates all fields from the existing entry)

Sections: Substance (catalog picker or free-text), Context (setting, intention,
rating), Journey (four phase note TextEditors: Prepare / Onset / Peak /
Integration), and Reflection (highlights, safety notes). Saving calls
`appState.journal.create` or `.update`; dismissing without saving never mutates
a SwiftData record (all state is local `@State`).

### `TripTalk/Views/Journal/JournalEntryDetailView.swift`
Read-only view of a single entry. Displays `JourneyTimelineView` (matched strain
by `substanceId` then name from `MockData.strains`, or string-init fallback with
"varies" timing if substance is set but not found in catalog). Shows all four
phase notes (collapsed if empty), reflection cards for highlights and safety
notes, and a delete button with a confirmation dialog.

---

## 7. Summary

| Step | Action | Status |
|------|--------|--------|
| Create `Views/Journal` group in Navigator | Manual in Xcode | **TODO** |
| Add 3 new Swift files to TripTalk target | Manual in Xcode | **TODO** |
| Modified files (AppState, ContentView, StrainDetailView) | Already in target | OK |
| New frameworks / SPM packages | None | OK |
| iOS deployment target | Already 17.0 | OK |
