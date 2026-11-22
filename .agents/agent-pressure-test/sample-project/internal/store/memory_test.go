package store

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
)

var (
	ctx   = context.Background()
	start = time.Date(2025, 5, 1, 0, 0, 0, 0, time.UTC)
	end   = time.Date(2025, 6, 1, 0, 0, 0, 0, time.UTC)
)

func charge(user, key string, cents int64, day int) domain.Entry {
	return domain.Entry{UserID: user, Kind: domain.KindCharge, AmountMinor: cents,
		Currency: "USD", IdempotencyKey: key, CreatedAt: start.AddDate(0, 0, day)}
}

func TestAddEntryIdempotency(t *testing.T) {
	m := NewMemory()
	first, created, err := m.AddEntry(ctx, charge("u_1", "k1", 500, 1))
	if err != nil || !created || first.ID == "" {
		t.Fatalf("first add = %+v, %v, %v", first, created, err)
	}
	again, created, err := m.AddEntry(ctx, charge("u_1", "k1", 500, 1))
	if err != nil || created || again.ID != first.ID {
		t.Fatalf("replay = %+v, %v, %v", again, created, err)
	}
	if _, _, err := m.AddEntry(ctx, charge("u_1", "k1", 999, 1)); !errors.Is(err, ErrIdempotencyConflict) {
		t.Fatalf("want conflict, got %v", err)
	}
	if _, created, _ := m.AddEntry(ctx, charge("u_2", "k1", 999, 1)); !created {
		t.Fatal("keys are scoped per user")
	}
	if bal, _ := m.Balances(ctx, "u_1"); bal["USD"] != 500 {
		t.Fatalf("replay must not change the balance: %v", bal)
	}
}

func TestUnknownUser(t *testing.T) {
	m := NewMemory()
	if _, err := m.Balances(ctx, "nobody"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("Balances: %v", err)
	}
	if _, err := m.ListEntries(ctx, "nobody", 10); !errors.Is(err, ErrNotFound) {
		t.Fatalf("ListEntries: %v", err)
	}
	if _, err := m.DeleteUserData(ctx, "nobody"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("DeleteUserData: %v", err)
	}
}

func TestListEntriesNewestFirst(t *testing.T) {
	m := NewMemory()
	for i := 0; i < 5; i++ {
		m.AddEntry(ctx, charge("u_1", string(rune('a'+i)), int64(100+i), i))
	}
	got, _ := m.ListEntries(ctx, "u_1", 3)
	if len(got) != 3 || got[0].AmountMinor != 104 || got[2].AmountMinor != 102 {
		t.Fatalf("unexpected list: %+v", got)
	}
}

func settle(t *testing.T, m *Memory, id string) domain.Settlement {
	t.Helper()
	open, err := m.OpenEntries(ctx, "u_1", "USD", start, end)
	if err != nil {
		t.Fatal(err)
	}
	s, err := domain.Close(domain.CloseInput{ID: id, UserID: "u_1", Currency: "USD",
		Start: start, End: end, Entries: open, Schedule: domain.DefaultSchedule, Now: end})
	if err != nil {
		t.Fatal(err)
	}
	if err := m.SaveSettlement(ctx, s, open); err != nil {
		t.Fatal(err)
	}
	return s
}

func TestSettlementLocksAndVoidUnlocks(t *testing.T) {
	m := NewMemory()
	m.AddEntry(ctx, charge("u_1", "a", 10_000, 1))
	m.AddEntry(ctx, charge("u_1", "b", 5_000, 2))
	m.AddEntry(ctx, charge("u_1", "late", 700, 45)) // outside the period

	s := settle(t, m, "stl_1")
	if open, _ := m.OpenEntries(ctx, "u_1", "USD", start, end); len(open) != 0 {
		t.Fatalf("settled entries must be locked, still open: %+v", open)
	}
	st, err := m.GetStatement(ctx, "u_1", s.ID)
	if err != nil || len(st.Entries) != 2 || st.Entries[0].SettlementID != "stl_1" {
		t.Fatalf("statement = %+v, %v", st, err)
	}
	if _, err := m.GetStatement(ctx, "u_2", s.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("statement of another user: %v", err)
	}

	if _, err := m.VoidSettlement(ctx, s.ID, end); err != nil {
		t.Fatal(err)
	}
	if open, _ := m.OpenEntries(ctx, "u_1", "USD", start, end); len(open) != 2 {
		t.Fatalf("void must unlock entries, open = %d", len(open))
	}
	if _, err := m.VoidSettlement(ctx, s.ID, end); !errors.Is(err, ErrAlreadyVoided) {
		t.Fatalf("second void: %v", err)
	}
}

func TestSaveSettlementRejectsLockedEntries(t *testing.T) {
	m := NewMemory()
	m.AddEntry(ctx, charge("u_1", "a", 10_000, 1))
	open, _ := m.OpenEntries(ctx, "u_1", "USD", start, end)
	settle(t, m, "stl_1")
	err := m.SaveSettlement(ctx, domain.Settlement{ID: "stl_2", UserID: "u_1"}, open)
	if !errors.Is(err, ErrEntryLocked) {
		t.Fatalf("want ErrEntryLocked, got %v", err)
	}
}

func TestDeleteUserData(t *testing.T) {
	m := NewMemory()
	m.AddEntry(ctx, charge("u_1", "a", 10_000, 1))
	m.AddEntry(ctx, charge("u_2", "a", 1, 1))
	settle(t, m, "stl_1")
	n, err := m.DeleteUserData(ctx, "u_1")
	if err != nil || n != 1 {
		t.Fatalf("DeleteUserData = %d, %v", n, err)
	}
	if _, err := m.ListSettlements(ctx, "u_1"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("user should be gone: %v", err)
	}
	if bal, _ := m.Balances(ctx, "u_2"); bal["USD"] != 1 {
		t.Fatal("other users must be untouched")
	}
}

func TestRebuildBalances(t *testing.T) {
	m := NewMemory()
	m.AddEntry(ctx, charge("u_1", "a", 300, 1))
	m.AddEntry(ctx, charge("u_2", "a", 900, 1))
	m.balances["u_1"]["USD"] = 42 // simulate drift

	res, err := m.RebuildBalances(ctx, true)
	if err != nil || res.Accounts != 2 || res.Changed != 1 {
		t.Fatalf("dry run = %+v, %v", res, err)
	}
	if m.balances["u_1"]["USD"] != 42 {
		t.Fatal("dry run must not modify balances")
	}
	if _, err := m.RebuildBalances(ctx, false); err != nil {
		t.Fatal(err)
	}
	if bal, _ := m.Balances(ctx, "u_1"); bal["USD"] != 300 {
		t.Fatalf("balance = %v, want 300", bal)
	}
}
