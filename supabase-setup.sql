-- ============================================
-- 0xBURGER Supabase Setup (Enterprise)
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Content table
CREATE TABLE IF NOT EXISTS site_content (
  id SERIAL PRIMARY KEY,
  section TEXT UNIQUE NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by TEXT
);

-- 2. Row Level Security
ALTER TABLE site_content ENABLE ROW LEVEL SECURITY;

-- Drop old policies (safe to re-run)
DO $$ BEGIN
  DROP POLICY IF EXISTS "public_read" ON site_content;
  DROP POLICY IF EXISTS "auth_write" ON site_content;
  DROP POLICY IF EXISTS "auth_update" ON site_content;
  DROP POLICY IF EXISTS "auth_delete" ON site_content;
  DROP POLICY IF EXISTS "admin_insert" ON site_content;
  DROP POLICY IF EXISTS "admin_update" ON site_content;
  DROP POLICY IF EXISTS "admin_delete" ON site_content;
END $$;

-- Public can read (site visitors)
CREATE POLICY "public_read" ON site_content FOR SELECT USING (true);

-- Only admins can write (checks JWT app_metadata)
CREATE POLICY "admin_insert" ON site_content FOR INSERT
  WITH CHECK (auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin'));

CREATE POLICY "admin_update" ON site_content FOR UPDATE
  USING (auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin'))
  WITH CHECK (auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin'));

CREATE POLICY "admin_delete" ON site_content FOR DELETE
  USING (auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin'));

-- 3. Writeup document uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'writeups',
  'writeups',
  true,
  15728640,
  ARRAY[
    'application/pdf',
    'text/markdown',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DO $$ BEGIN
  DROP POLICY IF EXISTS "writeups_public_read" ON storage.objects;
  DROP POLICY IF EXISTS "writeups_admin_insert" ON storage.objects;
  DROP POLICY IF EXISTS "writeups_admin_update" ON storage.objects;
  DROP POLICY IF EXISTS "writeups_admin_delete" ON storage.objects;
END $$;

CREATE POLICY "writeups_public_read" ON storage.objects FOR SELECT
  USING (bucket_id = 'writeups');

CREATE POLICY "writeups_admin_insert" ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'writeups'
    AND auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin')
  );

CREATE POLICY "writeups_admin_update" ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'writeups'
    AND auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin')
  )
  WITH CHECK (
    bucket_id = 'writeups'
    AND auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin')
  );

CREATE POLICY "writeups_admin_delete" ON storage.objects FOR DELETE
  USING (
    bucket_id = 'writeups'
    AND auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin')
  );

-- 4. Hidden flag submission logs
CREATE TABLE IF NOT EXISTS flag_submissions (
  id BIGSERIAL PRIMARY KEY,
  category TEXT,
  correct BOOLEAN NOT NULL DEFAULT false,
  submitted_hash TEXT NOT NULL,
  user_agent TEXT,
  ip_hint TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE flag_submissions ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS flag_submissions_ip_created_idx
  ON flag_submissions (ip_hint, created_at DESC);

CREATE INDEX IF NOT EXISTS flag_submissions_correct_created_idx
  ON flag_submissions (correct, created_at DESC);

DO $$ BEGIN
  DROP POLICY IF EXISTS "flag_submissions_admin_read" ON flag_submissions;
END $$;

CREATE POLICY "flag_submissions_admin_read" ON flag_submissions FOR SELECT
  USING (auth.jwt() -> 'app_metadata' ->> 'role' IN ('admin','superadmin'));

-- Inserts are done by the Edge Function with the service role key.

-- 5. Disable public sign-ups (run this in SQL Editor)
-- ALTER ROLE authenticator SET pgrst.jwt_role_claim_key = 'app_metadata';
