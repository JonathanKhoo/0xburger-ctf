-- Run this in Supabase SQL Editor
-- If table doesn't exist yet, create it:
CREATE TABLE IF NOT EXISTS site_content (
  id SERIAL PRIMARY KEY,
  section TEXT UNIQUE NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by TEXT
);

-- If table exists but missing the column, add it:
ALTER TABLE site_content ADD COLUMN IF NOT EXISTS updated_by TEXT;

-- Enable RLS (idempotent)
ALTER TABLE site_content ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies (safe to re-run)
DO $$ BEGIN
  DROP POLICY IF EXISTS "public_read" ON site_content;
  DROP POLICY IF EXISTS "auth_write" ON site_content;
  DROP POLICY IF EXISTS "auth_update" ON site_content;
  DROP POLICY IF EXISTS "auth_delete" ON site_content;
END $$;

CREATE POLICY "public_read" ON site_content FOR SELECT USING (true);
CREATE POLICY "auth_write" ON site_content FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "auth_update" ON site_content FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "auth_delete" ON site_content FOR DELETE USING (auth.role() = 'authenticated');
