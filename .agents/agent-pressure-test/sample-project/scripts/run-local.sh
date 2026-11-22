#!/usr/bin/env bash
# Runs ledger-service locally. Settings come from the environment (devenv loads .env).
set -euo pipefail
cd "$(dirname "$0")/.."

for var in REDIS_URL LEDGER_ADMIN_TOKEN STATEMENT_SIGNING_KEY; do
  if [ -z "${!var:-}" ]; then
    echo "$var: missing variable" >&2
    exit 1
  fi
done

exec go run ./cmd/ledger
