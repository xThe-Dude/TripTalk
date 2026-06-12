# V3 Phase 3 — Xcode Integration Steps

> Branch: `v3/phase3-journey-timeline`
> Date: 2026-06-12

These are the manual steps to complete in **Xcode** after pulling this branch.
The Swift files are compile-correct; these steps add them to the TripTalk target
so they participate in the build.

---

## 1. Create the `Journey` group in Xcode

In the Project Navigator, right-click **TripTalk → Views** and choose
**New Group Without Folder** (or **New Group**) → name it `Journey`.

> The folder already exists on disk at `TripTalk/Views/Journey/`.
> Creating the Xcode group makes the files visible in the Navigator.

---

## 2. Add new files to the `TripTalk` target

**File → Add Files to "TripTalk"…** (or drag into the Navigator).
Ensure **"Add to targets: TripTalk"** is checked for each file.

| File path (relative to repo root) | Navigator group |
|-----------------------------------|-----------------|
| `TripTalk/Models/PhaseTiming.swift` | Models |
| `TripTalk/Views/Journey/JourneyPhase.swift` | Views/Journey |
| `TripTalk/Views/Journey/JourneyTimelineView.swift` | Views/Journey |

> **Quick check:** select each file → File Inspector (right panel) →
> confirm "Target Membership → TripTalk" is ticked.

---

## 3. No new dependencies

Phase 3 uses only system frameworks already linked by the project:
- `Foundation` — parser, `NSRegularExpression`, `Date`
- `SwiftUI` — views, `#Preview`

No SPM, Cocoapods, or framework changes are required.

---

## 4. Running the previews

Open `TripTalk/Views/Journey/JourneyTimelineView.swift` in Xcode and open the
Canvas (Editor → Canvas). Four preview canvases are available:

| Preview name | What it exercises |
|---|---|
| **Golden Teachers · static** | Parsed timing, no active phase |
| **Ketamine IV · live ~45 min in** | Immediate onset, live banner in peak phase |
| **Ayahuasca · live onset phase** | `+ afterglow` stripping, live banner in onset |
| **Unknown strain · estimated timing** | Parse failure → fallback + disclaimer |

---

## 5. What Phase 3 adds

### `TripTalk/Models/PhaseTiming.swift`
Pure value type + parser. Converts free-text onset/duration strings (e.g.
`"30-60 min"`, `"4-6 hours"`, `"Immediate"`) into structured minute-boundary
values for the four phases. Returns `PhaseTiming.fallback` with
`wasEstimated: true` when parsing fails entirely.

**Phase boundary formula:**
```
Onset:       0           → onsetEnd
Peak:        onsetEnd    → onsetEnd + round(plateau × 0.75)
Integration: peakEnd     → totalEnd
```
where `plateau = totalEnd − onsetEnd`.

### `TripTalk/Views/Journey/JourneyPhase.swift`
`enum JourneyPhase: Int, CaseIterable, Hashable` with four cases.
Each case carries `title`, `symbolName` (SF Symbol), `shortDescription`, and
a `timeLabel(using:)` method that formats its window from a `PhaseTiming`.
Static helper `JourneyPhase.current(at:timing:)` maps elapsed minutes → phase.

### `TripTalk/Views/Journey/JourneyTimelineView.swift`
The signature interaction view. Accepts either a `Strain` or raw onset/duration
strings + strain name. Optional `ingestionDate: Date?` enables live mode:
- Active phase is highlighted with `ttAccent` (subtle circle + dot indicator).
- A safety-awareness banner shows elapsed time and time to next phase
  (e.g. `"~45 min in · peak in ~15 min"`).
- No timers — time is read at render; re-renders on normal SwiftUI state changes.
- `wasEstimated` surfaces a disclaimer when parse failed.
- Reduced-motion safe: no animations; all content visible in static layout.

---

## 6. Wiring into navigation (future — Phase 4+)

`JourneyTimelineView` is intentionally not wired into `HomeView` or any
navigation stack in Phase 3. To present it from a strain detail screen:

```swift
// Example — add in Phase 4
JourneyTimelineView(strain: selectedStrain, ingestionDate: activeSession?.startDate)
    .navigationTitle("Journey")
```

No changes to `HomeView.swift`, `TripTalkApp.swift`, or any existing file are
required for Phase 3.

---

## Summary

| Step | Action | Status |
|------|--------|--------|
| Create `Views/Journey` group in Navigator | Manual in Xcode | **TODO** |
| Add 3 Swift files to TripTalk target | Manual in Xcode | **TODO** |
| New frameworks / SPM packages | None | OK |
| iOS deployment target | Already 17.0 | OK |
