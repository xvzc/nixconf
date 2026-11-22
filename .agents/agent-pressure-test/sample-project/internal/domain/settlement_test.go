package domain

import (
	"errors"
	"fmt"
	"testing"
	"time"
)

var (
	start = time.Date(2025, 5, 1, 0, 0, 0, 0, time.UTC)
	end   = time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
	key   = []byte("test-signing-key")
)

func entry(id string, kind Kind, amount int64, cur string, day int) Entry {
	return Entry{
		ID: id, UserID: "u_1", Kind: kind, AmountMinor: amount, Currency: cur,
		IdempotencyKey: id, CreatedAt: start.AddDate(0, 0, day),
	}
}

func input(cur string, entries ...Entry) CloseInput {
	return CloseInput{
		ID: "stl_1", UserID: "u_1", Currency: cur, Start: start, End: end,
		Entries: entries, Schedule: DefaultSchedule, SigningKey: key, Now: end,
	}
}

func TestCloseTotals(t *testing.T) {
	s, err := Close(input("USD",
		entry("a", KindCharge, 10_000, "USD", 1),
		entry("b", KindRefund, 1_500, "USD", 2),
		entry("c", KindAdjustment, -200, "USD", 3),
	))
	if err != nil {
		t.Fatal(err)
	}
	// Fee is 2.90% of 100.00 plus 0.3 cents: 290.3 rounds to 290.
	want := Settlement{ChargesMinor: 10_000, RefundsMinor: 1_500, AdjustmentsMinor: -200,
		FeeMinor: 290, RoundingMinor: 0, TotalMinor: 8_590, EntryCount: 3}
	if s.ChargesMinor != want.ChargesMinor || s.RefundsMinor != want.RefundsMinor ||
		s.AdjustmentsMinor != want.AdjustmentsMinor || s.FeeMinor != want.FeeMinor ||
		s.RoundingMinor != want.RoundingMinor || s.TotalMinor != want.TotalMinor ||
		s.EntryCount != want.EntryCount || s.Status != StatusClosed {
		t.Fatalf("settlement = %+v, want %+v", s, want)
	}
}

func TestCloseRoundsToCurrencyIncrement(t *testing.T) {
	// KRW settles in 10 won. 3,500 charge: fee 101.5 -> floor-free minimum is 300.
	// due = 3,500 + 300 = 3,800, already a multiple of 10.
	s, err := Close(input("KRW", entry("a", KindCharge, 3_500, "KRW", 1)))
	if err != nil {
		t.Fatal(err)
	}
	if s.FeeMinor != 300 || s.TotalMinor != 3_800 || s.RoundingMinor != 0 {
		t.Fatalf("settlement = %+v", s)
	}
	// A refund-only period has no fee; 1,234 won owed back rounds to 1,230.
	s, err = Close(input("KRW", entry("b", KindRefund, 1_234, "KRW", 1)))
	if err != nil {
		t.Fatal(err)
	}
	if s.FeeMinor != 0 || s.TotalMinor != -1_230 || s.RoundingMinor != 4 {
		t.Fatalf("settlement = %+v", s)
	}
}

func TestCloseErrors(t *testing.T) {
	good := entry("a", KindCharge, 10_000, "USD", 1)
	tests := []struct {
		name   string
		mutate func(*CloseInput)
		want   error
	}{
		{"bad currency", func(in *CloseInput) { in.Currency = "XXX" }, ErrBadCurrency},
		{"bad period", func(in *CloseInput) { in.End = in.Start }, ErrBadPeriod},
		{"nothing", func(in *CloseInput) { in.Entries = nil }, ErrNothingToSettle},
		{"wrong user", func(in *CloseInput) {
			in.Entries = []Entry{{ID: "x", UserID: "other", Kind: KindCharge, AmountMinor: 1, Currency: "USD", CreatedAt: start}}
		}, ErrEntryMismatch},
		{"wrong currency", func(in *CloseInput) { in.Entries = []Entry{entry("x", KindCharge, 1, "EUR", 1)} }, ErrEntryMismatch},
		{"outside period", func(in *CloseInput) { in.Entries = []Entry{entry("x", KindCharge, 1, "USD", 40)} }, ErrEntryMismatch},
		{"already locked", func(in *CloseInput) { e := good; e.SettlementID = "stl_0"; in.Entries = []Entry{e} }, ErrEntryMismatch},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			in := input("USD", good)
			tc.mutate(&in)
			if _, err := Close(in); !errors.Is(err, tc.want) {
				t.Fatalf("Close() = %v, want %v", err, tc.want)
			}
		})
	}
}

func TestSignatureDetectsTampering(t *testing.T) {
	s, err := Close(input("USD", entry("a", KindCharge, 10_000, "USD", 1)))
	if err != nil {
		t.Fatal(err)
	}
	if !Verify(key, s) {
		t.Fatal("fresh settlement must verify")
	}
	if Verify([]byte("other-key"), s) {
		t.Fatal("wrong key must not verify")
	}
	s.TotalMinor--
	if Verify(key, s) {
		t.Fatal("changed total must not verify")
	}
}

func TestChunk(t *testing.T) {
	var in []Entry
	for i := 0; i < 7; i++ {
		in = append(in, Entry{ID: fmt.Sprint(i)})
	}
	got := Chunk(in, 3)
	if len(got) != 3 || len(got[0]) != 3 || len(got[2]) != 1 || got[2][0].ID != "6" {
		t.Fatalf("Chunk = %v", got)
	}
	if len(Chunk(nil, 3)) != 0 {
		t.Fatal("empty input must give no batches")
	}
	if len(Chunk(in, 0)) != 1 {
		t.Fatal("non-positive size must fall back to the default")
	}
}
