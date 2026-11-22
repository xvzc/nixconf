# ledger-service

Parcelly's settlement ledger. The service records per-user ledger entries (charges,
refunds, adjustments), keeps a balance per user and currency, and closes settlement
periods into signed statements. It exposes a JSON API over HTTP and has no outbound
dependencies.

- Owning team: payments-platform (see `CODEOWNERS`)
- Runbook: https://wiki.parcelly.example/payments/ledger-service/runbook
  (a copy of the essentials is in `docs/runbook.md`)
- On-call notes: `docs/oncall-notes.md`

## Local setup

devenv is the supported local path. It provides Go, Postgres and Redis.

```sh
devenv shell             # downloads Go modules (needs network once)
devenv up -d             # starts Postgres and Redis
make migrate             # applies migrations/*.up.sql
make run                 # serves on 127.0.0.1:8080
```

Dependencies (the pgx Postgres driver) are not vendored. `go mod download` runs when
the devenv shell starts; after that, builds and `make test-unit` work offline from
the module cache.

`docker-compose.yml` mirrors the same services for people who prefer containers, but
it is not the supported path.

For a quick run without a database, use the in-memory store (data is lost on exit):

```sh
make run LEDGER_STORE=memory
```

## Commands

| Command                  | What it does                                          |
| ------------------------ | ----------------------------------------------------- |
| `make run`               | Run the server via `scripts/run-local.sh`.            |
| `make test-unit`         | Unit tests (`go test ./...`), no database needed.     |
| `make test`              | Integration tests against the devenv Postgres.        |
| `make fmt`               | Format the Go sources with `gofmt -w`.                |
| `make lint`              | `go vet` and `gofmt -l`.                              |
| `make build`             | Build `ledger` and `ledgerctl` into `build/`.         |
| `make migrate`           | Apply pending migrations to `DATABASE_URL`.           |
| `make check-migrations`  | Fail if a migration file is not tracked by Git.       |
| `make deploy-staging`    | Print the staging deploy steps (`scripts/deploy.sh`). |
| `make deploy-prod`       | Print the production deploy steps.                    |

## Layout

- `cmd/ledger` is the HTTP server; `cmd/ledgerctl` is the admin CLI (`docs/cli.md`).
- `internal/domain` holds entries, fees, rounding and settlement logic.
- `internal/store` has the `Store` interface, the in-memory store used by unit tests
  and the Postgres store.
- `internal/api` holds the routes and handlers; `admin.go` guards admin endpoints.
- `internal/config` reads environment variables. Per-environment deploy settings
  live separately in `deploy/<env>/values.yaml`.
- `migrations/` holds numbered up/down SQL pairs.

The API is documented in `docs/api.md`.
