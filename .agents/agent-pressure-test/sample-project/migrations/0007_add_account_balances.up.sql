-- 0007: cached balance per user and currency, kept up to date on write and
-- recomputed by "ledgerctl rebuild-balances".
CREATE TABLE account_balances (
    user_id       text   NOT NULL REFERENCES users (id),
    currency      char(3) NOT NULL,
    balance_minor bigint NOT NULL DEFAULT 0,
    updated_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, currency)
);

INSERT INTO account_balances (user_id, currency, balance_minor)
SELECT user_id, currency,
       sum(CASE kind WHEN 'refund' THEN -amount_minor ELSE amount_minor END)
FROM ledger_entries GROUP BY user_id, currency;
