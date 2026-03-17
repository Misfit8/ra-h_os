#!/bin/bash
set -e

DB_PATH="${SQLITE_DB_PATH:-/data/rah.sqlite}"
SEED_FILE="/app/scripts/seed.sql"

# Seed the database on first boot
if [ ! -f "$DB_PATH" ]; then
  echo "[railway-start] No database found at $DB_PATH — seeding from $SEED_FILE"
  mkdir -p "$(dirname "$DB_PATH")"
  sqlite3 "$DB_PATH" < "$SEED_FILE"
  echo "[railway-start] Database seeded successfully."
else
  echo "[railway-start] Database exists at $DB_PATH — skipping seed."
fi

export SQLITE_VEC_EXTENSION_PATH=/app/vendor/sqlite-extensions/vec0.so
exec node server.js
