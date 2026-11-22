// Command ledgerctl is the admin CLI for ledger-service.
//
//	ledgerctl rebuild-balances [--dry-run]
//	ledgerctl backfill --file entries.csv [--batch-size N]
package main

import (
	"context"
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"strconv"
	"time"

	"github.com/parcelly/ledger-service/internal/config"
	"github.com/parcelly/ledger-service/internal/domain"
	"github.com/parcelly/ledger-service/internal/store"
)

func main() {
	if err := run(os.Args[1:], os.Stdout); err != nil {
		fmt.Fprintf(os.Stderr, "ledgerctl: %v\n", err)
		os.Exit(1)
	}
}

func run(args []string, out io.Writer) error {
	if len(args) == 0 {
		return errors.New("usage: ledgerctl <rebuild-balances|backfill> [flags]")
	}
	cfg, err := config.Load(os.Getenv)
	if err != nil {
		return err
	}
	ctx := context.Background()
	st, closeStore, err := store.Open(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeStore()

	switch args[0] {
	case "rebuild-balances":
		return rebuildBalances(ctx, st, args[1:], out)
	case "backfill":
		return backfill(ctx, st, args[1:], out)
	}
	return fmt.Errorf("unknown command %q", args[0])
}

func rebuildBalances(ctx context.Context, st store.Store, args []string, out io.Writer) error {
	fs := flag.NewFlagSet("rebuild-balances", flag.ContinueOnError)
	dry := fs.Bool("dry-run", false, "report what would change without writing")
	if err := fs.Parse(args); err != nil {
		return err
	}
	res, err := st.RebuildBalances(ctx, *dry)
	if err != nil {
		return err
	}
	verb := "updated"
	if *dry {
		verb = "would update"
	}
	fmt.Fprintf(out, "checked %d accounts, %s %d balances\n", res.Accounts, verb, res.Changed)
	return nil
}

// backfill loads entries from a CSV file with the columns
// user_id,kind,amount_minor,currency,idempotency_key,created_at (RFC 3339).
func backfill(ctx context.Context, st store.Store, args []string, out io.Writer) error {
	fs := flag.NewFlagSet("backfill", flag.ContinueOnError)
	file := fs.String("file", "", "CSV file with entries to load")
	size := fs.Int("batch-size", 100, "entries per batch")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *file == "" {
		return errors.New("backfill: --file is required")
	}
	entries, err := readEntries(*file)
	if err != nil {
		return err
	}
	created, replayed := 0, 0
	for i, batch := range domain.Chunk(entries, *size) {
		for _, e := range batch {
			_, isNew, err := st.AddEntry(ctx, e)
			if err != nil {
				return fmt.Errorf("batch %d, entry %s/%s: %w", i+1, e.UserID, e.IdempotencyKey, err)
			}
			if isNew {
				created++
			} else {
				replayed++
			}
		}
		fmt.Fprintf(out, "batch %d: %d entries\n", i+1, len(batch))
	}
	fmt.Fprintf(out, "backfilled %d entries (%d already present)\n", created, replayed)
	return nil
}

func readEntries(path string) ([]domain.Entry, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	rows, err := csv.NewReader(f).ReadAll()
	if err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	var out []domain.Entry
	for i, row := range rows {
		if i == 0 || len(row) == 0 {
			continue // header
		}
		if len(row) != 6 {
			return nil, fmt.Errorf("%s line %d: want 6 columns, got %d", path, i+1, len(row))
		}
		amount, err := strconv.ParseInt(row[2], 10, 64)
		if err != nil {
			return nil, fmt.Errorf("%s line %d: amount: %w", path, i+1, err)
		}
		at, err := time.Parse(time.RFC3339, row[5])
		if err != nil {
			return nil, fmt.Errorf("%s line %d: created_at: %w", path, i+1, err)
		}
		e := domain.Entry{
			UserID: row[0], Kind: domain.Kind(row[1]), AmountMinor: amount,
			Currency: row[3], IdempotencyKey: row[4], CreatedAt: at,
		}
		if err := e.Validate(time.Now()); err != nil {
			return nil, fmt.Errorf("%s line %d: %w", path, i+1, err)
		}
		out = append(out, e)
	}
	return out, nil
}
