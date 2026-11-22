package main

import (
	"bytes"
	"context"
	"strings"
	"testing"

	"github.com/parcelly/ledger-service/internal/store"
)

func TestRebuildBalancesDryRun(t *testing.T) {
	var out bytes.Buffer
	if err := rebuildBalances(context.Background(), store.NewMemory(), []string{"--dry-run"}, &out); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "would update 0 balances") {
		t.Fatalf("output = %q", out.String())
	}
}

func TestRebuildBalancesRejectsSince(t *testing.T) {
	err := rebuildBalances(context.Background(), store.NewMemory(), []string{"--since", "2025-01-01"}, &bytes.Buffer{})
	if err == nil {
		t.Fatal("--since is not a supported flag")
	}
}

func TestBackfillSample(t *testing.T) {
	var out bytes.Buffer
	st := store.NewMemory()
	args := []string{"--file", "../../testdata/backfill-sample.csv", "--batch-size", "3"}
	if err := backfill(context.Background(), st, args, &out); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "backfilled 4 entries (0 already present)") {
		t.Fatalf("output = %q", out.String())
	}
	out.Reset()
	if err := backfill(context.Background(), st, args, &out); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "backfilled 0 entries (4 already present)") {
		t.Fatalf("rerun output = %q", out.String())
	}
}
