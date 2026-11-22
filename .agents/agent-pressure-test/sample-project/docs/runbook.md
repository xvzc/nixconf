# Runbook

## Service basics

- Health: `GET /healthz`. Readiness checks the Postgres connection at startup.
- Logs: one line per start; errors log `internal error: ...` with the cause.
- Storage: Postgres is the source of truth. Redis is reserved for future caching.

## Deploying

1. Merge to `main`; CI runs lint, unit tests, migrations and integration tests.
2. `make deploy-staging`, then check `/healthz` and a test settlement.
3. `make deploy-prod` is run from the release pipeline, not from laptops.

Migrations are applied before the new version rolls out. Migrations must stay
backward compatible with the previous release for one deploy.

## Balance drift

Symptom: the drift alert fires or a user balance disagrees with the entry history.

1. `ledgerctl rebuild-balances --dry-run` and note how many balances would change.
2. If the count is small, run `ledgerctl rebuild-balances`.
3. If it is large, stop and page payments-platform.

## Voiding a settlement

An admin can `POST /v1/admin/settlements/{id}/void`. This unlocks the entries so the
period can be closed again. Voiding is recorded; the statement stays readable.

## Deleting a user's data

Only for approved erasure requests. `DELETE /v1/admin/users/{id}` removes entries,
settlements and balances. There is no undo; take a snapshot first.
