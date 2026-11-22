-- 0001: first version of the ledger. One row per entry.
CREATE TABLE ledger_entries (
    id           text PRIMARY KEY DEFAULT 'ent_' || replace(gen_random_uuid()::text, '-', ''),
    user_id      text        NOT NULL,
    kind         text        NOT NULL CHECK (kind IN ('charge', 'refund', 'adjustment')),
    amount_cents bigint      NOT NULL,
    memo         text        NOT NULL DEFAULT '',
    created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ledger_entries_user_idx ON ledger_entries (user_id);
