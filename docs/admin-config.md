# Admin Config

The public bundle does not contain the Supabase URL, anon key, or flag hashes.

For local admin testing, create an ignored file at the repo root:

```json
{
  "supabaseUrl": "https://YOUR_PROJECT.supabase.co",
  "supabaseAnonKey": "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY",
  "flagCheckUrl": "https://YOUR_PROJECT.supabase.co/functions/v1/check-flag"
}
```

Name it:

```text
admin-config.json
```

That file is ignored by Git.

## Flag Checker Backend

Deploy the Supabase Edge Function without JWT verification. The function enforces origin checks and rate limits itself, because players are anonymous:

```powershell
supabase functions deploy check-flag --project-ref YOUR_PROJECT_REF --no-verify-jwt
```

Set the private flag hashes as a Supabase secret:

```powershell
supabase secrets set --project-ref YOUR_PROJECT_REF FLAG_HASHES_JSON='<private-json-map-of-category-to-sha256>'
```

Run `supabase-setup.sql` in the SQL Editor so `flag_submissions` exists.

## Security Headers

`index.html` includes a meta CSP and referrer policy for GitHub Pages.

`_headers` is included for hosts that support static header files, such as Cloudflare Pages or Netlify. GitHub Pages ignores `_headers`, so `Permissions-Policy` and `X-Content-Type-Options` require moving the static frontend behind a host/proxy that can set real HTTP headers.

## Important GitHub Pages Note

A purely static GitHub Pages site cannot both hide browser-used Supabase admin config and use Supabase admin editing directly from the browser. If a config file is deployed publicly, players can fetch it.

For a public CTF answer checker, the Edge Function is the secure boundary: flags/hashes stay in Supabase secrets, and the browser only receives `correct/wrong` plus the solved category.

For admin editing, secure options are:

1. Keep admin editing local/private only, then deploy generated content.
2. Move admin to a private backend/API proxy.
3. Host admin on a protected platform route outside GitHub Pages.

RLS still remains the real database write boundary.
