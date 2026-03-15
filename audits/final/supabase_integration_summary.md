# Supabase Integration Summary

## What Was Done

### Step 1 — Dependency Documentation
- `TripTalk/DEPENDENCIES.md` — documents `supabase-swift` v2.x package URL for manual Xcode SPM addition.

### Step 2 — Service Layer (TripTalk/Services/)
All files created from scratch:

| File | Purpose |
|---|---|
| `SupabaseManager.swift` | Singleton `SupabaseClient` configured with project URL + anon key |
| `AuthService.swift` | `@Observable @MainActor` class — session/profile management, Apple sign-in, email auth, sign-up, sign-out |
| `StrainRepository.swift` | Fetches all published strains or by substance type |
| `ReviewRepository.swift` | Fetch, create, mark-helpful for reviews |
| `TripReportRepository.swift` | Fetch and create trip reports |
| `BookmarkRepository.swift` | Fetch all bookmarks, toggle (insert/delete) |
| `StorageService.swift` | Upload avatar and community photos to Supabase Storage |

### Step 3 — Database Models (TripTalk/Models/DBModels.swift)
`Codable` structs mapping to Supabase tables with snake_case CodingKeys:
- `DBProfile`, `DBStrain`, `DBReview`, `DBTripReport`, `DBBookmark`
- Insert structs: `ReviewInsert`, `TripReportInsert`

### Step 4 — Model Converter (TripTalk/Services/ModelConverters.swift)
`DBStrain.toStrain()` extension converts DB records to the existing `Strain` view model:
- Maps `parent_substance` string → `SubstanceType` enum via `.capitalized`
- Maps `potency` string → `Potency` enum (handles `very_strong` → `.veryStrong`)
- Maps `difficulty` string → `Difficulty` enum (handles "beginner" → "Beginner Friendly" rawValue)
- Tags (`commonEffects`, `bodyFeel`, `emotionalProfile`) use `compactMap` — unknown values are silently dropped

### Step 5 — AppState Wiring (TripTalk/ViewModels/AppState.swift)
- Added `let authService = AuthService()` property
- Added `loadFromSupabase() async` — fetches strains, converts, assigns; falls back silently to MockData on error
- `init()` fires `Task { await loadFromSupabase() }` so live data loads on app launch

## Offline Fallback
`strains` is always initialized from `MockData.strains` first. If Supabase is unreachable, the app continues working with mock data. `MockData.swift` was not modified.

## Pending Manual Step
Cole must add the SPM package in Xcode:
1. File → Add Package Dependencies
2. Paste: `https://github.com/supabase/supabase-swift`
3. Version rule: from `2.0.0`
4. Add to **TripTalk** target

## Supabase Project
- URL: `https://fybfuykxbwhlhmjyscor.supabase.co`
- RLS policies must allow anon reads on `strains` (is_published = true) for unauthenticated catalog browsing.
