interface AuthCodeEntry {
  codeChallenge: string;
  redirectUri: string;
  clientId: string;
  expiresAt: number;
  used: boolean;
}

const codes = new Map<string, AuthCodeEntry>();

export function storeAuthCode(code: string, entry: Omit<AuthCodeEntry, 'used'>): void {
  codes.set(code, { ...entry, used: false });
}

export function consumeAuthCode(code: string): AuthCodeEntry | null {
  purgeExpired();
  const entry = codes.get(code);
  if (!entry) return null;
  if (entry.used) return null;
  if (Date.now() > entry.expiresAt) {
    codes.delete(code);
    return null;
  }
  entry.used = true;
  return entry;
}

function purgeExpired(): void {
  const now = Date.now();
  for (const [code, entry] of codes.entries()) {
    if (now > entry.expiresAt || entry.used) {
      codes.delete(code);
    }
  }
}
