-- 0004: callers retry writes, so every entry carries an idempotency key. Existing
-- rows get a synthetic key derived from their id.
ALTER TABLE ledger_entries ADD COLUMN idempotency_key text;
UPDATE ledger_entries SET idempotency_key = 'legacy-' || id WHERE idempotency_key IS NULL;
ALTER TABLE ledger_entries ALTER COLUMN idempotency_key SET NOT NULL;

CREATE UNIQUE INDEX ledger_entries_idempotency_uq
    ON ledger_entries (user_id, idempotency_key);
