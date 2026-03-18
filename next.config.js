/** @type {import('next').NextConfig} */

const RAH_API_ORIGIN = (process.env.RAH_API_URL ?? 'https://ra-hos-production.up.railway.app/api')
  .replace(/\/api$/, '');

const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
      "style-src 'self' 'unsafe-inline'",
      `connect-src 'self' https://api.anthropic.com ${RAH_API_ORIGIN}`,
      "img-src 'self' data: https:",
      "font-src 'self'",
      "worker-src 'self'",
    ].join('; '),
  },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
];

const nextConfig = {
  output: 'standalone',
  experimental: {
    serverActions: {
      allowedOrigins: (process.env.ALLOWED_ORIGINS ?? 'localhost:3000').split(','),
    },
  },

  async headers() {
    return [{ source: '/(.*)', headers: securityHeaders }];
  },

  typescript: {
    ignoreBuildErrors: false,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
}

module.exports = nextConfig
