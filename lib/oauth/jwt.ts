import { SignJWT, jwtVerify } from 'jose';
import type { AuthInfo } from '@modelcontextprotocol/sdk/server/auth/types.js';

function getSecret(): Uint8Array {
  const secret = process.env.MCP_JWT_SECRET;
  if (!secret) throw new Error('MCP_JWT_SECRET env var is not set');
  return new TextEncoder().encode(secret);
}

function getBaseUrl(): string {
  return process.env.NEXT_PUBLIC_BASE_URL || '';
}

export async function signAccessToken(clientId: string): Promise<string> {
  const baseUrl = getBaseUrl();
  return new SignJWT({ clientId, scopes: ['mcp'] })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject('mcp-user')
    .setIssuer(baseUrl)
    .setAudience(baseUrl)
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(getSecret());
}

export async function verifyAccessToken(token: string): Promise<AuthInfo> {
  const baseUrl = getBaseUrl();
  const { payload } = await jwtVerify(token, getSecret(), {
    issuer: baseUrl,
    audience: baseUrl,
  });

  return {
    token,
    clientId: (payload.clientId as string) || 'mcp-user',
    scopes: (payload.scopes as string[]) || ['mcp'],
    expiresAt: payload.exp,
  };
}
