const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const enc = new TextEncoder();

async function sha256Hex(value) {
  const digest = await crypto.subtle.digest('SHA-256', enc.encode(value.trim()));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function secretMap() {
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

async function logSubmission(payload) {
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

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method not allowed' }, 405);

  let body;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'invalid json' }, 400);
  }

  const flag = String(body.flag || '').trim();
  if (!flag || flag.length > 160) return json({ correct: false, error: 'invalid flag' }, 400);

  const hashes = secretMap();
  const submittedHash = await sha256Hex(flag);
  const category = Object.keys(hashes).find((name) => hashes[name] === submittedHash) || null;
  const correct = Boolean(category);

  await logSubmission({
    category,
    correct,
    submitted_hash: submittedHash,
    user_agent: req.headers.get('user-agent'),
    ip_hint: req.headers.get('cf-connecting-ip') || req.headers.get('x-forwarded-for'),
  });

  return json({ correct, category });
});
