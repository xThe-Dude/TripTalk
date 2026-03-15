# TripTalk — Supabase Backend Proposal

## Overview

Migrate TripTalk from a fully offline mock-data app to a live Supabase-powered backend with authentication, real-time UGC, media uploads, and content moderation.

---

## 1. Auth Methods

| Method | Priority | Notes |
|---|---|---|
| **Sign in with Apple** | P0 (required for App Store if offering any social login) | Native iOS, highest trust, anonymized email relay |
| **Email + Password** | P0 | Fallback for non-Apple users |
| **Anonymous / Guest** | P1 | Browse catalog without account; upgrade to full account to submit UGC |

### Auth Flow
```
App Launch
  → Age Gate (21+ verification, stored locally)
  → Onboarding (3 screens, shown once)
  → Home (browsing as guest)
  → "Sign In" prompt when attempting UGC (write review, submit report, bookmark sync)
  → Apple Sign In / Email+Password
  → Profile created in `profiles` table via trigger
```

### Session Management
- Supabase Swift SDK handles JWT refresh automatically
- Access token stored in Keychain (not UserDefaults)
- Offline fallback: cached data remains browsable, UGC queued for sync

---

## 2. Database Schema

### `profiles` (auto-created on auth signup)
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT 'Anonymous',
  avatar_url TEXT,
  bio TEXT,
  experience_level TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'experienced')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_banned BOOLEAN NOT NULL DEFAULT false,
  report_count INT NOT NULL DEFAULT 0
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'Anonymous'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### `strains` (admin-managed catalog)
```sql
CREATE TABLE strains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  parent_substance TEXT NOT NULL CHECK (parent_substance IN ('psilocybin', 'ayahuasca', 'mescaline', 'ketamine', 'other')),
  species TEXT NOT NULL,
  potency TEXT NOT NULL CHECK (potency IN ('mild', 'moderate', 'strong', 'very_strong')),
  description TEXT NOT NULL,
  common_effects TEXT[] NOT NULL DEFAULT '{}',
  body_feel TEXT[] NOT NULL DEFAULT '{}',
  emotional_profile TEXT[] NOT NULL DEFAULT '{}',
  onset TEXT NOT NULL,
  duration TEXT NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'experienced')),
  hero_image_url TEXT,
  is_published BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Computed stats via view (not stored, always fresh)
CREATE VIEW strain_stats AS
SELECT
  s.id AS strain_id,
  COALESCE(AVG(r.rating)::NUMERIC(3,2), 0) AS average_rating,
  COUNT(DISTINCT r.id) AS review_count,
  COUNT(DISTINCT p.id) AS photo_count
FROM strains s
LEFT JOIN reviews r ON r.strain_id = s.id AND r.is_removed = false
LEFT JOIN community_photos p ON p.strain_id = s.id AND p.is_removed = false
GROUP BY s.id;
```

### `reviews` (user-generated)
```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID REFERENCES strains(id) ON DELETE CASCADE,
  service_id UUID REFERENCES service_centers(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title TEXT NOT NULL CHECK (char_length(title) BETWEEN 3 AND 200),
  body TEXT NOT NULL CHECK (char_length(body) BETWEEN 10 AND 5000),
  tags TEXT[] NOT NULL DEFAULT '{}',
  helpful_count INT NOT NULL DEFAULT 0,
  is_reported BOOLEAN NOT NULL DEFAULT false,
  is_removed BOOLEAN NOT NULL DEFAULT false,
  removed_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Must reference either strain or service, not both
  CONSTRAINT review_target CHECK (
    (strain_id IS NOT NULL AND service_id IS NULL) OR
    (strain_id IS NULL AND service_id IS NOT NULL)
  )
);

CREATE INDEX idx_reviews_strain ON reviews(strain_id) WHERE is_removed = false;
CREATE INDEX idx_reviews_author ON reviews(author_id);
CREATE INDEX idx_reviews_created ON reviews(created_at DESC);
```

### `trip_reports` (user-generated)
```sql
CREATE TABLE trip_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  setting TEXT NOT NULL CHECK (setting IN ('nature', 'home', 'ceremony', 'social', 'festival')),
  intention TEXT CHECK (char_length(intention) <= 1000),
  experience_types TEXT[] NOT NULL DEFAULT '{}',
  visual_intensity INT NOT NULL CHECK (visual_intensity BETWEEN 1 AND 5),
  body_intensity INT NOT NULL CHECK (body_intensity BETWEEN 1 AND 5),
  emotional_intensity INT NOT NULL CHECK (emotional_intensity BETWEEN 1 AND 5),
  moods TEXT[] NOT NULL DEFAULT '{}',
  highlights TEXT NOT NULL CHECK (char_length(highlights) BETWEEN 10 AND 5000),
  safety_notes TEXT,
  would_repeat BOOLEAN NOT NULL DEFAULT false,
  is_reported BOOLEAN NOT NULL DEFAULT false,
  is_removed BOOLEAN NOT NULL DEFAULT false,
  removed_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_strain ON trip_reports(strain_id) WHERE is_removed = false;
CREATE INDEX idx_reports_author ON trip_reports(author_id);
CREATE INDEX idx_reports_created ON trip_reports(created_at DESC);
```

### `service_centers` (admin-managed)
```sql
CREATE TABLE service_centers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  address TEXT NOT NULL,
  about TEXT NOT NULL,
  offerings TEXT[] NOT NULL DEFAULT '{}',
  is_verified BOOLEAN NOT NULL DEFAULT false,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  website_url TEXT,
  phone TEXT,
  image_symbol TEXT NOT NULL DEFAULT 'building.2',
  is_published BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### `bookmarks` (per-user)
```sql
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, strain_id)
);

CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);
```

### `helpful_votes` (prevent double-voting)
```sql
CREATE TABLE helpful_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, review_id)
);
```

### `content_reports` (moderation)
```sql
CREATE TABLE content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
  trip_report_id UUID REFERENCES trip_reports(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('spam', 'harmful', 'dosage_advice', 'recreational', 'harassment', 'other')),
  details TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'actioned', 'dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### `community_photos` (user-uploaded strain photos)
```sql
CREATE TABLE community_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  caption TEXT,
  is_removed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### `crisis_taps` (anonymous safety metric)
```sql
CREATE TABLE crisis_taps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource TEXT NOT NULL CHECK (resource IN ('988_lifeline', 'fireside_project')),
  tapped_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 3. Row-Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE strains ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE crisis_taps ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════
-- PROFILES
-- ═══════════════════════════════════════
-- Anyone can read profiles (for author names on reviews)
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ═══════════════════════════════════════
-- STRAINS (read-only for users, admin writes)
-- ═══════════════════════════════════════
CREATE POLICY "Published strains are viewable by everyone"
  ON strains FOR SELECT USING (is_published = true);

-- Admin-only insert/update/delete via service_role key (not RLS)

-- ═══════════════════════════════════════
-- REVIEWS
-- ═══════════════════════════════════════
-- Anyone can read non-removed reviews
CREATE POLICY "Non-removed reviews are viewable"
  ON reviews FOR SELECT USING (is_removed = false);

-- Authenticated users can create reviews
CREATE POLICY "Authenticated users can create reviews"
  ON reviews FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete own reviews"
  ON reviews FOR DELETE USING (auth.uid() = author_id);

-- ═══════════════════════════════════════
-- TRIP REPORTS
-- ═══════════════════════════════════════
CREATE POLICY "Non-removed reports are viewable"
  ON trip_reports FOR SELECT USING (is_removed = false);

CREATE POLICY "Authenticated users can create reports"
  ON trip_reports FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update own reports"
  ON trip_reports FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can delete own reports"
  ON trip_reports FOR DELETE USING (auth.uid() = author_id);

-- ═══════════════════════════════════════
-- SERVICE CENTERS (read-only)
-- ═══════════════════════════════════════
CREATE POLICY "Published services are viewable"
  ON service_centers FOR SELECT USING (is_published = true);

-- ═══════════════════════════════════════
-- BOOKMARKS (private per user)
-- ═══════════════════════════════════════
CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create bookmarks"
  ON bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE USING (auth.uid() = user_id);

-- ═══════════════════════════════════════
-- HELPFUL VOTES (private per user)
-- ═══════════════════════════════════════
CREATE POLICY "Users can view own votes"
  ON helpful_votes FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create votes"
  ON helpful_votes FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own votes"
  ON helpful_votes FOR DELETE USING (auth.uid() = user_id);

-- ═══════════════════════════════════════
-- CONTENT REPORTS (write-only for users, admins read)
-- ═══════════════════════════════════════
CREATE POLICY "Users can create content reports"
  ON content_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- Users can view their own reports
CREATE POLICY "Users can view own content reports"
  ON content_reports FOR SELECT USING (auth.uid() = reporter_id);

-- ═══════════════════════════════════════
-- COMMUNITY PHOTOS
-- ═══════════════════════════════════════
CREATE POLICY "Non-removed photos are viewable"
  ON community_photos FOR SELECT USING (is_removed = false);

CREATE POLICY "Users can upload photos"
  ON community_photos FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can delete own photos"
  ON community_photos FOR DELETE USING (auth.uid() = author_id);

-- ═══════════════════════════════════════
-- CRISIS TAPS (anonymous, write-only)
-- ═══════════════════════════════════════
CREATE POLICY "Anyone can log a crisis tap"
  ON crisis_taps FOR INSERT WITH CHECK (true);

-- Admins read via service_role
```

---

## 4. Storage Bucket Policies

```sql
-- ═══════════════════════════════════════
-- AVATARS BUCKET
-- ═══════════════════════════════════════
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, -- 2MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- Users can upload their own avatar: avatars/{user_id}/*
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update/delete their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Public read (avatars are public)
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- ═══════════════════════════════════════
-- COMMUNITY PHOTOS BUCKET
-- ═══════════════════════════════════════
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('community-photos', 'community-photos', true, 5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- Users upload to: community-photos/{user_id}/{strain_id}/*
CREATE POLICY "Users can upload community photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'community-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own community photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'community-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Community photos are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community-photos');

-- ═══════════════════════════════════════
-- STRAIN HEROES BUCKET (admin-only write)
-- ═══════════════════════════════════════
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('strain-heroes', 'strain-heroes', true, 10485760, -- 10MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- Public read only (admin uploads via service_role)
CREATE POLICY "Strain heroes are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'strain-heroes');
```

---

## 5. Client-Side Code Snippets (Swift)

### Package Dependency
```swift
// Package.swift or Xcode SPM
.package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
```

### Supabase Client Singleton
```swift
// SupabaseManager.swift
import Supabase
import Foundation

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://YOUR_PROJECT.supabase.co")!,
        supabaseKey: "YOUR_ANON_KEY"
    )
}
```

### Auth — Sign in with Apple
```swift
// AuthService.swift
import AuthenticationServices
import Supabase

@Observable
@MainActor
final class AuthService {
    var session: Session?
    var profile: Profile?
    var isAuthenticated: Bool { session != nil }
    
    private let client = SupabaseManager.client
    
    init() {
        Task { await restoreSession() }
    }
    
    func restoreSession() async {
        do {
            session = try await client.auth.session
            if let userId = session?.user.id {
                profile = try await fetchProfile(userId)
            }
        } catch {
            session = nil
        }
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        self.session = session
        self.profile = try await fetchProfile(session.user.id)
    }
    
    func signInWithEmail(_ email: String, password: String) async throws {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        self.session = session
        self.profile = try await fetchProfile(session.user.id)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws {
        let session = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(displayName)]
        )
        self.session = session.session
        self.profile = try await fetchProfile(session.session!.user.id)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        session = nil
        profile = nil
    }
    
    private func fetchProfile(_ userId: UUID) async throws -> Profile {
        try await client.from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
}
```

### API Calls — Fetch Strains
```swift
// StrainRepository.swift
import Supabase

struct StrainRepository {
    private let client = SupabaseManager.client
    
    func fetchAll() async throws -> [Strain] {
        try await client.from("strains")
            .select("*, strain_stats(*)")
            .eq("is_published", value: true)
            .order("name")
            .execute()
            .value
    }
    
    func fetchBySubstance(_ type: String) async throws -> [Strain] {
        try await client.from("strains")
            .select("*, strain_stats(*)")
            .eq("is_published", value: true)
            .eq("parent_substance", value: type)
            .execute()
            .value
    }
    
    func search(_ query: String) async throws -> [Strain] {
        try await client.from("strains")
            .select("*, strain_stats(*)")
            .eq("is_published", value: true)
            .ilike("name", pattern: "%\(query)%")
            .execute()
            .value
    }
}
```

### API Calls — Reviews & Trip Reports
```swift
// ReviewRepository.swift
struct ReviewRepository {
    private let client = SupabaseManager.client
    
    func fetchForStrain(_ strainId: UUID) async throws -> [Review] {
        try await client.from("reviews")
            .select("*, profiles(display_name, avatar_url)")
            .eq("strain_id", value: strainId)
            .eq("is_removed", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func create(_ review: ReviewInsert) async throws {
        try await client.from("reviews")
            .insert(review)
            .execute()
    }
    
    func markHelpful(_ reviewId: UUID, userId: UUID) async throws {
        // Insert vote (unique constraint prevents doubles)
        try await client.from("helpful_votes")
            .insert(["user_id": userId.uuidString, "review_id": reviewId.uuidString])
            .execute()
        
        // Increment count via RPC
        try await client.rpc("increment_helpful", params: ["review_id": reviewId.uuidString])
            .execute()
    }
}

// TripReportRepository.swift
struct TripReportRepository {
    private let client = SupabaseManager.client
    
    func fetchForStrain(_ strainId: UUID) async throws -> [TripReport] {
        try await client.from("trip_reports")
            .select("*, profiles(display_name, avatar_url)")
            .eq("strain_id", value: strainId)
            .eq("is_removed", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func create(_ report: TripReportInsert) async throws {
        try await client.from("trip_reports")
            .insert(report)
            .execute()
    }
}
```

### API Calls — Bookmarks
```swift
// BookmarkRepository.swift
struct BookmarkRepository {
    private let client = SupabaseManager.client
    
    func fetchAll(userId: UUID) async throws -> [Bookmark] {
        try await client.from("bookmarks")
            .select("*, strains(*, strain_stats(*))")
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func toggle(userId: UUID, strainId: UUID) async throws -> Bool {
        // Check if exists
        let existing: [Bookmark] = try await client.from("bookmarks")
            .select()
            .eq("user_id", value: userId)
            .eq("strain_id", value: strainId)
            .execute()
            .value
        
        if let bookmark = existing.first {
            try await client.from("bookmarks")
                .delete()
                .eq("id", value: bookmark.id)
                .execute()
            return false // removed
        } else {
            try await client.from("bookmarks")
                .insert(["user_id": userId.uuidString, "strain_id": strainId.uuidString])
                .execute()
            return true // added
        }
    }
}
```

### File Uploads — Avatar
```swift
// StorageService.swift
import Supabase

struct StorageService {
    private let client = SupabaseManager.client
    
    func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString)/avatar.jpg"
        
        try await client.storage.from("avatars")
            .upload(
                path: path,
                file: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
        
        let publicURL = try client.storage.from("avatars").getPublicURL(path: path)
        
        // Update profile
        try await client.from("profiles")
            .update(["avatar_url": publicURL.absoluteString])
            .eq("id", value: userId)
            .execute()
        
        return publicURL.absoluteString
    }
    
    func uploadCommunityPhoto(
        userId: UUID,
        strainId: UUID,
        imageData: Data,
        caption: String?
    ) async throws {
        let filename = "\(UUID().uuidString).jpg"
        let path = "\(userId.uuidString)/\(strainId.uuidString)/\(filename)"
        
        try await client.storage.from("community-photos")
            .upload(
                path: path,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        // Create DB record
        try await client.from("community_photos")
            .insert([
                "author_id": userId.uuidString,
                "strain_id": strainId.uuidString,
                "storage_path": path,
                "caption": caption ?? ""
            ])
            .execute()
    }
}
```

---

## 6. Edge Functions

### `moderate-content` — Auto-flag harmful UGC
```typescript
// supabase/functions/moderate-content/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const BANNED_PATTERNS = [
  /\bdos(age|ing|e)\b/i,           // dosage advice
  /\bhow\s+(much|to)\s+(take|use|consume)\b/i,
  /\brecreational\b/i,
  /\bget\s+(high|fucked|wasted)\b/i,
  /\bparty\b/i,
  /\bforaging\b/i,                  // foraging encouragement
  /\bgrow(ing)?\s+(your|at)\b/i,   // cultivation advice
]

serve(async (req) => {
  const { record, table } = await req.json()
  
  const textToCheck = table === 'reviews' 
    ? `${record.title} ${record.body}`
    : `${record.highlights} ${record.safety_notes || ''} ${record.intention || ''}`
  
  const flagged = BANNED_PATTERNS.some(p => p.test(textToCheck))
  
  if (flagged) {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // Auto-flag for review
    await supabase.from(table)
      .update({ is_reported: true })
      .eq('id', record.id)
    
    // Create moderation report
    await supabase.from('content_reports')
      .insert({
        reporter_id: '00000000-0000-0000-0000-000000000000', // system
        [table === 'reviews' ? 'review_id' : 'trip_report_id']: record.id,
        reason: 'harmful',
        details: 'Auto-flagged by content moderator',
        status: 'pending'
      })
  }
  
  return new Response(JSON.stringify({ flagged }), {
    headers: { "Content-Type": "application/json" }
  })
})
```

**Trigger:** Database webhook on INSERT to `reviews` and `trip_reports`.

### `increment-helpful` — Atomic helpful count
```sql
-- RPC function (not edge function, runs in Postgres)
CREATE OR REPLACE FUNCTION increment_helpful(review_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE reviews
  SET helpful_count = helpful_count + 1
  WHERE id = review_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### `daily-stats` — Optional analytics aggregation (cron)
```typescript
// supabase/functions/daily-stats/index.ts
// Runs on schedule: every day at midnight UTC
// Aggregates: new users, reviews, reports, crisis taps
// Writes to an admin_stats table for dashboard
```

---

## 7. Migration Plan (v1 → v2)

### Phase 1: Add Supabase SDK (non-breaking)
- Add `supabase-swift` SPM dependency
- Create `SupabaseManager`, repositories, `AuthService`
- Keep MockData as fallback — if fetch fails, show cached mock data
- **No UI changes yet**

### Phase 2: Auth integration
- Add Sign in with Apple + email/password
- Wire auth into ProfileView
- Guest browsing still works (no auth required for reading)
- UGC prompts sign-in

### Phase 3: Live data
- Seed Supabase with current MockData content
- Swap `AppState` data sources: MockData → repositories
- Bookmarks sync to server (with local UserDefaults cache for offline)
- Reviews + reports write to Supabase

### Phase 4: New features
- Community photos upload
- Real service center locations (CoreLocation)
- Push notifications (Supabase Realtime or APNs)
- Content moderation edge function live

### Estimated effort: 5-7 days total across all phases

---

## 8. Cost Estimate (Supabase)

| Tier | Monthly | Gets You |
|---|---|---|
| **Free** | $0 | 500MB DB, 1GB storage, 2GB bandwidth, 500K edge invocations |
| **Pro** | $25 | 8GB DB, 100GB storage, 250GB bandwidth, 2M edge invocations |

For v1 launch with <10K users, the **free tier** is more than sufficient. Move to Pro when you hit storage or bandwidth limits.
