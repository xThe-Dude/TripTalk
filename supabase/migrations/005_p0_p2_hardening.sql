-- ═══════════════════════════════════════════════════
-- TripTalk P0 + P2 Hardening Migration
-- Run in Supabase SQL Editor AFTER base schema exists
-- Safe to run multiple times (uses IF NOT EXISTS / OR REPLACE)
-- ═══════════════════════════════════════════════════


-- ╔═══════════════════════════════════════╗
-- ║  P0: Account Deletion (Apple req)    ║
-- ╚═══════════════════════════════════════╝

-- App calls: client.rpc("delete_own_account")
-- Deletes profile + all user content, then removes auth user.
-- CASCADE on profiles handles reviews, reports, photos, etc.

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Delete profile (cascades to reviews, trip_reports, bookmarks,
  -- helpful_votes, content_reports, community_photos)
  DELETE FROM public.profiles WHERE id = auth.uid();

  -- Remove the auth user entirely
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- Lock down access: only authenticated users can call this
REVOKE EXECUTE ON FUNCTION public.delete_own_account() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.delete_own_account() FROM anon;
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;


-- ╔═══════════════════════════════════════╗
-- ║  P0: Auto-moderate on report count   ║
-- ╚═══════════════════════════════════════╝

-- Auto-remove content after 3 reports
CREATE OR REPLACE FUNCTION public.auto_moderate_on_report()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  report_count INT;
BEGIN
  -- Count reports for this piece of content
  IF NEW.review_id IS NOT NULL THEN
    SELECT COUNT(*) INTO report_count
    FROM content_reports WHERE review_id = NEW.review_id;

    IF report_count >= 3 THEN
      UPDATE reviews SET is_removed = true, removed_reason = 'auto_moderated'
      WHERE id = NEW.review_id AND is_removed = false;
    END IF;

  ELSIF NEW.trip_report_id IS NOT NULL THEN
    SELECT COUNT(*) INTO report_count
    FROM content_reports WHERE trip_report_id = NEW.trip_report_id;

    IF report_count >= 3 THEN
      UPDATE trip_reports SET is_removed = true, removed_reason = 'auto_moderated'
      WHERE id = NEW.trip_report_id AND is_removed = false;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_auto_moderate ON content_reports;
CREATE TRIGGER trg_auto_moderate
  AFTER INSERT ON content_reports
  FOR EACH ROW
  EXECUTE FUNCTION auto_moderate_on_report();


-- ╔═══════════════════════════════════════╗
-- ║  P0: Ban enforcement via RLS         ║
-- ╚═══════════════════════════════════════╝

-- Banned users can't create reviews
DROP POLICY IF EXISTS "Authenticated users can create reviews" ON reviews;
CREATE POLICY "Authenticated users can create reviews"
  ON reviews FOR INSERT
  WITH CHECK (
    auth.uid() = author_id
    AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = true)
  );

-- Banned users can't create trip reports
DROP POLICY IF EXISTS "Authenticated users can create reports" ON trip_reports;
CREATE POLICY "Authenticated users can create reports"
  ON trip_reports FOR INSERT
  WITH CHECK (
    auth.uid() = author_id
    AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = true)
  );

-- Banned users can't upload photos
DROP POLICY IF EXISTS "Users can upload photos" ON community_photos;
CREATE POLICY "Users can upload photos"
  ON community_photos FOR INSERT
  WITH CHECK (
    auth.uid() = author_id
    AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_banned = true)
  );


-- ╔═══════════════════════════════════════╗
-- ║  P0: Sanitize user input triggers    ║
-- ╚═══════════════════════════════════════╝

CREATE OR REPLACE FUNCTION public.sanitize_profile()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.display_name := LEFT(TRIM(NEW.display_name), 50);
  NEW.bio := LEFT(TRIM(NEW.bio), 500);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sanitize_profile ON profiles;
CREATE TRIGGER trg_sanitize_profile
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION sanitize_profile();


-- ╔═══════════════════════════════════════╗
-- ║  P2: Constraint + indexes            ║
-- ╚═══════════════════════════════════════╝

-- Reviews must target exactly one entity (strain or service)
-- Note: column is strain_id/service_id (no substance_id in current schema)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'reviews' AND column_name = 'substance_id'
  ) THEN
    ALTER TABLE reviews DROP CONSTRAINT IF EXISTS reviews_exactly_one_target;
    ALTER TABLE reviews ADD CONSTRAINT reviews_exactly_one_target
      CHECK (num_nonnulls(substance_id, service_id, strain_id) = 1);
  ELSE
    ALTER TABLE reviews DROP CONSTRAINT IF EXISTS reviews_exactly_one_target;
    ALTER TABLE reviews ADD CONSTRAINT reviews_exactly_one_target
      CHECK (num_nonnulls(service_id, strain_id) = 1);
  END IF;
END $$;

-- Partial indexes for filtered queries
CREATE INDEX IF NOT EXISTS idx_reviews_not_removed
  ON reviews (created_at DESC) WHERE is_removed = false;
CREATE INDEX IF NOT EXISTS idx_trip_reports_not_removed
  ON trip_reports (created_at DESC) WHERE is_removed = false;
CREATE INDEX IF NOT EXISTS idx_community_photos_not_removed
  ON community_photos (created_at DESC) WHERE is_removed = false;


-- ╔═══════════════════════════════════════╗
-- ║  P2: Rate limiting triggers          ║
-- ╚═══════════════════════════════════════╝

-- Max 5 reviews per 24h
CREATE OR REPLACE FUNCTION public.check_review_rate_limit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  recent_count INT;
BEGIN
  SELECT COUNT(*) INTO recent_count
  FROM reviews
  WHERE author_id = NEW.author_id
    AND created_at > now() - interval '24 hours';

  IF recent_count >= 5 THEN
    RAISE EXCEPTION 'Rate limit exceeded: maximum 5 reviews per 24 hours';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_review_rate_limit ON reviews;
CREATE TRIGGER trg_review_rate_limit
  BEFORE INSERT ON reviews
  FOR EACH ROW EXECUTE FUNCTION check_review_rate_limit();

-- Max 5 trip reports per 24h
CREATE OR REPLACE FUNCTION public.check_trip_report_rate_limit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  recent_count INT;
BEGIN
  SELECT COUNT(*) INTO recent_count
  FROM trip_reports
  WHERE author_id = NEW.author_id
    AND created_at > now() - interval '24 hours';

  IF recent_count >= 5 THEN
    RAISE EXCEPTION 'Rate limit exceeded: maximum 5 trip reports per 24 hours';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_trip_report_rate_limit ON trip_reports;
CREATE TRIGGER trg_trip_report_rate_limit
  BEFORE INSERT ON trip_reports
  FOR EACH ROW EXECUTE FUNCTION check_trip_report_rate_limit();

-- Max 10 content reports per 24h
CREATE OR REPLACE FUNCTION public.check_report_rate_limit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  recent_count INT;
BEGIN
  SELECT COUNT(*) INTO recent_count
  FROM content_reports
  WHERE reporter_id = NEW.reporter_id
    AND created_at > now() - interval '24 hours';

  IF recent_count >= 10 THEN
    RAISE EXCEPTION 'Rate limit exceeded: maximum 10 reports per 24 hours';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_report_rate_limit ON content_reports;
CREATE TRIGGER trg_report_rate_limit
  BEFORE INSERT ON content_reports
  FOR EACH ROW EXECUTE FUNCTION check_report_rate_limit();


-- ═══════════════════════════════════════════════════
-- Done! All P0 (account deletion, auto-moderation,
-- ban enforcement, input sanitization) and P2
-- (rate limiting, indexes, constraints) applied.
-- ═══════════════════════════════════════════════════
