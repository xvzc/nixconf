// Package store persists ledger data. Memory backs unit tests and quick local runs;
// Postgres is the real implementation and matches the schema in migrations/.
package store

import (
	"context"
	"errors"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
)

// Errors returned by Store implementations.
var (
	ErrNotFound            = errors.New("not found")
	ErrIdempotencyConflict = errors.New("idempotency key already used with a different request")
	ErrEntryLocked         = errors.New("entry is already part of a settlement")
	ErrAlreadyVoided       = errors.New("settlement is already voided")
)

// RebuildResult describes what a balance rebuild changed.
type RebuildResult struct {
	Accounts int
	Changed  int
}

// Store is the persistence boundary of the service. Everything is keyed by user ID.
type Store interface {
	// AddEntry stores e and assigns ID and CreatedAt when empty. A repeated
	// idempotency key with the same payload returns the original entry and
	// created=false; with a different payload it returns ErrIdempotencyConflict.
	AddEntry(ctx context.Context, e domain.Entry) (entry domain.Entry, created bool, err error)
	// ListEntries returns a user's entries, newest first. Unknown users give
	// ErrNotFound.
	ListEntries(ctx context.Context, userID string, limit int) ([]domain.Entry, error)
	// Balances returns the cached balance per currency. Unknown users give
	// ErrNotFound.
	Balances(ctx context.Context, userID string) (map[string]int64, error)

	// OpenEntries returns the unsettled entries of a currency created in
	// [start, end), oldest first.
	OpenEntries(ctx context.Context, userID, currency string, start, end time.Time) ([]domain.Entry, error)
	// SaveSettlement stores s and locks entries to it atomically. It returns
	// ErrEntryLocked if any entry was settled in the meantime.
	SaveSettlement(ctx context.Context, s domain.Settlement, entries []domain.Entry) error
	ListSettlements(ctx context.Context, userID string) ([]domain.Settlement, error)
	GetStatement(ctx context.Context, userID, settlementID string) (domain.Statement, error)

	// VoidSettlement marks a settlement voided and unlocks its entries.
	VoidSettlement(ctx context.Context, settlementID string, at time.Time) (domain.Settlement, error)
	// DeleteUserData removes a user's entries, settlements and balances and returns
	// the number of entries deleted.
	DeleteUserData(ctx context.Context, userID string) (int, error)

	// RebuildBalances recomputes cached balances from entries. With dryRun set it
	// only reports what would change.
	RebuildBalances(ctx context.Context, dryRun bool) (RebuildResult, error)
}
