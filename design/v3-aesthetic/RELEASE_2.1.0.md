# TripTalk 2.1.0 (build 9) — Submission Checklist

**Status:** Code-complete, version-bumped, pushed. Hold submission until **2.0.0 (build 8)
clears review** — App Store Connect blocks a second version while one is in review.

## Version
- `MARKETING_VERSION` = **2.1.0**  (above pending 2.0.0)
- `CURRENT_PROJECT_VERSION` = **9**  (above pending build 8)
- Bundle: `com.triptalk.app`
- Commit: `833e979` (+ all v3 work through `757f51d`)

## "What's New" (approved — paste into ASC)

> A refined, premium redesign throughout — a calmer, editorial "field guide" look
> with a brand-new app icon. Explore now shows full variety photos, and we fixed the
> journal so you can log entries for every variety in the catalog. Plus polish and
> stability improvements across the app.

## What changed in 2.1.0 (for internal reference / review notes)
- **Aesthetic overhaul (Phase 1+2):** matte charcoal base (#0E1419), single champagne-gold
  accent (#D9C8A0), keyline cards (de-glossed), nav-bar separator. Removed teal/purple
  gradients + glow across all screens.
- **New app icon:** etched field-guide TT monogram (replaces glass TT).
- **Explore fix:** variety cards now show real catalog photos (was a generic leaf icon).
- **Journal fix:** "Pick from catalog" strain picker now lists the full catalog
  (was hardcoded to a stale MockData subset).
- **Build stability:** decomposed ProfileView to clear SwiftUI type-check timeouts.

## Submission steps (Cole — Xcode/ASC; Lily can't do these)
1. [ ] **Archive** Release build in Xcode (Product → Archive). Confirm 2.1.0 / 9 + new icon.
2. [ ] **Upload** to App Store Connect (Organizer → Distribute App). Wait ~10–30 min processing.
3. [ ] **Wait for 2.0.0 approval** before creating/submitting 2.1.0.
4. [ ] In ASC: create **2.1.0** version, attach **build 9**.
5. [ ] **Refresh screenshots** — UI changed dramatically; old teal-gradient shots are misleading.
       Recapture on simulator (Home, Catalog, Explore, Journal, a detail screen).
6. [ ] Paste the **"What's New"** text above.
7. [ ] Submit for review.

## Notes
- Demo account (if review asks): demo@triptalk.app / TripTalk-Demo-2026!
- No new permissions/entitlements added in v3 — purely visual + 2 data-source fixes.
