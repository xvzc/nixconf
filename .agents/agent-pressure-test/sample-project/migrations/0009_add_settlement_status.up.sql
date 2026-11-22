-- 0009: settlements can be voided by an administrator.
ALTER TABLE settlements
    ADD COLUMN status    text NOT NULL DEFAULT 'closed'
        CHECK (status IN ('closed', 'voided')),
    ADD COLUMN voided_at timestamptz;
