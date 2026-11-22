DROP INDEX ledger_entries_idempotency_uq;
ALTER TABLE ledger_entries DROP COLUMN idempotency_key;
