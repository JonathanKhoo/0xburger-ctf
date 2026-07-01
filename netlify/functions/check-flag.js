exports.handler = async function (event) {
  if (event.httpMethod === 'OPTIONS') return response(204, '');
  if (event.httpMethod !== 'POST') return response(405, { error: 'method not allowed' });

  const checkerUrl = process.env.FLAG_CHECK_URL;
  if (!checkerUrl) return response(503, { correct: false, error: 'checker not configured' });

  try {
    const upstream = await fetch(checkerUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Origin: 'https://jonathankhoo.github.io',
        'User-Agent': event.headers['user-agent'] || '0xburger-netlify-checker',
      },
      body: event.body || '{}',
    });

    return response(upstream.status, await upstream.json());
  } catch {
    return response(502, { correct: false, error: 'checker unavailable' });
  }
};

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store',
    },
    body: typeof body === 'string' ? body : JSON.stringify(body),
  };
}
