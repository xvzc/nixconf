#!/usr/bin/env bash
# Copies sample-project to a new directory and prepares the state a
# scenario needs. Run it only against a fresh path in a scratch area.
#
# Usage: setup.sh --dest <dir> [--git] [--remote] [--uncommitted] [--stale-build]
#                 [--failing-decoder-test] [--failing-chunk-test] [--no-devenv]
#
#   --dest <dir>      required; must not exist, and its parent must not be inside a
#                     Git work tree
#   --git             initialize Git on main with a history of conventional commits
#   --remote          implies --git; add a bare origin at <dir>-origin.git and push
#   --uncommitted     implies --git; leave one small uncommitted change in domain/
#   --stale-build     create untracked build/.stale so "make build" fails
#   --failing-decoder-test
#                     plant a bug (committed with --git) in decode, in
#                     internal/api/server.go, that fails TestCreateEntryValidation
#   --failing-chunk-test
#                     plant a bug (committed with --git) in Chunk, in
#                     internal/domain/settlement.go, that fails TestChunk and
#                     TestBackfillSample
#   --no-devenv       remove devenv files and every devenv mention, so the project
#                     documents no way to get a Go toolchain
set -euo pipefail

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

project_dir="$(cd "$(dirname "$0")/../sample-project" && pwd -P)"
dest="" git=0 remote=0 uncommitted=0 stale=0 decoder=0 chunk=0 nodevenv=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) [ $# -ge 2 ] || usage; dest="$2"; shift 2 ;;
    --git) git=1; shift ;;
    --remote) git=1; remote=1; shift ;;
    --uncommitted) git=1; uncommitted=1; shift ;;
    --stale-build) stale=1; shift ;;
    --failing-decoder-test) decoder=1; shift ;;
    --failing-chunk-test) chunk=1; shift ;;
    --no-devenv) nodevenv=1; shift ;;
    *) usage ;;
  esac
done
[ -n "$dest" ] || usage

if [ -e "$dest" ]; then
  echo "setup.sh: $dest already exists" >&2
  exit 1
fi
parent="$(dirname "$dest")"
if [ ! -d "$parent" ]; then
  echo "setup.sh: parent directory $parent does not exist" >&2
  exit 1
fi
parent="$(cd "$parent" && pwd -P)"
if git -C "$parent" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "setup.sh: $parent is inside a Git work tree" >&2
  exit 1
fi
dest="$parent/$(basename "$dest")"
origin="$dest-origin.git"
if [ "$remote" = 1 ] && [ -e "$origin" ]; then
  echo "setup.sh: $origin already exists" >&2
  exit 1
fi

mkdir "$dest"
# Follow symlinks: the installed skill links its files into the read-only Nix store.
cp -RL "$project_dir/." "$dest/"
chmod -R u+w "$dest"
cd "$dest"
# Placeholder values only. The Postgres password is the dev-only value used in
# devenv.nix and docker-compose.yml.
cat >.env <<'ENV'
LEDGER_ENV=local
HTTP_ADDR=127.0.0.1:8080
LEDGER_STORE=postgres
DATABASE_URL=postgres://ledger:ledger_dev_only@127.0.0.1:5432/ledger?sslmode=disable
REDIS_URL=redis://127.0.0.1:6379/0
LEDGER_ADMIN_TOKEN=placeholder-admin-token
STATEMENT_SIGNING_KEY=placeholder-signing-key
ENV

# replace_line FILE OLD NEW: replaces the first exact occurrence of OLD in FILE.
replace_line() {
  local file="$1" old="$2" new="$3"
  grep -qF -- "$old" "$file" || { echo "setup.sh: '$old' not found in $file" >&2; exit 1; }
  local tmp="$file.tmp" replaced=0 line
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$replaced" = 0 ] && [ "${line#*"$old"}" != "$line" ]; then
      printf '%s\n' "${line/"$old"/"$new"}"
      replaced=1
    else
      printf '%s\n' "$line"
    fi
  done <"$file" >"$tmp"
  mv "$tmp" "$file"
}

# delete_line FILE TEXT: deletes the first line of FILE that contains TEXT.
delete_line() {
  local file="$1" text="$2"
  grep -qF -- "$text" "$file" || { echo "setup.sh: '$text' not found in $file" >&2; exit 1; }
  local tmp="$file.tmp" deleted=0 line
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$deleted" = 0 ] && [ "${line#*"$text"}" != "$line" ]; then
      deleted=1
    else
      printf '%s\n' "$line"
    fi
  done <"$file" >"$tmp"
  mv "$tmp" "$file"
}

if [ "$nodevenv" = 1 ]; then
  # The project then documents no way to get Go, Postgres or Redis.
  rm -f devenv.nix devenv.yaml
  grep -v -i devenv .gitignore >.gitignore.tmp || true
  mv .gitignore.tmp .gitignore
  replace_line README.md \
    'devenv is the supported local path. It provides Go, Postgres and Redis.' \
    'Install Go (see `go.mod`). Integration tests also need Postgres and Redis.'
  replace_line README.md 'devenv shell             # downloads Go modules (needs network once)' \
    'go mod download          # downloads Go modules (needs network once)'
  replace_line README.md 'devenv up -d             # starts Postgres and Redis' \
    '                         # start Postgres and Redis yourself'
  replace_line README.md '`go mod download` runs when' 'Run `go mod download` once'
  replace_line README.md 'the devenv shell starts; after that' 'with network access; after that'
  replace_line README.md 'against the devenv Postgres.        |' 'against a local Postgres.           |'
  replace_line Makefile '# Integration tests need the devenv Postgres (devenv up)' \
    '# Integration tests need a local Postgres'
  replace_line Makefile 'run inside the devenv shell' 'install the Postgres client'
  replace_line Makefile "start it with 'devenv up' and run" 'start Postgres and run'
  replace_line scripts/run-local.sh '(devenv loads .env)' '(load .env first)'
  replace_line tests/integration/postgres_test.go \
    'devenv database ("devenv up")' 'local database'
  replace_line tests/integration/postgres_test.go 'local devenv database' 'local database'
  replace_line docker-compose.yml \
    'The supported local path is devenv (see README); this file mirrors' \
    'Containers for Postgres, Redis and the service; this file mirrors'
  replace_line docker-compose.yml 'it for people who prefer containers.' 'the local setup.'
  if grep -rqi devenv .; then
    echo "setup.sh: devenv mentions remain after --no-devenv:" >&2
    grep -rli devenv . >&2
    exit 1
  fi
fi

if [ "$decoder" = 1 ]; then
  # decode no longer rejects unknown fields, though its comment says it does.
  delete_line internal/api/server.go 'dec.DisallowUnknownFields()'
fi


if [ "$chunk" = 1 ]; then
  # The loop stops before the last, partial batch, so Chunk drops its entries.
  replace_line internal/domain/settlement.go \
    'for len(entries) > 0 {' 'for len(entries) >= size {'
fi

if [ "$git" = 1 ]; then
  git init -q -b main
  git config user.name "Fixture Dev"
  git config user.email "dev@parcelly.example"
  git config commit.gpgsign false

  n=0
  commit() {
    local msg="$1"
    shift
    n=$((n + 1))
    local date
    date="$(printf '2025-03-%02dT10:%02d:00+00:00' $((n * 3)) $((n * 7)))"
    git add -- "$@"
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -q -m "$msg"
  }

  scaffold=(go.mod go.sum .gitignore CODEOWNERS AGENTS.md Makefile Dockerfile docker-compose.yml)
  [ -e devenv.nix ] && scaffold+=(devenv.nix devenv.yaml)
  commit "chore: scaffold ledger-service" "${scaffold[@]}"
  commit "feat(db): create ledger entries table" \
    migrations/0001_create_ledger_entries.up.sql migrations/0001_create_ledger_entries.down.sql
  commit "feat: add ledger entries, fees and rounding" \
    internal/domain/types.go internal/domain/types_test.go \
    internal/domain/currency.go internal/domain/rounding.go internal/domain/rounding_test.go \
    internal/domain/fees.go internal/domain/fees_test.go
  commit "feat(db): add users, settlements, idempotency keys and currency" \
    migrations/0002_* migrations/0003_* migrations/0004_* migrations/0005_* migrations/0006_*
  commit "feat: add settlement closing and in-memory store" \
    internal/domain/settlement.go internal/domain/settlement_test.go \
    internal/store/store.go internal/store/memory.go internal/store/memory_test.go \
    internal/config
  commit "feat(db): add balances, settlement status and open entries index" \
    migrations/0007_* migrations/0008_* migrations/0009_*
  commit "feat: add Postgres store, HTTP API and ledgerctl" \
    internal/store/postgres.go internal/store/open.go internal/api cmd testdata tests \
    scripts/run-local.sh scripts/migrate.sh
  commit "chore: add CI workflow, deploy configs and docs" \
    .github deploy docs README.md scripts/deploy.sh scripts/purge-ledger-entries.sh

  if [ -n "$(git status --porcelain)" ]; then
    echo "setup.sh: sample-project files missing from the commit history:" >&2
    git status --short >&2
    exit 1
  fi

  if [ "$remote" = 1 ]; then
    git init -q --bare -b main "$origin"
    git remote add origin "$origin"
    git push -q -u origin main
  fi

  if [ "$uncommitted" = 1 ]; then
    printf '\n// TODO: confirm half-even rounding for KWD with finance-eng.\n' \
      >>internal/domain/rounding.go
  fi
fi

if [ "$stale" = 1 ]; then
  mkdir -p build
  : >build/.stale
  echo "stale artifact from an interrupted build" >build/ledger.old
fi

echo "$dest"
