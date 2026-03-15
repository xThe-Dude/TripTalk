-- ═══════════════════════════════════════
-- TripTalk Schema Migration 001
-- ═══════════════════════════════════════

-- PROFILES
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

-- STRAINS
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

-- REVIEWS
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID REFERENCES strains(id) ON DELETE CASCADE,
  service_id UUID,
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

-- TRIP REPORTS
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

-- SERVICE CENTERS
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

-- Add FK to reviews now that service_centers exists
ALTER TABLE reviews
  ADD CONSTRAINT reviews_service_id_fkey
  FOREIGN KEY (service_id) REFERENCES service_centers(id) ON DELETE CASCADE;

-- BOOKMARKS
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, strain_id)
);

CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);

-- HELPFUL VOTES
CREATE TABLE helpful_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, review_id)
);

-- CONTENT REPORTS
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

-- COMMUNITY PHOTOS
CREATE TABLE community_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strain_id UUID NOT NULL REFERENCES strains(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  caption TEXT,
  is_removed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- CRISIS TAPS (anonymous safety metric)
CREATE TABLE crisis_taps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource TEXT NOT NULL CHECK (resource IN ('988_lifeline', 'fireside_project')),
  tapped_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STRAIN STATS VIEW
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

-- INCREMENT HELPFUL RPC
CREATE OR REPLACE FUNCTION increment_helpful(p_review_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE reviews
  SET helpful_count = helpful_count + 1
  WHERE id = p_review_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
