-- 0002: users become a real table; entries reference them.
CREATE TABLE users (
    id         text PRIMARY KEY,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO users (id) SELECT DISTINCT user_id FROM ledger_entries;

ALTER TABLE ledger_entries
    ADD CONSTRAINT ledger_entries_user_fk FOREIGN KEY (user_id) REFERENCES users (id);
