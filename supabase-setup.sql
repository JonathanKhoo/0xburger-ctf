-- Run this in Supabase SQL Editor after creating your project
-- 1. Create the content table
CREATE TABLE IF NOT EXISTS site_content (
  id SERIAL PRIMARY KEY,
  section TEXT UNIQUE NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security
ALTER TABLE site_content ENABLE ROW LEVEL SECURITY;

-- 3. Anyone can read (public site visitors)
CREATE POLICY "public_read" ON site_content
  FOR SELECT USING (true);

-- 4. Only authenticated users can insert/update/delete
CREATE POLICY "auth_write" ON site_content
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "auth_update" ON site_content
  FOR UPDATE USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "auth_delete" ON site_content
  FOR DELETE USING (auth.role() = 'authenticated');

-- 5. Seed default content (optional)
INSERT INTO site_content (section, content) VALUES
  ('writeups', '<div class="writeup-card" onclick="toast(''coming soon: writeups drop after next comp'',''info'')"><div class="writeup-icon">\U0001f3f4</div><div class="writeup-info"><h4>Writeups coming soon...</h4><div class="meta">stay tuned for fresh serves</div></div></div><div style="text-align:center;padding:20px"><span style="color:var(--dim);font-size:11px">grill is hot. content cooking. check back later.</span></div>')
ON CONFLICT (section) DO NOTHING;
