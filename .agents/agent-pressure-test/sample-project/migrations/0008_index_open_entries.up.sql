-- 0008: closing a period scans a user's unsettled entries by currency and date;
-- that query was a sequential scan on large accounts.
CREATE INDEX ledger_entries_open_idx
    ON ledger_entries (user_id, currency, created_at)
    WHERE settlement_id IS NULL;
