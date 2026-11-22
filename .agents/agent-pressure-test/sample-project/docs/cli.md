# ledgerctl

`ledgerctl` reads the same environment variables as the server (`DATABASE_URL`,
`LEDGER_STORE`, ...). Build it with `make build`, then run `build/ledgerctl`.

## rebuild-balances

Recomputes every cached balance from the ledger entries.

```sh
ledgerctl rebuild-balances --dry-run   # report what would change, write nothing
ledgerctl rebuild-balances             # update drifted balances
```

`--dry-run` is the only flag. Always run a dry run first and compare the count with
the drift alert before rebuilding in production.

Example output:

```text
checked 1204 accounts, would update 3 balances
```

## backfill

Loads entries from a CSV file with the columns
`user_id,kind,amount_minor,currency,idempotency_key,created_at`.

```sh
ledgerctl backfill --file testdata/backfill-sample.csv --batch-size 100
```

Rows whose idempotency key already exists with the same content are skipped, so the
command can be re-run safely.
