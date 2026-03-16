-- ═══════════════════════════════════════
-- TripTalk FULL Migration (reset + rebuild)
-- Run this single file in Supabase SQL Editor
-- ═══════════════════════════════════════

-- ╔═══════════════════════════════════════╗
-- ║  STEP 0: NUKE EVERYTHING             ║
-- ╚═══════════════════════════════════════╝

DROP VIEW IF EXISTS strain_stats CASCADE;
DROP FUNCTION IF EXISTS increment_helpful CASCADE;
DROP FUNCTION IF EXISTS handle_new_user CASCADE;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TABLE IF EXISTS crisis_taps CASCADE;
DROP TABLE IF EXISTS community_photos CASCADE;
DROP TABLE IF EXISTS content_reports CASCADE;
DROP TABLE IF EXISTS helpful_votes CASCADE;
DROP TABLE IF EXISTS bookmarks CASCADE;
DROP TABLE IF EXISTS trip_reports CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS service_centers CASCADE;
DROP TABLE IF EXISTS strains CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Storage policy cleanup (buckets managed via API, skip delete)
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Avatars are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload community photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own community photos" ON storage.objects;
DROP POLICY IF EXISTS "Community photos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Strain heroes are publicly accessible" ON storage.objects;

-- ╔═══════════════════════════════════════╗
-- ║  STEP 1: SCHEMA                      ║
-- ╚═══════════════════════════════════════╝

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
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reviews_strain ON reviews(strain_id) WHERE is_removed = false;
CREATE INDEX idx_reviews_author ON reviews(author_id);
CREATE INDEX idx_reviews_created ON reviews(created_at DESC);

CREATE TABLE trip_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  setting TEXT NOT NULL CHECK (setting IN ('nature', 'home', 'ceremony', 'social', 'festival')),
  intention TEXT,
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

CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, strain_id)
);

CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);

CREATE TABLE helpful_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, review_id)
);

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

CREATE TABLE community_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  caption TEXT,
  is_removed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE crisis_taps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource TEXT NOT NULL CHECK (resource IN ('988_lifeline', 'fireside_project')),
  tapped_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

CREATE OR REPLACE FUNCTION increment_helpful(p_review_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE reviews
  SET helpful_count = helpful_count + 1
  WHERE id = p_review_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ╔═══════════════════════════════════════╗
-- ║  STEP 2: ROW LEVEL SECURITY          ║
-- ╚═══════════════════════════════════════╝

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

CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Published strains are viewable by everyone"
  ON strains FOR SELECT USING (is_published = true);

CREATE POLICY "Non-removed reviews are viewable"
  ON reviews FOR SELECT USING (is_removed = false);
CREATE POLICY "Authenticated users can create reviews"
  ON reviews FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own reviews"
  ON reviews FOR DELETE USING (auth.uid() = author_id);

CREATE POLICY "Non-removed reports are viewable"
  ON trip_reports FOR SELECT USING (is_removed = false);
CREATE POLICY "Authenticated users can create reports"
  ON trip_reports FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own reports"
  ON trip_reports FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own reports"
  ON trip_reports FOR DELETE USING (auth.uid() = author_id);

CREATE POLICY "Published services are viewable"
  ON service_centers FOR SELECT USING (is_published = true);

CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bookmarks"
  ON bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own votes"
  ON helpful_votes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create votes"
  ON helpful_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own votes"
  ON helpful_votes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can create content reports"
  ON content_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users can view own content reports"
  ON content_reports FOR SELECT USING (auth.uid() = reporter_id);

CREATE POLICY "Non-removed photos are viewable"
  ON community_photos FOR SELECT USING (is_removed = false);
CREATE POLICY "Users can upload photos"
  ON community_photos FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own photos"
  ON community_photos FOR DELETE USING (auth.uid() = author_id);

CREATE POLICY "Anyone can log a crisis tap"
  ON crisis_taps FOR INSERT WITH CHECK (true);

-- ╔═══════════════════════════════════════╗
-- ║  STEP 3: STORAGE BUCKETS             ║
-- ╚═══════════════════════════════════════╝

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('community-photos', 'community-photos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('strain-heroes', 'strain-heroes', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload community photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'community-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own community photos"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'community-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Community photos are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community-photos');

CREATE POLICY "Strain heroes are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'strain-heroes');
