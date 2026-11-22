package store

import (
	"context"
	"fmt"
	"sort"
	"sync"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
)

// Memory is a Store that keeps everything in process memory.
type Memory struct {
	mu          sync.Mutex
	seq         int
	now         func() time.Time
	users       map[string]bool
	entries     map[string]domain.Entry
	idem        map[string]string // userID + "\x00" + key -> entry ID
	balances    map[string]map[string]int64
	settlements map[string]domain.Settlement
	lines       map[string][]domain.Entry // settlement ID -> entries as locked
}

// NewMemory returns an empty in-memory store.
func NewMemory() *Memory {
	return &Memory{
		now:         time.Now,
		users:       map[string]bool{},
		entries:     map[string]domain.Entry{},
		idem:        map[string]string{},
		balances:    map[string]map[string]int64{},
		settlements: map[string]domain.Settlement{},
		lines:       map[string][]domain.Entry{},
	}
}

func (m *Memory) AddEntry(_ context.Context, e domain.Entry) (domain.Entry, bool, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	idemKey := e.UserID + "\x00" + e.IdempotencyKey
	if id, ok := m.idem[idemKey]; ok {
		prev := m.entries[id]
		if !prev.SamePayload(e) {
			return domain.Entry{}, false, ErrIdempotencyConflict
		}
		return prev, false, nil
	}
	m.seq++
	e.ID = fmt.Sprintf("ent_%06d", m.seq)
	e.SettlementID = ""
	if e.CreatedAt.IsZero() {
		e.CreatedAt = m.now().UTC()
	}
	m.users[e.UserID] = true
	m.entries[e.ID] = e
	m.idem[idemKey] = e.ID
	m.bump(e.UserID, e.Currency, e.SignedMinor())
	return e, true, nil
}

func (m *Memory) bump(userID, currency string, delta int64) {
	if m.balances[userID] == nil {
		m.balances[userID] = map[string]int64{}
	}
	m.balances[userID][currency] += delta
}

func (m *Memory) userEntries(userID string) []domain.Entry {
	var out []domain.Entry
	for _, e := range m.entries {
		if e.UserID == userID {
			out = append(out, e)
		}
	}
	return out
}

func (m *Memory) ListEntries(_ context.Context, userID string, limit int) ([]domain.Entry, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.users[userID] {
		return nil, fmt.Errorf("%w: user %s", ErrNotFound, userID)
	}
	out := m.userEntries(userID)
	sort.Slice(out, func(i, j int) bool {
		if !out[i].CreatedAt.Equal(out[j].CreatedAt) {
			return out[i].CreatedAt.After(out[j].CreatedAt)
		}
		return out[i].ID > out[j].ID
	})
	if limit > 0 && len(out) > limit {
		out = out[:limit]
	}
	return out, nil
}

func (m *Memory) Balances(_ context.Context, userID string) (map[string]int64, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.users[userID] {
		return nil, fmt.Errorf("%w: user %s", ErrNotFound, userID)
	}
	out := map[string]int64{}
	for cur, v := range m.balances[userID] {
		out[cur] = v
	}
	return out, nil
}

func (m *Memory) OpenEntries(_ context.Context, userID, currency string, start, end time.Time) ([]domain.Entry, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var out []domain.Entry
	for _, e := range m.userEntries(userID) {
		if e.Currency == currency && e.SettlementID == "" &&
			!e.CreatedAt.Before(start) && e.CreatedAt.Before(end) {
			out = append(out, e)
		}
	}
	sort.Slice(out, func(i, j int) bool {
		if !out[i].CreatedAt.Equal(out[j].CreatedAt) {
			return out[i].CreatedAt.Before(out[j].CreatedAt)
		}
		return out[i].ID < out[j].ID
	})
	return out, nil
}

func (m *Memory) SaveSettlement(_ context.Context, s domain.Settlement, entries []domain.Entry) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, e := range entries {
		cur, ok := m.entries[e.ID]
		if !ok {
			return fmt.Errorf("%w: entry %s", ErrNotFound, e.ID)
		}
		if cur.SettlementID != "" {
			return fmt.Errorf("%w: %s", ErrEntryLocked, e.ID)
		}
	}
	locked := make([]domain.Entry, 0, len(entries))
	for _, e := range entries {
		cur := m.entries[e.ID]
		cur.SettlementID = s.ID
		m.entries[e.ID] = cur
		locked = append(locked, cur)
	}
	m.settlements[s.ID] = s
	m.lines[s.ID] = locked
	return nil
}

func (m *Memory) ListSettlements(_ context.Context, userID string) ([]domain.Settlement, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.users[userID] {
		return nil, fmt.Errorf("%w: user %s", ErrNotFound, userID)
	}
	var out []domain.Settlement
	for _, s := range m.settlements {
		if s.UserID == userID {
			out = append(out, s)
		}
	}
	sort.Slice(out, func(i, j int) bool {
		if !out[i].CreatedAt.Equal(out[j].CreatedAt) {
			return out[i].CreatedAt.After(out[j].CreatedAt)
		}
		return out[i].ID > out[j].ID
	})
	return out, nil
}

func (m *Memory) GetStatement(_ context.Context, userID, settlementID string) (domain.Statement, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	s, ok := m.settlements[settlementID]
	if !ok || s.UserID != userID {
		return domain.Statement{}, fmt.Errorf("%w: settlement %s", ErrNotFound, settlementID)
	}
	lines := append([]domain.Entry(nil), m.lines[settlementID]...)
	return domain.Statement{Settlement: s, Entries: lines}, nil
}

func (m *Memory) VoidSettlement(_ context.Context, settlementID string, at time.Time) (domain.Settlement, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	s, ok := m.settlements[settlementID]
	if !ok {
		return domain.Settlement{}, fmt.Errorf("%w: settlement %s", ErrNotFound, settlementID)
	}
	if s.Status == domain.StatusVoided {
		return domain.Settlement{}, ErrAlreadyVoided
	}
	s.Status = domain.StatusVoided
	s.VoidedAt = &at
	m.settlements[settlementID] = s
	for _, e := range m.lines[settlementID] {
		if cur, ok := m.entries[e.ID]; ok {
			cur.SettlementID = ""
			m.entries[e.ID] = cur
		}
	}
	return s, nil
}

func (m *Memory) DeleteUserData(_ context.Context, userID string) (int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.users[userID] {
		return 0, fmt.Errorf("%w: user %s", ErrNotFound, userID)
	}
	n := 0
	for id, e := range m.entries {
		if e.UserID == userID {
			delete(m.idem, e.UserID+"\x00"+e.IdempotencyKey)
			delete(m.entries, id)
			n++
		}
	}
	for id, s := range m.settlements {
		if s.UserID == userID {
			delete(m.settlements, id)
			delete(m.lines, id)
		}
	}
	delete(m.balances, userID)
	delete(m.users, userID)
	return n, nil
}

func (m *Memory) RebuildBalances(_ context.Context, dryRun bool) (RebuildResult, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	all := make([]domain.Entry, 0, len(m.entries))
	for _, e := range m.entries {
		all = append(all, e)
	}
	fresh := map[string]map[string]int64{}
	for _, e := range all {
		if fresh[e.UserID] == nil {
			fresh[e.UserID] = map[string]int64{}
		}
		fresh[e.UserID][e.Currency] += e.SignedMinor()
	}
	res := RebuildResult{Accounts: len(fresh)}
	for user, cur := range fresh {
		for c, want := range cur {
			if m.balances[user][c] != want {
				res.Changed++
			}
		}
	}
	if !dryRun {
		m.balances = fresh
	}
	return res, nil
}
