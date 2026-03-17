import { NextRequest, NextResponse } from 'next/server';
import { consumeAuthCode } from '@/lib/oauth/store';
import { signAccessToken } from '@/lib/oauth/jwt';

export const runtime = 'nodejs';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function oauthError(error: string, description: string, status = 400) {
  console.error(`[oauth/token] ${error}: ${description}`);
  return NextResponse.json(
    { error, error_description: description },
    { status, headers: CORS_HEADERS }
  );
}

export async function POST(req: NextRequest) {
  try {
    const text = await req.text();
    console.log('[oauth/token] content-type:', req.headers.get('content-type'));
    console.log('[oauth/token] body:', text);

    const body = new URLSearchParams(text);

    const grantType = body.get('grant_type');
    if (grantType !== 'authorization_code') {
      return oauthError('unsupported_grant_type', 'Only authorization_code is supported');
    }

    const code = body.get('code');
    const codeVerifier = body.get('code_verifier');
    const redirectUri = body.get('redirect_uri');

    if (!code || !codeVerifier) {
      return oauthError('invalid_request', `Missing code (${!!code}) or code_verifier (${!!codeVerifier})`);
    }

    const entry = consumeAuthCode(code);
    if (!entry) {
      return oauthError('invalid_grant', 'Authorization code is invalid, expired, or already used');
    }

    if (redirectUri && entry.redirectUri !== redirectUri) {
      console.error(`[oauth/token] redirect_uri mismatch: expected "${entry.redirectUri}", got "${redirectUri}"`);
      return oauthError('invalid_grant', 'redirect_uri mismatch');
    }

    // Verify PKCE: BASE64URL(SHA-256(code_verifier)) must equal stored codeChallenge
    const encoder = new TextEncoder();
    const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(codeVerifier));
    const computed = Buffer.from(hashBuffer).toString('base64url');

    console.log('[oauth/token] PKCE computed:', computed, 'stored:', entry.codeChallenge);

    if (computed !== entry.codeChallenge) {
      return oauthError('invalid_grant', 'code_verifier does not match code_challenge');
    }

    const accessToken = await signAccessToken(entry.clientId);

    return NextResponse.json(
      {
        access_token: accessToken,
        token_type: 'bearer',
        expires_in: 3600,
      },
      { headers: CORS_HEADERS }
    );
  } catch (err) {
    console.error('[oauth/token] unhandled error:', err);
    return NextResponse.json(
      { error: 'server_error', error_description: err instanceof Error ? err.message : 'Unknown error' },
      { status: 500, headers: CORS_HEADERS }
    );
  }
}

export async function OPTIONS() {
  return new Response(null, { status: 204, headers: CORS_HEADERS });
}
