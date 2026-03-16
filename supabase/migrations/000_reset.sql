-- Drop everything in reverse dependency order
DROP VIEW IF EXISTS strain_stats CASCADE;
DROP FUNCTION IF EXISTS increment_helpful CASCADE;
DROP FUNCTION IF EXISTS handle_new_user CASCADE;
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

-- Drop storage buckets
DELETE FROM storage.objects WHERE bucket_id IN ('avatars', 'community-photos', 'strain-heroes');
DELETE FROM storage.buckets WHERE id IN ('avatars', 'community-photos', 'strain-heroes');

-- Drop storage policies (ignore errors if they don't exist)
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Avatars are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload community photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own community photos" ON storage.objects;
DROP POLICY IF EXISTS "Community photos are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Strain heroes are publicly accessible" ON storage.objects;
