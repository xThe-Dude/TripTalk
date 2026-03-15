-- ═══════════════════════════════════════
-- TripTalk RLS Policies Migration 002
-- ═══════════════════════════════════════

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

-- PROFILES
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- STRAINS (public read)
CREATE POLICY "Published strains are viewable by everyone"
  ON strains FOR SELECT USING (is_published = true);

-- REVIEWS
CREATE POLICY "Non-removed reviews are viewable"
  ON reviews FOR SELECT USING (is_removed = false);
CREATE POLICY "Authenticated users can create reviews"
  ON reviews FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own reviews"
  ON reviews FOR DELETE USING (auth.uid() = author_id);

-- TRIP REPORTS
CREATE POLICY "Non-removed reports are viewable"
  ON trip_reports FOR SELECT USING (is_removed = false);
CREATE POLICY "Authenticated users can create reports"
  ON trip_reports FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own reports"
  ON trip_reports FOR UPDATE USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own reports"
  ON trip_reports FOR DELETE USING (auth.uid() = author_id);

-- SERVICE CENTERS (public read)
CREATE POLICY "Published services are viewable"
  ON service_centers FOR SELECT USING (is_published = true);

-- BOOKMARKS (private)
CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bookmarks"
  ON bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own bookmarks"
  ON bookmarks FOR DELETE USING (auth.uid() = user_id);

-- HELPFUL VOTES (private)
CREATE POLICY "Users can view own votes"
  ON helpful_votes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create votes"
  ON helpful_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own votes"
  ON helpful_votes FOR DELETE USING (auth.uid() = user_id);

-- CONTENT REPORTS (write-only for users)
CREATE POLICY "Users can create content reports"
  ON content_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users can view own content reports"
  ON content_reports FOR SELECT USING (auth.uid() = reporter_id);

-- COMMUNITY PHOTOS
CREATE POLICY "Non-removed photos are viewable"
  ON community_photos FOR SELECT USING (is_removed = false);
CREATE POLICY "Users can upload photos"
  ON community_photos FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own photos"
  ON community_photos FOR DELETE USING (auth.uid() = author_id);

-- CRISIS TAPS (anonymous write)
CREATE POLICY "Anyone can log a crisis tap"
  ON crisis_taps FOR INSERT WITH CHECK (true);
