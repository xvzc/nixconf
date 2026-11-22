//go:build integration

// Package integration runs the store and HTTP API against a real Postgres. Start the
// devenv database ("devenv up") and apply the migrations ("make migrate") first.
package integration

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/parcelly/ledger-service/internal/api"
	"github.com/parcelly/ledger-service/internal/domain"
	"github.com/parcelly/ledger-service/internal/store"
)

// defaultURL is the local devenv database; the password is a dev-only value.
const defaultURL = "postgres://ledger:ledger_dev_only@127.0.0.1:5432/ledger?sslmode=disable"

var pg *store.Postgres

func TestMain(m *testing.M) {
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		url = defaultURL
	}
	var err error
	pg, err = store.OpenPostgres(context.Background(), url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "integration: Postgres is not reachable: %v\n", err)
		os.Exit(1)
	}
	code := m.Run()
	pg.Close()
	os.Exit(code)
}

// newUser returns a user ID unique to this run, so tests never collide with data
// left by earlier runs.
func newUser(t *testing.T) string {
	t.Helper()
	id := fmt.Sprintf("it_%d", time.Now().UnixNano())
	t.Cleanup(func() { pg.DeleteUserData(context.Background(), id) })
	return id
}

func charge(user, key string, amount int64) domain.Entry {
	return domain.Entry{UserID: user, Kind: domain.KindCharge, AmountMinor: amount,
		Currency: "USD", IdempotencyKey: key}
}

func TestIdempotentAddEntry(t *testing.T) {
	ctx := context.Background()
	u := newUser(t)
	first, created, err := pg.AddEntry(ctx, charge(u, "k1", 500))
	if err != nil || !created || first.ID == "" {
		t.Fatalf("first = %+v %v %v", first, created, err)
	}
	again, created, err := pg.AddEntry(ctx, charge(u, "k1", 500))
	if err != nil || created || again.ID != first.ID {
		t.Fatalf("replay = %+v %v %v", again, created, err)
	}
	if _, _, err := pg.AddEntry(ctx, charge(u, "k1", 501)); !errors.Is(err, store.ErrIdempotencyConflict) {
		t.Fatalf("want conflict, got %v", err)
	}
	bal, err := pg.Balances(ctx, u)
	if err != nil || bal["USD"] != 500 {
		t.Fatalf("balances = %v, %v", bal, err)
	}
}

func TestSettlementLifecycle(t *testing.T) {
	ctx := context.Background()
	u := newUser(t)
	if _, _, err := pg.AddEntry(ctx, charge(u, "a", 10_000)); err != nil {
		t.Fatal(err)
	}
	start, end := time.Now().Add(-time.Hour), time.Now().Add(time.Hour)

	open, err := pg.OpenEntries(ctx, u, "USD", start, end)
	if err != nil || len(open) != 1 {
		t.Fatalf("open = %+v, %v", open, err)
	}
	s, err := domain.Close(domain.CloseInput{ID: "stl_" + u, UserID: u, Currency: "USD",
		Start: start, End: end, Entries: open, Schedule: domain.DefaultSchedule,
		SigningKey: []byte("k"), Now: time.Now().UTC()})
	if err != nil {
		t.Fatal(err)
	}
	if err := pg.SaveSettlement(ctx, s, open); err != nil {
		t.Fatal(err)
	}
	dup := s
	dup.ID = "stl_dup_" + u
	if err := pg.SaveSettlement(ctx, dup, open); !errors.Is(err, store.ErrEntryLocked) {
		t.Fatalf("locked entry: %v", err)
	}
	st, err := pg.GetStatement(ctx, u, s.ID)
	if err != nil || len(st.Entries) != 1 || st.TotalMinor != 10_290 {
		t.Fatalf("statement = %+v, %v", st, err)
	}
	if _, err := pg.VoidSettlement(ctx, s.ID, time.Now().UTC()); err != nil {
		t.Fatal(err)
	}
	if _, err := pg.VoidSettlement(ctx, s.ID, time.Now().UTC()); !errors.Is(err, store.ErrAlreadyVoided) {
		t.Fatalf("second void: %v", err)
	}
	if open, _ := pg.OpenEntries(ctx, u, "USD", start, end); len(open) != 1 {
		t.Fatalf("void must unlock entries, open = %d", len(open))
	}
}

func TestRebuildBalancesDryRun(t *testing.T) {
	ctx := context.Background()
	u := newUser(t)
	if _, _, err := pg.AddEntry(ctx, charge(u, "a", 700)); err != nil {
		t.Fatal(err)
	}
	res, err := pg.RebuildBalances(ctx, true)
	if err != nil || res.Accounts < 1 {
		t.Fatalf("RebuildBalances = %+v, %v", res, err)
	}
}

func TestHTTPFlowOnPostgres(t *testing.T) {
	u := newUser(t)
	h := api.New(api.Options{Store: pg, AdminToken: "it-admin", SigningKey: []byte("it-key")}).Routes()
	call := func(method, path, body string, hdr ...string) (int, string) {
		req := httptest.NewRequest(method, path, strings.NewReader(body))
		for i := 0; i+1 < len(hdr); i += 2 {
			req.Header.Set(hdr[i], hdr[i+1])
		}
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code, rec.Body.String()
	}
	body := `{"kind":"charge","amount_minor":10000,"currency":"USD","idempotency_key":"o1"}`
	if code, out := call("POST", "/v1/users/"+u+"/entries", body); code != http.StatusCreated {
		t.Fatalf("create: %d %s", code, out)
	}
	conflict := strings.Replace(body, "10000", "10001", 1)
	if code, _ := call("POST", "/v1/users/"+u+"/entries", conflict); code != http.StatusConflict {
		t.Fatalf("conflict: %d", code)
	}
	now := time.Now().UTC()
	period := fmt.Sprintf(`{"currency":"USD","period_start":%q,"period_end":%q}`,
		now.Add(-time.Hour).Format(time.RFC3339), now.Add(time.Hour).Format(time.RFC3339))
	if code, out := call("POST", "/v1/users/"+u+"/settlements", period); code != http.StatusCreated {
		t.Fatalf("close: %d %s", code, out)
	}
	if code, _ := call("DELETE", "/v1/admin/users/"+u, ""); code != http.StatusForbidden {
		t.Fatalf("delete without token: %d", code)
	}
	if code, out := call("DELETE", "/v1/admin/users/"+u, "", "Authorization", "Bearer it-admin"); code != 200 {
		t.Fatalf("delete with token: %d %s", code, out)
	}
	if code, _ := call("GET", "/v1/users/"+u+"/balance", ""); code != http.StatusNotFound {
		t.Fatalf("after delete: %d", code)
	}
}
