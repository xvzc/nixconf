-- 0003: settlements and the lines (entries) they lock.
CREATE TABLE settlements (
    id                text PRIMARY KEY,
    user_id           text        NOT NULL REFERENCES users (id),
    period_start      timestamptz NOT NULL,
    period_end        timestamptz NOT NULL,
    entry_count       integer     NOT NULL,
    charges_minor     bigint      NOT NULL,
    refunds_minor     bigint      NOT NULL,
    adjustments_minor bigint      NOT NULL,
    fee_minor         bigint      NOT NULL,
    rounding_minor    bigint      NOT NULL,
    total_minor       bigint      NOT NULL,
    signature         text        NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now(),
    CHECK (period_start < period_end)
);

CREATE INDEX settlements_user_idx ON settlements (user_id, created_at DESC);

CREATE TABLE settlement_lines (
    settlement_id text   NOT NULL REFERENCES settlements (id),
    entry_id      text   NOT NULL,
    kind          text   NOT NULL,
    amount_minor  bigint NOT NULL,
    PRIMARY KEY (settlement_id, entry_id)
);

ALTER TABLE ledger_entries ADD COLUMN settlement_id text REFERENCES settlements (id);
