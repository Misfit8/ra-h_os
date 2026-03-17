import { NextRequest } from 'next/server';
import { timingSafeEqual } from 'crypto';
import { storeAuthCode } from '@/lib/oauth/store';

export const runtime = 'nodejs';

function loginForm(params: URLSearchParams, error?: string): Response {
  const errorHtml = error
    ? `<p style="color:#e53e3e;margin-bottom:16px;">${error}</p>`
    : '';

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RA-H — Authorize</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0f0f0f; color: #e5e5e5; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .card { background: #1a1a1a; border: 1px solid #333; border-radius: 12px; padding: 40px; width: 100%; max-width: 380px; }
    h1 { font-size: 20px; font-weight: 600; margin-bottom: 8px; }
    p { font-size: 14px; color: #999; margin-bottom: 28px; }
    label { display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px; }
    input[type=text], input[type=password] { width: 100%; padding: 10px 12px; background: #111; border: 1px solid #333; border-radius: 8px; color: #e5e5e5; font-size: 14px; margin-bottom: 16px; outline: none; }
    input:focus { border-color: #555; }
    button { width: 100%; padding: 12px; background: #e5e5e5; color: #111; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; margin-top: 4px; }
    button:hover { background: #fff; }
  </style>
</head>
<body>
  <div class="card">
    <h1>RA-H Knowledge Graph</h1>
    <p>Sign in to connect Claude to your graph.</p>
    ${errorHtml}
    <form method="POST">
      ${Array.from(params.entries()).map(([k, v]) =>
        `<input type="hidden" name="${k}" value="${v.replace(/"/g, '&quot;')}">`
      ).join('\n      ')}
      <label for="username">Username</label>
      <input type="text" id="username" name="username" autocomplete="username" required>
      <label for="password">Password</label>
      <input type="password" id="password" name="password" autocomplete="current-password" required>
      <button type="submit">Authorize</button>
    </form>
  </div>
</body>
</html>`;

  return new Response(html, {
    status: error ? 401 : 200,
    headers: { 'Content-Type': 'text/html' },
  });
}

export async function GET(req: NextRequest) {
  const params = req.nextUrl.searchParams;
  return loginForm(params);
}

export async function POST(req: NextRequest) {
  const body = await req.formData();

  const redirectUri = body.get('redirect_uri') as string;
  const state = body.get('state') as string;
  const codeChallenge = body.get('code_challenge') as string;
  const codeChallengeMethod = body.get('code_challenge_method') as string;
  const clientId = body.get('client_id') as string;
  const username = body.get('username') as string;
  const password = body.get('password') as string;

  // Reconstruct params for re-rendering form
  const oauthParams = new URLSearchParams();
  if (redirectUri) oauthParams.set('redirect_uri', redirectUri);
  if (state) oauthParams.set('state', state);
  if (codeChallenge) oauthParams.set('code_challenge', codeChallenge);
  if (codeChallengeMethod) oauthParams.set('code_challenge_method', codeChallengeMethod);
  if (clientId) oauthParams.set('client_id', clientId);

  // Validate PKCE method
  if (codeChallengeMethod !== 'S256') {
    return loginForm(oauthParams, 'Only S256 code challenge method is supported.');
  }

  // Validate credentials
  const expectedUsername = process.env.MCP_USERNAME || '';
  const expectedPassword = process.env.MCP_PASSWORD || '';

  let valid = false;
  try {
    const userBuf = Buffer.from(username || '');
    const expectedUserBuf = Buffer.from(expectedUsername);
    const passBuf = Buffer.from(password || '');
    const expectedPassBuf = Buffer.from(expectedPassword);
    valid =
      userBuf.length === expectedUserBuf.length &&
      passBuf.length === expectedPassBuf.length &&
      timingSafeEqual(userBuf, expectedUserBuf) &&
      timingSafeEqual(passBuf, expectedPassBuf);
  } catch {
    valid = false;
  }

  if (!valid) {
    return loginForm(oauthParams, 'Invalid username or password.');
  }

  // Generate auth code
  const code = crypto.randomUUID();
  storeAuthCode(code, {
    codeChallenge,
    redirectUri,
    clientId: clientId || 'unknown',
    expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
  });

  const redirectUrl = new URL(redirectUri);
  redirectUrl.searchParams.set('code', code);
  if (state) redirectUrl.searchParams.set('state', state);

  return Response.redirect(redirectUrl.toString(), 302);
}
