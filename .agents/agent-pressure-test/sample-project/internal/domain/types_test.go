package domain

import (
	"errors"
	"strings"
	"testing"
	"time"
)

var now = time.Date(2025, 6, 1, 10, 0, 0, 0, time.UTC)

func TestEntryValidate(t *testing.T) {
	ok := Entry{UserID: "u_1", Kind: KindCharge, AmountMinor: 100, Currency: "USD", IdempotencyKey: "k1"}
	tests := []struct {
		name   string
		mutate func(*Entry)
		want   error
	}{
		{"valid", func(*Entry) {}, nil},
		{"no user", func(e *Entry) { e.UserID = " " }, ErrNoUser},
		{"bad kind", func(e *Entry) { e.Kind = "tip" }, ErrBadKind},
		{"zero charge", func(e *Entry) { e.AmountMinor = 0 }, ErrBadAmount},
		{"negative refund", func(e *Entry) { e.Kind = KindRefund; e.AmountMinor = -5 }, ErrBadAmount},
		{"zero adjustment", func(e *Entry) { e.Kind = KindAdjustment; e.AmountMinor = 0 }, ErrBadAmount},
		{"negative adjustment", func(e *Entry) { e.Kind = KindAdjustment; e.AmountMinor = -5 }, nil},
		{"unknown currency", func(e *Entry) { e.Currency = "XXX" }, ErrBadCurrency},
		{"lowercase currency", func(e *Entry) { e.Currency = "usd" }, ErrBadCurrency},
		{"no key", func(e *Entry) { e.IdempotencyKey = "" }, ErrBadKey},
		{"long key", func(e *Entry) { e.IdempotencyKey = strings.Repeat("k", 129) }, ErrBadKey},
		{"long memo", func(e *Entry) { e.Memo = strings.Repeat("m", 201) }, ErrMemoTooLong},
		{"future", func(e *Entry) { e.CreatedAt = now.Add(time.Hour) }, ErrFutureEntry},
		{"small skew", func(e *Entry) { e.CreatedAt = now.Add(time.Minute) }, nil},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			e := ok
			tc.mutate(&e)
			if err := e.Validate(now); !errors.Is(err, tc.want) {
				t.Fatalf("Validate() = %v, want %v", err, tc.want)
			}
		})
	}
}

func TestSignedMinor(t *testing.T) {
	tests := []struct {
		e    Entry
		want int64
	}{
		{Entry{Kind: KindCharge, AmountMinor: 250}, 250},
		{Entry{Kind: KindRefund, AmountMinor: 250}, -250},
		{Entry{Kind: KindAdjustment, AmountMinor: -40}, -40},
	}
	for _, tc := range tests {
		if got := tc.e.SignedMinor(); got != tc.want {
			t.Errorf("%s: SignedMinor() = %d, want %d", tc.e.Kind, got, tc.want)
		}
	}
}

func TestSamePayload(t *testing.T) {
	a := Entry{UserID: "u", Kind: KindCharge, AmountMinor: 5, Currency: "USD", ID: "x"}
	b := a
	b.ID, b.IdempotencyKey = "y", "k"
	if !a.SamePayload(b) {
		t.Error("store-assigned fields must not matter")
	}
	b.AmountMinor = 6
	if a.SamePayload(b) {
		t.Error("different amount must not match")
	}
}

func TestBalancesPerCurrency(t *testing.T) {
	got := Balances([]Entry{
		{Kind: KindCharge, AmountMinor: 300, Currency: "USD"},
		{Kind: KindRefund, AmountMinor: 100, Currency: "USD"},
		{Kind: KindAdjustment, AmountMinor: 50, Currency: "KRW"},
	})
	if got["USD"] != 200 || got["KRW"] != 50 || len(got) != 2 {
		t.Fatalf("Balances = %v", got)
	}
}
