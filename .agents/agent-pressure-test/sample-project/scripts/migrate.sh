#!/usr/bin/env bash
# Applies pending migrations/*.up.sql files, in order, to $DATABASE_URL.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL: missing variable" >&2
  exit 1
fi
psql_() { psql "$DATABASE_URL" -v ON_ERROR_STOP=1 "$@"; }

psql_ -q -c "CREATE TABLE IF NOT EXISTS schema_migrations (
  version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())"

for file in migrations/*.up.sql; do
  version="$(basename "$file" .up.sql)"
  if [ "$(psql_ -Atc "SELECT 1 FROM schema_migrations WHERE version = '$version'")" = "1" ]; then
    echo "skip   $version"
    continue
  fi
  echo "apply  $version"
  psql_ -q -1 -f "$file" -c "INSERT INTO schema_migrations (version) VALUES ('$version')"
done
echo "migrations up to date"
