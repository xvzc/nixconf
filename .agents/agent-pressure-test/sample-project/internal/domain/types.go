// Package domain holds the pure business rules of the ledger: entries, fee
// calculation, rounding and settlement. It performs no I/O.
//
// All money is an int64 in the minor unit of the entry's currency (cents for USD,
// won for KRW, fils for KWD).
package domain

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Kind classifies a ledger entry.
type Kind string

const (
	// KindCharge is an amount the user owes, for example a shipping charge.
	KindCharge Kind = "charge"
	// KindRefund reduces what the user owes.
	KindRefund Kind = "refund"
	// KindAdjustment is a manual correction; its amount keeps its own sign.
	KindAdjustment Kind = "adjustment"
)

// Valid reports whether k is a known kind.
func (k Kind) Valid() bool {
	return k == KindCharge || k == KindRefund || k == KindAdjustment
}

// Entry is one line in a user's ledger.
type Entry struct {
	ID             string    `json:"id"`
	UserID         string    `json:"user_id"`
	SettlementID   string    `json:"settlement_id,omitempty"`
	Kind           Kind      `json:"kind"`
	AmountMinor    int64     `json:"amount_minor"`
	Currency       string    `json:"currency"`
	IdempotencyKey string    `json:"idempotency_key"`
	Memo           string    `json:"memo,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
}

// Validation errors returned by Entry.Validate.
var (
	ErrNoUser         = errors.New("user_id is required")
	ErrBadKind        = errors.New("kind must be charge, refund or adjustment")
	ErrBadAmount      = errors.New("invalid amount")
	ErrBadCurrency    = errors.New("unsupported currency")
	ErrBadKey         = errors.New("idempotency_key must be 1 to 128 characters")
	ErrMemoTooLong    = errors.New("memo must be at most 200 characters")
	ErrFutureEntry    = errors.New("created_at is in the future")
	maxClockSkew      = 5 * time.Minute
	maxIdempotencyKey = 128
	maxMemo           = 200
)

// Validate checks the invariants every stored entry must satisfy.
func (e Entry) Validate(now time.Time) error {
	if strings.TrimSpace(e.UserID) == "" {
		return ErrNoUser
	}
	if !e.Kind.Valid() {
		return fmt.Errorf("%w: %q", ErrBadKind, e.Kind)
	}
	switch e.Kind {
	case KindCharge, KindRefund:
		if e.AmountMinor <= 0 {
			return fmt.Errorf("%w: %s must be positive", ErrBadAmount, e.Kind)
		}
	case KindAdjustment:
		if e.AmountMinor == 0 {
			return fmt.Errorf("%w: adjustment must not be zero", ErrBadAmount)
		}
	}
	if !Supported(e.Currency) {
		return fmt.Errorf("%w: %q", ErrBadCurrency, e.Currency)
	}
	if n := len(e.IdempotencyKey); n < 1 || n > maxIdempotencyKey {
		return ErrBadKey
	}
	if len(e.Memo) > maxMemo {
		return ErrMemoTooLong
	}
	if !e.CreatedAt.IsZero() && e.CreatedAt.After(now.Add(maxClockSkew)) {
		return ErrFutureEntry
	}
	return nil
}

// SignedMinor is the effect of the entry on what the user owes: charges add,
// refunds subtract, adjustments apply as stored.
func (e Entry) SignedMinor() int64 {
	if e.Kind == KindRefund {
		return -e.AmountMinor
	}
	return e.AmountMinor
}

// SamePayload reports whether two entries describe the same request, ignoring the
// fields the store assigns. It decides whether a repeated idempotency key is a
// replay or a conflict.
func (e Entry) SamePayload(o Entry) bool {
	return e.UserID == o.UserID && e.Kind == o.Kind && e.AmountMinor == o.AmountMinor &&
		e.Currency == o.Currency && e.Memo == o.Memo
}

// Balances sums the signed amounts of entries per currency.
func Balances(entries []Entry) map[string]int64 {
	out := make(map[string]int64)
	for _, e := range entries {
		out[e.Currency] += e.SignedMinor()
	}
	return out
}
