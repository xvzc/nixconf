package domain

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"
)

// Status is the lifecycle state of a settlement.
type Status string

const (
	StatusClosed Status = "closed"
	StatusVoided Status = "voided"
)

// Settlement is the statement produced when a user's period is closed.
type Settlement struct {
	ID               string     `json:"id"`
	UserID           string     `json:"user_id"`
	Currency         string     `json:"currency"`
	PeriodStart      time.Time  `json:"period_start"`
	PeriodEnd        time.Time  `json:"period_end"`
	Status           Status     `json:"status"`
	EntryCount       int        `json:"entry_count"`
	ChargesMinor     int64      `json:"charges_minor"`
	RefundsMinor     int64      `json:"refunds_minor"`
	AdjustmentsMinor int64      `json:"adjustments_minor"`
	FeeMinor         int64      `json:"fee_minor"`
	RoundingMinor    int64      `json:"rounding_minor"`
	TotalMinor       int64      `json:"total_minor"`
	Signature        string     `json:"signature"`
	CreatedAt        time.Time  `json:"created_at"`
	VoidedAt         *time.Time `json:"voided_at,omitempty"`
}

// Statement is a settlement together with the entries it locked.
type Statement struct {
	Settlement
	Entries []Entry `json:"entries"`
}

// Errors returned when closing a period.
var (
	ErrBadPeriod       = errors.New("period_start must be before period_end")
	ErrNothingToSettle = errors.New("no open entries in the period")
	ErrEntryMismatch   = errors.New("entry does not belong in this settlement")
)

// CloseInput carries everything Close needs. Entries are the user's open entries
// for the currency and period, as selected by the store.
type CloseInput struct {
	ID         string
	UserID     string
	Currency   string
	Start, End time.Time
	Entries    []Entry
	Schedule   FeeSchedule
	SigningKey []byte
	Now        time.Time
}

// Close totals the entries of one period, applies the processing fee, rounds the
// amount due to the currency's settlement increment and signs the result.
func Close(in CloseInput) (Settlement, error) {
	if !Supported(in.Currency) {
		return Settlement{}, fmt.Errorf("%w: %q", ErrBadCurrency, in.Currency)
	}
	if !in.Start.Before(in.End) {
		return Settlement{}, ErrBadPeriod
	}
	if len(in.Entries) == 0 {
		return Settlement{}, ErrNothingToSettle
	}

	s := Settlement{
		ID: in.ID, UserID: in.UserID, Currency: in.Currency,
		PeriodStart: in.Start, PeriodEnd: in.End,
		Status: StatusClosed, EntryCount: len(in.Entries), CreatedAt: in.Now,
	}
	charges := 0
	for _, e := range in.Entries {
		if e.UserID != in.UserID || e.Currency != in.Currency || e.SettlementID != "" ||
			e.CreatedAt.Before(in.Start) || !e.CreatedAt.Before(in.End) {
			return Settlement{}, fmt.Errorf("%w: %s", ErrEntryMismatch, e.ID)
		}
		switch e.Kind {
		case KindCharge:
			s.ChargesMinor += e.AmountMinor
			charges++
		case KindRefund:
			s.RefundsMinor += e.AmountMinor
		case KindAdjustment:
			s.AdjustmentsMinor += e.AmountMinor
		}
	}
	s.FeeMinor = CalculateFee(in.Schedule, in.Currency, charges, s.ChargesMinor)
	due := s.ChargesMinor - s.RefundsMinor + s.AdjustmentsMinor + s.FeeMinor
	s.TotalMinor = RoundToIncrement(due, Increment(in.Currency))
	s.RoundingMinor = s.TotalMinor - due
	s.Signature = Sign(in.SigningKey, s)
	return s, nil
}

// Sign returns the hex HMAC-SHA256 of the settlement's figures.
func Sign(key []byte, s Settlement) string {
	mac := hmac.New(sha256.New, key)
	fmt.Fprintf(mac, "%s|%s|%s|%d|%d|%d|%d|%d|%d|%d|%d|%d",
		s.ID, s.UserID, s.Currency, s.PeriodStart.Unix(), s.PeriodEnd.Unix(),
		s.EntryCount, s.ChargesMinor, s.RefundsMinor, s.AdjustmentsMinor,
		s.FeeMinor, s.RoundingMinor, s.TotalMinor)
	return hex.EncodeToString(mac.Sum(nil))
}

// Verify reports whether the settlement's signature matches its figures.
func Verify(key []byte, s Settlement) bool {
	return hmac.Equal([]byte(Sign(key, s)), []byte(s.Signature))
}

// Chunk splits entries into consecutive batches of at most size entries. Bulk
// operations such as backfills write one batch at a time.
func Chunk(entries []Entry, size int) [][]Entry {
	if size <= 0 {
		size = 100
	}
	var out [][]Entry
	for len(entries) > 0 {
		n := size
		if len(entries) < n {
			n = len(entries)
		}
		out = append(out, entries[:n])
		entries = entries[n:]
	}
	return out
}
