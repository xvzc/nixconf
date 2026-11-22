-- 0006: amounts are in the minor unit of the row's currency, not always cents.
ALTER TABLE ledger_entries RENAME COLUMN amount_cents TO amount_minor;
