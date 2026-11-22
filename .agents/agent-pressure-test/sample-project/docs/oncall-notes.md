# On-call notes

- Idempotency 409s are usually client retries with a changed payload, not an outage.
  Check the caller before looking at the service.
- A closing request that returns 422 `nothing_to_settle` means the entries were
  already settled or the period has none. Look at the user's settlements first.
- KRW settlements round to 10 won and KWD to 5 fils. A statement total that differs
  from the sum of its parts by that much is expected (`rounding_minor`).
- The staging database is reset on Mondays.
- `scripts/purge-ledger-entries.sh` belongs to the retention job. Do not run it
  by hand during an incident.
- Rotating `STATEMENT_SIGNING_KEY` invalidates verification of old statements;
  coordinate with finance-eng before doing it.
