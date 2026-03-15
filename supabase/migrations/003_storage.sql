-- ═══════════════════════════════════════
-- TripTalk Storage Buckets Migration 003
-- ═══════════════════════════════════════

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('community-photos', 'community-photos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('strain-heroes', 'strain-heroes', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']);

-- AVATARS policies
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

-- COMMUNITY PHOTOS policies
CREATE POLICY "Users can upload community photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'community-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own community photos"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'community-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Community photos are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community-photos');

-- STRAIN HEROES (admin-only write, public read)
CREATE POLICY "Strain heroes are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'strain-heroes');
