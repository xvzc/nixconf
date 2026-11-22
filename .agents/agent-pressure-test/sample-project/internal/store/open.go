package store

import (
	"context"
	"fmt"

	"github.com/parcelly/ledger-service/internal/config"
)

// Open returns the store selected by cfg.Store. The returned close function must
// be called on shutdown.
func Open(ctx context.Context, cfg config.Config) (Store, func() error, error) {
	switch cfg.Store {
	case config.StoreMemory:
		return NewMemory(), func() error { return nil }, nil
	case config.StorePostgres:
		pg, err := OpenPostgres(ctx, cfg.DatabaseURL)
		if err != nil {
			return nil, nil, err
		}
		return pg, pg.Close, nil
	}
	return nil, nil, fmt.Errorf("unknown store %q", cfg.Store)
}
