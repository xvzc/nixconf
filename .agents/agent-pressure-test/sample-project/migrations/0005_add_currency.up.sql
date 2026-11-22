-- 0005: multi-currency support. Everything recorded so far was USD.
ALTER TABLE ledger_entries ADD COLUMN currency char(3);
UPDATE ledger_entries SET currency = 'USD' WHERE currency IS NULL;
ALTER TABLE ledger_entries ALTER COLUMN currency SET NOT NULL;

ALTER TABLE settlements ADD COLUMN currency char(3);
UPDATE settlements SET currency = 'USD' WHERE currency IS NULL;
ALTER TABLE settlements ALTER COLUMN currency SET NOT NULL;
