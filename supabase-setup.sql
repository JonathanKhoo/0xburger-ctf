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

-- 3. Disable public sign-ups (run this in SQL Editor)
-- ALTER ROLE authenticator SET pgrst.jwt_role_claim_key = 'app_metadata';
