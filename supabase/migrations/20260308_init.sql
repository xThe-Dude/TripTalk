-- TripTalk Schema v1
-- Supabase (PostgreSQL) with Row Level Security

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE substance_type AS ENUM (
    'psilocybin', 'ayahuasca', 'mescaline', 'ketamine'
);

CREATE TYPE potency_level AS ENUM (
    'mild', 'moderate', 'strong', 'very_strong'
);

CREATE TYPE difficulty_level AS ENUM (
    'beginner', 'intermediate', 'experienced'
);

CREATE TYPE trip_setting AS ENUM (
    'nature', 'home', 'ceremony', 'social', 'festival', 'clinical'
);

CREATE TYPE experience_type AS ENUM (
    'visual', 'physical', 'emotional', 'spiritual', 'dissociative'
);

-- ============================================================
-- PROFILES (extends Supabase auth.users)
-- ============================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Explorer',
    bio TEXT,
    experience_level TEXT DEFAULT 'curious', -- curious, novice, experienced, veteran
    jurisdiction TEXT DEFAULT 'Colorado',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', 'Explorer'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- VARIETIES (the core content — mushroom strains, ketamine forms, etc.)
-- ============================================================

CREATE TABLE varieties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    substance_type substance_type NOT NULL,
    species TEXT, -- "Psilocybe cubensis", "Ketamine HCl", etc.
    potency potency_level NOT NULL DEFAULT 'moderate',
    difficulty difficulty_level NOT NULL DEFAULT 'intermediate',
    description TEXT NOT NULL,
    onset TEXT, -- "30-60 min"
    duration TEXT, -- "4-6 hours"
    safety_notes TEXT,
    -- Effects stored as text arrays (flexible, no need for separate tables)
    common_effects TEXT[] DEFAULT '{}',
    body_feel TEXT[] DEFAULT '{}',
    emotional_profile TEXT[] DEFAULT '{}',
    -- Jurisdiction info
    legal_notes TEXT,
    -- Stats (denormalized for read performance)
    average_rating NUMERIC(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    photo_count INT DEFAULT 0,
    -- Metadata
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_varieties_substance ON varieties(substance_type);
CREATE INDEX idx_varieties_potency ON varieties(potency);
CREATE INDEX idx_varieties_difficulty ON varieties(difficulty);
CREATE INDEX idx_varieties_published ON varieties(is_published) WHERE is_published = true;

-- Full text search
ALTER TABLE varieties ADD COLUMN fts tsvector
    GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, '') || ' ' || coalesce(species, ''))
    ) STORED;
CREATE INDEX idx_varieties_fts ON varieties USING gin(fts);

-- ============================================================
-- VARIETY PHOTOS
-- ============================================================

CREATE TABLE variety_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variety_id UUID NOT NULL REFERENCES varieties(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    storage_path TEXT NOT NULL, -- path in Supabase Storage
    caption TEXT,
    is_hero BOOLEAN DEFAULT false, -- primary display photo
    is_approved BOOLEAN DEFAULT false, -- moderation gate
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_variety_photos_variety ON variety_photos(variety_id);

-- ============================================================
-- TRIP REPORTS
-- ============================================================

CREATE TABLE trip_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variety_id UUID NOT NULL REFERENCES varieties(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    -- Core rating
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    -- Context
    setting trip_setting,
    intention TEXT,
    -- Intensity ratings (1-5)
    visual_intensity INT CHECK (visual_intensity BETWEEN 1 AND 5),
    body_intensity INT CHECK (body_intensity BETWEEN 1 AND 5),
    emotional_intensity INT CHECK (emotional_intensity BETWEEN 1 AND 5),
    -- Tags
    experience_types experience_type[] DEFAULT '{}',
    moods TEXT[] DEFAULT '{}',
    -- Narrative
    highlights TEXT,
    safety_notes TEXT,
    would_repeat BOOLEAN,
    -- Moderation
    is_approved BOOLEAN DEFAULT false,
    is_flagged BOOLEAN DEFAULT false,
    flag_reason TEXT,
    -- Anti-sourcing attestation
    no_sourcing_confirmed BOOLEAN NOT NULL DEFAULT false,
    -- Stats
    helpful_count INT DEFAULT 0,
    report_count INT DEFAULT 0,
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_trip_reports_variety ON trip_reports(variety_id);
CREATE INDEX idx_trip_reports_user ON trip_reports(user_id);
CREATE INDEX idx_trip_reports_rating ON trip_reports(rating);
CREATE INDEX idx_trip_reports_approved ON trip_reports(is_approved) WHERE is_approved = true;

-- ============================================================
-- TRIP REPORT PHOTOS
-- ============================================================

CREATE TABLE trip_report_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_report_id UUID NOT NULL REFERENCES trip_reports(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- HELPFUL VOTES (prevent double-voting)
-- ============================================================

CREATE TABLE helpful_votes (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    trip_report_id UUID NOT NULL REFERENCES trip_reports(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, trip_report_id)
);

-- ============================================================
-- SAVED VARIETIES (bookmarks)
-- ============================================================

CREATE TABLE saved_varieties (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    variety_id UUID NOT NULL REFERENCES varieties(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, variety_id)
);

-- ============================================================
-- SERVICE CENTERS
-- ============================================================

CREATE TABLE service_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    phone TEXT,
    website TEXT,
    hours TEXT,
    -- Attributes
    offerings TEXT[] DEFAULT '{}',
    substance_types substance_type[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT false,
    is_claimed BOOLEAN DEFAULT false,
    -- Stats
    average_rating NUMERIC(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    -- Metadata
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_service_centers_city_state ON service_centers(state, city);
CREATE INDEX idx_service_centers_verified ON service_centers(is_verified) WHERE is_verified = true;

-- Full text search for services
ALTER TABLE service_centers ADD COLUMN fts tsvector
    GENERATED ALWAYS AS (
        to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, '') || ' ' || coalesce(city, '') || ' ' || coalesce(state, ''))
    ) STORED;
CREATE INDEX idx_service_centers_fts ON service_centers USING gin(fts);

-- ============================================================
-- SERVICE REVIEWS (separate from trip reports)
-- ============================================================

CREATE TABLE service_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_center_id UUID NOT NULL REFERENCES service_centers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    text TEXT,
    is_approved BOOLEAN DEFAULT false,
    no_sourcing_confirmed BOOLEAN NOT NULL DEFAULT false,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_service_reviews_center ON service_reviews(service_center_id);

-- ============================================================
-- CONTENT FLAGS (user reports for moderation)
-- ============================================================

CREATE TABLE content_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_type TEXT NOT NULL, -- 'trip_report', 'service_review', 'variety_photo'
    content_id UUID NOT NULL,
    reason TEXT NOT NULL, -- 'sourcing', 'inappropriate', 'inaccurate', 'spam'
    details TEXT,
    is_resolved BOOLEAN DEFAULT false,
    resolved_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE varieties ENABLE ROW LEVEL SECURITY;
ALTER TABLE variety_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_report_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_varieties ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_flags ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read all, update own
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Varieties: public read (published only)
CREATE POLICY "Published varieties are viewable" ON varieties FOR SELECT USING (is_published = true);

-- Variety photos: public read (approved only)
CREATE POLICY "Approved photos are viewable" ON variety_photos FOR SELECT USING (is_approved = true);
CREATE POLICY "Users can upload photos" ON variety_photos FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Trip reports: public read (approved), users can create/update own
CREATE POLICY "Approved reports are viewable" ON trip_reports FOR SELECT USING (is_approved = true);
CREATE POLICY "Users can create reports" ON trip_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reports" ON trip_reports FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reports" ON trip_reports FOR DELETE USING (auth.uid() = user_id);
-- Also let users see their own unapproved reports
CREATE POLICY "Users can see own reports" ON trip_reports FOR SELECT USING (auth.uid() = user_id);

-- Trip report photos
CREATE POLICY "Report photos are viewable" ON trip_report_photos FOR SELECT USING (true);
CREATE POLICY "Users can upload report photos" ON trip_report_photos FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM trip_reports WHERE id = trip_report_id AND user_id = auth.uid())
);

-- Helpful votes: users can vote
CREATE POLICY "Votes are viewable" ON helpful_votes FOR SELECT USING (true);
CREATE POLICY "Users can vote" ON helpful_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unvote" ON helpful_votes FOR DELETE USING (auth.uid() = user_id);

-- Saved varieties: private to user
CREATE POLICY "Users can see own saves" ON saved_varieties FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can save" ON saved_varieties FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unsave" ON saved_varieties FOR DELETE USING (auth.uid() = user_id);

-- Service centers: public read
CREATE POLICY "Published services are viewable" ON service_centers FOR SELECT USING (is_published = true);

-- Service reviews: public read (approved), users can create
CREATE POLICY "Approved service reviews are viewable" ON service_reviews FOR SELECT USING (is_approved = true);
CREATE POLICY "Users can create service reviews" ON service_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can see own service reviews" ON service_reviews FOR SELECT USING (auth.uid() = user_id);

-- Content flags: users can create, only see own
CREATE POLICY "Users can flag content" ON content_flags FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users can see own flags" ON content_flags FOR SELECT USING (auth.uid() = reporter_id);

-- ============================================================
-- FUNCTIONS: Update denormalized stats
-- ============================================================

CREATE OR REPLACE FUNCTION update_variety_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE varieties SET
        average_rating = (SELECT COALESCE(AVG(rating), 0) FROM trip_reports WHERE variety_id = COALESCE(NEW.variety_id, OLD.variety_id) AND is_approved = true),
        review_count = (SELECT COUNT(*) FROM trip_reports WHERE variety_id = COALESCE(NEW.variety_id, OLD.variety_id) AND is_approved = true),
        updated_at = now()
    WHERE id = COALESCE(NEW.variety_id, OLD.variety_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_trip_report_change
    AFTER INSERT OR UPDATE OR DELETE ON trip_reports
    FOR EACH ROW EXECUTE FUNCTION update_variety_stats();

CREATE OR REPLACE FUNCTION update_service_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE service_centers SET
        average_rating = (SELECT COALESCE(AVG(rating), 0) FROM service_reviews WHERE service_center_id = COALESCE(NEW.service_center_id, OLD.service_center_id) AND is_approved = true),
        review_count = (SELECT COUNT(*) FROM service_reviews WHERE service_center_id = COALESCE(NEW.service_center_id, OLD.service_center_id) AND is_approved = true),
        updated_at = now()
    WHERE id = COALESCE(NEW.service_center_id, OLD.service_center_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_service_review_change
    AFTER INSERT OR UPDATE OR DELETE ON service_reviews
    FOR EACH ROW EXECUTE FUNCTION update_service_stats();

-- Update helpful count
CREATE OR REPLACE FUNCTION update_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE trip_reports SET
        helpful_count = (SELECT COUNT(*) FROM helpful_votes WHERE trip_report_id = COALESCE(NEW.trip_report_id, OLD.trip_report_id))
    WHERE id = COALESCE(NEW.trip_report_id, OLD.trip_report_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_helpful_vote_change
    AFTER INSERT OR DELETE ON helpful_votes
    FOR EACH ROW EXECUTE FUNCTION update_helpful_count();
