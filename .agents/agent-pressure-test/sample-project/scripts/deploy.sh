#!/usr/bin/env bash
# Usage: scripts/deploy.sh <staging|prod>
# Prints the steps a deploy would perform. It does not contact any system.
set -euo pipefail
cd "$(dirname "$0")/.."

env="${1:-}"
case "$env" in
  staging | prod) ;;
  *) echo "usage: $0 <staging|prod>" >&2; exit 2 ;;
esac

values="deploy/$env/values.yaml"
[ -f "$values" ] || { echo "missing $values" >&2; exit 1; }
tag="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

echo "[dry] build image parcelly/ledger-service:$tag"
echo "[dry] push image parcelly/ledger-service:$tag"
echo "[dry] helm upgrade --install ledger-service ./chart -f $values --set image.tag=$tag"
echo "[dry] wait for rollout ledger-service in $env"
