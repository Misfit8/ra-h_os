FROM node:20-slim AS base
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

# Rebuild native modules for Linux
RUN npm rebuild better-sqlite3

# Build the Next.js app
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_DEPLOYMENT_MODE=cloud
ENV NEXT_PUBLIC_ENABLE_SUBSCRIPTION_BACKEND=false
RUN npm run build

# Production image
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Copy sqlite extensions and seed
COPY --from=builder /app/vendor ./vendor
COPY --from=builder /app/scripts/seed.sql ./scripts/seed.sql
COPY --from=builder /app/scripts/railway-start.sh ./scripts/railway-start.sh

# Ensure data dir exists
RUN mkdir -p /data && chown nextjs:nodejs /data
RUN chmod +x ./scripts/railway-start.sh

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV SQLITE_DB_PATH=/data/rah.sqlite
ENV SQLITE_VEC_EXTENSION_PATH=/app/vendor/sqlite-extensions/vec0.so

CMD ["./scripts/railway-start.sh"]
