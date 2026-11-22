#!/usr/bin/env bash
# Deletes ledger entries older than the retention window. Used by the data-retention
# job on the operations host only; it is irreversible.
set -euo pipefail

RETENTION_DAYS="${RETENTION_DAYS:-1095}"
: "${DATABASE_URL:?DATABASE_URL must point at the database to purge}"

read -r -p "Delete ledger entries older than ${RETENTION_DAYS} days from ${DATABASE_URL%%@*}@...? [type 'purge'] " answer
[ "$answer" = "purge" ] || { echo "aborted"; exit 1; }

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -c "DELETE FROM ledger_entries WHERE created_at < now() - interval '${RETENTION_DAYS} days'"
