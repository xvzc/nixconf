package store

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib" // registers the "pgx" database/sql driver

	"github.com/parcelly/ledger-service/internal/domain"
)

// Postgres is a Store backed by the tables created in migrations/.
type Postgres struct {
	db *sql.DB
}

// OpenPostgres connects to the database at url and checks the connection.
func OpenPostgres(ctx context.Context, url string) (*Postgres, error) {
	db, err := sql.Open("pgx", url)
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}
	pingCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		db.Close()
		return nil, fmt.Errorf("ping database: %w", err)
	}
	return &Postgres{db: db}, nil
}

// Close releases the connection pool.
func (p *Postgres) Close() error { return p.db.Close() }

const (
	entryColumns = `id, user_id, settlement_id, kind, amount_minor, currency,
		idempotency_key, memo, created_at`
	settlementColumns = `id, user_id, currency, period_start, period_end, status,
		entry_count, charges_minor, refunds_minor, adjustments_minor, fee_minor,
		rounding_minor, total_minor, signature, created_at, voided_at`
)

type scanner interface{ Scan(...any) error }

func scanEntry(r scanner) (domain.Entry, error) {
	var e domain.Entry
	var settlement sql.NullString
	err := r.Scan(&e.ID, &e.UserID, &settlement, &e.Kind, &e.AmountMinor, &e.Currency,
		&e.IdempotencyKey, &e.Memo, &e.CreatedAt)
	e.SettlementID = settlement.String
	e.CreatedAt = e.CreatedAt.UTC()
	return e, err
}

func scanSettlement(r scanner) (domain.Settlement, error) {
	var s domain.Settlement
	var voided sql.NullTime
	err := r.Scan(&s.ID, &s.UserID, &s.Currency, &s.PeriodStart, &s.PeriodEnd, &s.Status,
		&s.EntryCount, &s.ChargesMinor, &s.RefundsMinor, &s.AdjustmentsMinor, &s.FeeMinor,
		&s.RoundingMinor, &s.TotalMinor, &s.Signature, &s.CreatedAt, &voided)
	s.PeriodStart, s.PeriodEnd, s.CreatedAt = s.PeriodStart.UTC(), s.PeriodEnd.UTC(), s.CreatedAt.UTC()
	if voided.Valid {
		t := voided.Time.UTC()
		s.VoidedAt = &t
	}
	return s, err
}

func (p *Postgres) userExists(ctx context.Context, userID string) error {
	var one int
	err := p.db.QueryRowContext(ctx, `SELECT 1 FROM users WHERE id = $1`, userID).Scan(&one)
	if errors.Is(err, sql.ErrNoRows) {
		return fmt.Errorf("%w: user %s", ErrNotFound, userID)
	}
	return err
}

func (p *Postgres) AddEntry(ctx context.Context, e domain.Entry) (domain.Entry, bool, error) {
	if e.CreatedAt.IsZero() {
		e.CreatedAt = time.Now().UTC()
	}
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return domain.Entry{}, false, err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx,
		`INSERT INTO users (id) VALUES ($1) ON CONFLICT DO NOTHING`, e.UserID); err != nil {
		return domain.Entry{}, false, fmt.Errorf("upsert user: %w", err)
	}
	row := tx.QueryRowContext(ctx, `
		INSERT INTO ledger_entries (user_id, kind, amount_minor, currency,
		                            idempotency_key, memo, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, idempotency_key) DO NOTHING
		RETURNING `+entryColumns,
		e.UserID, e.Kind, e.AmountMinor, e.Currency, e.IdempotencyKey, e.Memo, e.CreatedAt)
	stored, err := scanEntry(row)
	if errors.Is(err, sql.ErrNoRows) {
		prev, err := scanEntry(tx.QueryRowContext(ctx,
			`SELECT `+entryColumns+` FROM ledger_entries
			 WHERE user_id = $1 AND idempotency_key = $2`, e.UserID, e.IdempotencyKey))
		if err != nil {
			return domain.Entry{}, false, err
		}
		if !prev.SamePayload(e) {
			return domain.Entry{}, false, ErrIdempotencyConflict
		}
		return prev, false, nil
	}
	if err != nil {
		return domain.Entry{}, false, fmt.Errorf("insert entry: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO account_balances (user_id, currency, balance_minor)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, currency) DO UPDATE
		SET balance_minor = account_balances.balance_minor + EXCLUDED.balance_minor,
		    updated_at = now()`, stored.UserID, stored.Currency, stored.SignedMinor()); err != nil {
		return domain.Entry{}, false, fmt.Errorf("update balance: %w", err)
	}
	return stored, true, tx.Commit()
}

func (p *Postgres) ListEntries(ctx context.Context, userID string, limit int) ([]domain.Entry, error) {
	if err := p.userExists(ctx, userID); err != nil {
		return nil, err
	}
	if limit <= 0 {
		limit = 100
	}
	rows, err := p.db.QueryContext(ctx, `SELECT `+entryColumns+` FROM ledger_entries
		WHERE user_id = $1 ORDER BY created_at DESC, id DESC LIMIT $2`, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Entry
	for rows.Next() {
		e, err := scanEntry(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

func (p *Postgres) Balances(ctx context.Context, userID string) (map[string]int64, error) {
	if err := p.userExists(ctx, userID); err != nil {
		return nil, err
	}
	rows, err := p.db.QueryContext(ctx,
		`SELECT currency, balance_minor FROM account_balances WHERE user_id = $1`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]int64{}
	for rows.Next() {
		var cur string
		var v int64
		if err := rows.Scan(&cur, &v); err != nil {
			return nil, err
		}
		out[cur] = v
	}
	return out, rows.Err()
}

func (p *Postgres) OpenEntries(ctx context.Context, userID, currency string, start, end time.Time) ([]domain.Entry, error) {
	rows, err := p.db.QueryContext(ctx, `SELECT `+entryColumns+` FROM ledger_entries
		WHERE user_id = $1 AND currency = $2 AND settlement_id IS NULL
		  AND created_at >= $3 AND created_at < $4
		ORDER BY created_at, id`, userID, currency, start, end)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Entry
	for rows.Next() {
		e, err := scanEntry(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

func (p *Postgres) SaveSettlement(ctx context.Context, s domain.Settlement, entries []domain.Entry) error {
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `INSERT INTO settlements (`+settlementColumns+`)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)`,
		s.ID, s.UserID, s.Currency, s.PeriodStart, s.PeriodEnd, s.Status,
		s.EntryCount, s.ChargesMinor, s.RefundsMinor, s.AdjustmentsMinor, s.FeeMinor,
		s.RoundingMinor, s.TotalMinor, s.Signature, s.CreatedAt, s.VoidedAt); err != nil {
		return fmt.Errorf("insert settlement: %w", err)
	}
	for _, e := range entries {
		res, err := tx.ExecContext(ctx, `UPDATE ledger_entries SET settlement_id = $1
			WHERE id = $2 AND settlement_id IS NULL`, s.ID, e.ID)
		if err != nil {
			return fmt.Errorf("lock entry: %w", err)
		}
		if n, _ := res.RowsAffected(); n != 1 {
			return fmt.Errorf("%w: %s", ErrEntryLocked, e.ID)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO settlement_lines
			(settlement_id, entry_id, kind, amount_minor) VALUES ($1,$2,$3,$4)`,
			s.ID, e.ID, e.Kind, e.AmountMinor); err != nil {
			return fmt.Errorf("insert settlement line: %w", err)
		}
	}
	return tx.Commit()
}

func (p *Postgres) ListSettlements(ctx context.Context, userID string) ([]domain.Settlement, error) {
	if err := p.userExists(ctx, userID); err != nil {
		return nil, err
	}
	rows, err := p.db.QueryContext(ctx, `SELECT `+settlementColumns+` FROM settlements
		WHERE user_id = $1 ORDER BY created_at DESC, id DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Settlement
	for rows.Next() {
		s, err := scanSettlement(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}

func (p *Postgres) GetStatement(ctx context.Context, userID, settlementID string) (domain.Statement, error) {
	s, err := scanSettlement(p.db.QueryRowContext(ctx, `SELECT `+settlementColumns+`
		FROM settlements WHERE id = $1 AND user_id = $2`, settlementID, userID))
	if errors.Is(err, sql.ErrNoRows) {
		return domain.Statement{}, fmt.Errorf("%w: settlement %s", ErrNotFound, settlementID)
	}
	if err != nil {
		return domain.Statement{}, err
	}
	rows, err := p.db.QueryContext(ctx, `SELECT e.id, e.user_id, e.settlement_id, e.kind,
			e.amount_minor, e.currency, e.idempotency_key, e.memo, e.created_at
		FROM settlement_lines l JOIN ledger_entries e ON e.id = l.entry_id
		WHERE l.settlement_id = $1 ORDER BY e.created_at, e.id`, settlementID)
	if err != nil {
		return domain.Statement{}, err
	}
	defer rows.Close()
	st := domain.Statement{Settlement: s}
	for rows.Next() {
		e, err := scanEntry(rows)
		if err != nil {
			return domain.Statement{}, err
		}
		e.SettlementID = settlementID
		st.Entries = append(st.Entries, e)
	}
	return st, rows.Err()
}

func (p *Postgres) VoidSettlement(ctx context.Context, settlementID string, at time.Time) (domain.Settlement, error) {
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return domain.Settlement{}, err
	}
	defer tx.Rollback()

	cur, err := scanSettlement(tx.QueryRowContext(ctx, `SELECT `+settlementColumns+`
		FROM settlements WHERE id = $1 FOR UPDATE`, settlementID))
	if errors.Is(err, sql.ErrNoRows) {
		return domain.Settlement{}, fmt.Errorf("%w: settlement %s", ErrNotFound, settlementID)
	}
	if err != nil {
		return domain.Settlement{}, err
	}
	if cur.Status == domain.StatusVoided {
		return domain.Settlement{}, ErrAlreadyVoided
	}
	if _, err := tx.ExecContext(ctx,
		`UPDATE settlements SET status = 'voided', voided_at = $2 WHERE id = $1`,
		settlementID, at); err != nil {
		return domain.Settlement{}, err
	}
	if _, err := tx.ExecContext(ctx,
		`UPDATE ledger_entries SET settlement_id = NULL WHERE settlement_id = $1`,
		settlementID); err != nil {
		return domain.Settlement{}, err
	}
	cur.Status, cur.VoidedAt = domain.StatusVoided, &at
	return cur, tx.Commit()
}

func (p *Postgres) DeleteUserData(ctx context.Context, userID string) (int, error) {
	if err := p.userExists(ctx, userID); err != nil {
		return 0, err
	}
	tx, err := p.db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `DELETE FROM settlement_lines WHERE settlement_id IN
		(SELECT id FROM settlements WHERE user_id = $1)`, userID); err != nil {
		return 0, err
	}
	res, err := tx.ExecContext(ctx, `DELETE FROM ledger_entries WHERE user_id = $1`, userID)
	if err != nil {
		return 0, err
	}
	n, _ := res.RowsAffected()
	for _, table := range []string{"settlements", "account_balances"} {
		if _, err := tx.ExecContext(ctx, `DELETE FROM `+table+` WHERE user_id = $1`, userID); err != nil {
			return 0, err
		}
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM users WHERE id = $1`, userID); err != nil {
		return 0, err
	}
	return int(n), tx.Commit()
}

const freshBalances = `SELECT user_id, currency,
	sum(CASE kind WHEN 'refund' THEN -amount_minor ELSE amount_minor END) AS total
	FROM ledger_entries GROUP BY user_id, currency`

func (p *Postgres) RebuildBalances(ctx context.Context, dryRun bool) (RebuildResult, error) {
	var res RebuildResult
	err := p.db.QueryRowContext(ctx, `
		SELECT count(DISTINCT s.user_id),
		       count(*) FILTER (WHERE b.balance_minor IS DISTINCT FROM s.total)
		FROM (`+freshBalances+`) s
		LEFT JOIN account_balances b USING (user_id, currency)`).Scan(&res.Accounts, &res.Changed)
	if err != nil || dryRun {
		return res, err
	}
	_, err = p.db.ExecContext(ctx, `
		INSERT INTO account_balances (user_id, currency, balance_minor)
		SELECT user_id, currency, total FROM (`+freshBalances+`) f
		ON CONFLICT (user_id, currency) DO UPDATE
		SET balance_minor = EXCLUDED.balance_minor, updated_at = now()`)
	return res, err
}
