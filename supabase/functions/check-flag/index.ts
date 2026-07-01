const ALLOWED_ORIGINS = new Set([
  'https://jonathankhoo.github.io',
  'http://localhost:8765',
  'http://127.0.0.1:8765',
  'null',
]);

const enc = new TextEncoder();
const attempts = new Map<string, number[]>();

function originFor(req: Request) {
  const origin = req.headers.get('origin') || '';
  if (!origin) return '';
  return ALLOWED_ORIGINS.has(origin) ? origin : null;
}

function headersFor(origin: string) {
  const headers = new Headers({
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
    'Vary': 'Origin',
  });
  if (origin) headers.set('Access-Control-Allow-Origin', origin);
  return headers;
}

async function sha256Hex(value: string) {
  const digest = await crypto.subtle.digest('SHA-256', enc.encode(value.trim()));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function json(body: unknown, status = 200, origin = '') {
  return new Response(JSON.stringify(body), {
    status,
    headers: headersFor(origin),
  });
}

function secretMap(): Record<string, string | undefined> {
  const direct = {
    crypto: Deno.env.get('FLAG_CRYPTO_HASH'),
    misc: Deno.env.get('FLAG_MISC_HASH'),
    reverse: Deno.env.get('FLAG_REVERSE_HASH'),
  };
  if (direct.crypto || direct.misc || direct.reverse) return direct;

  const raw = Deno.env.get('FLAG_HASHES_JSON') || '{}';
  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function clientKey(req: Request) {
  return (req.headers.get('cf-connecting-ip') || req.headers.get('x-forwarded-for') || 'anon')
    .split(',')[0]
    .trim()
    .slice(0, 80);
}

function isRateLimited(key: string) {
  const now = Date.now();
  const windowMs = 60_000;
  const maxAttempts = 20;
  const recent = (attempts.get(key) || []).filter((ts) => now - ts < windowMs);
  recent.push(now);
  attempts.set(key, recent);
  return recent.length > maxAttempts;
}

async function logSubmission(payload: Record<string, unknown>) {
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) return;

  await fetch(`${url}/rest/v1/flag_submissions`, {
    method: 'POST',
    headers: {
      apikey: key,
      authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal',
    },
    body: JSON.stringify(payload),
  }).catch(() => {});
}

Deno.serve(async (req: Request) => {
  const origin = originFor(req);
  if (origin === null) return json({ error: 'origin not allowed' }, 403);
  if (req.method === 'OPTIONS') return new Response('ok', { headers: headersFor(origin) });
  if (req.method !== 'POST') return json({ error: 'method not allowed' }, 405, origin);

  const key = clientKey(req);
  if (isRateLimited(key)) return json({ correct: false, error: 'too many attempts' }, 429, origin);

  let body: { flag?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: 'invalid json' }, 400, origin);
  }

  const flag = String(body.flag || '').trim();
  if (!flag || flag.length > 160) return json({ correct: false, error: 'invalid flag' }, 400, origin);

  const hashes = secretMap();
  const submittedHash = await sha256Hex(flag);
  const category = Object.keys(hashes).find((name) => hashes[name] === submittedHash) || null;
  const correct = Boolean(category);

  await logSubmission({
    category,
    correct,
    submitted_hash: submittedHash,
    user_agent: req.headers.get('user-agent'),
    ip_hint: key,
  });

  return json({ correct, category }, 200, origin);
});
