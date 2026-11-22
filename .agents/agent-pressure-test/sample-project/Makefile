SHELL := /bin/bash

-include .env
export

.PHONY: run test-unit test fmt lint build migrate check-migrations deploy-staging deploy-prod

GO_DIRS := cmd internal tests

run:
	scripts/run-local.sh

test-unit:
	go test ./...

# Integration tests need the devenv Postgres (devenv up) with migrations applied.
test:
	@command -v psql >/dev/null || { echo "test: psql not found; run inside the devenv shell" >&2; exit 1; }
	@psql "$$DATABASE_URL" -Atc 'select 1' >/dev/null 2>&1 || { \
		echo "test: Postgres is not reachable at DATABASE_URL; start it with 'devenv up' and run 'make migrate'" >&2; exit 1; }
	go test -tags integration -count=1 ./tests/integration/...

fmt:
	gofmt -w $(GO_DIRS)

lint:
	go vet ./...
	go vet -tags integration ./...
	@out="$$(gofmt -l $(GO_DIRS))"; if [ -n "$$out" ]; then echo "gofmt needed:" >&2; echo "$$out" >&2; exit 1; fi

build:
	@if [ -e build/.stale ]; then echo "build: stale artifacts in build/" >&2; exit 1; fi
	mkdir -p build
	go build -o build/ledger ./cmd/ledger
	go build -o build/ledgerctl ./cmd/ledgerctl

# Applies every pending migrations/*.up.sql to DATABASE_URL.
migrate:
	scripts/migrate.sh

# Fails when a migration exists on disk but is not tracked by Git.
check-migrations:
	@untracked="$$(comm -23 <(printf '%s\n' migrations/* | sort) <(git ls-files migrations/ | sort))"; \
	if [ -n "$$untracked" ]; then echo "check-migrations: untracked migrations:" >&2; echo "$$untracked" >&2; exit 1; fi; \
	echo "check-migrations: ok"

deploy-staging:
	scripts/deploy.sh staging

deploy-prod:
	scripts/deploy.sh prod
