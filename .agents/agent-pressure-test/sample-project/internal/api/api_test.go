package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
	"github.com/parcelly/ledger-service/internal/store"
)

const adminToken = "test-admin-token"

var fixedNow = time.Date(2025, 6, 2, 12, 0, 0, 0, time.UTC)

func newServer() http.Handler {
	return New(Options{
		Store:      store.NewMemory(),
		AdminToken: adminToken,
		SigningKey: []byte("test-signing-key"),
		Now:        func() time.Time { return fixedNow },
	}).Routes()
}

func do(t *testing.T, h http.Handler, method, path, body string, hdr ...string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	for i := 0; i+1 < len(hdr); i += 2 {
		req.Header.Set(hdr[i], hdr[i+1])
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func admin() []string { return []string{"Authorization", "Bearer " + adminToken} }

func decodeBody[T any](t *testing.T, rec *httptest.ResponseRecorder) T {
	t.Helper()
	var v T
	if err := json.Unmarshal(rec.Body.Bytes(), &v); err != nil {
		t.Fatalf("decode %q: %v", rec.Body.String(), err)
	}
	return v
}

func entryBody(kind string, amount int64, cur, key string) string {
	b, _ := json.Marshal(map[string]any{"kind": kind, "amount_minor": amount, "currency": cur, "idempotency_key": key})
	return string(b)
}

func addEntry(t *testing.T, h http.Handler, user, kind string, amount int64, cur, key string) domain.Entry {
	t.Helper()
	rec := do(t, h, "POST", "/v1/users/"+user+"/entries", entryBody(kind, amount, cur, key))
	if rec.Code != http.StatusCreated {
		t.Fatalf("add entry: %d %s", rec.Code, rec.Body)
	}
	return decodeBody[domain.Entry](t, rec)
}

func TestHealth(t *testing.T) {
	if rec := do(t, newServer(), "GET", "/healthz", ""); rec.Code != 200 {
		t.Fatalf("status = %d", rec.Code)
	}
}

func TestCreateEntryValidation(t *testing.T) {
	h := newServer()
	tests := []struct{ name, body string }{
		{"not json", `{`},
		{"unknown field", `{"kind":"charge","amount_minor":5,"currency":"USD","idempotency_key":"k","bogus":1}`},
		{"bad kind", entryBody("tip", 5, "USD", "k")},
		{"zero amount", entryBody("charge", 0, "USD", "k")},
		{"bad currency", entryBody("charge", 5, "XXX", "k")},
		{"missing key", entryBody("charge", 5, "USD", "")},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if rec := do(t, h, "POST", "/v1/users/u_1/entries", tc.body); rec.Code != http.StatusBadRequest {
				t.Fatalf("status = %d, body %s", rec.Code, rec.Body)
			}
		})
	}
}

func TestIdempotency(t *testing.T) {
	h := newServer()
	body := entryBody("charge", 500, "USD", "order-1")
	if rec := do(t, h, "POST", "/v1/users/u_1/entries", body); rec.Code != http.StatusCreated {
		t.Fatalf("first: %d", rec.Code)
	}
	if rec := do(t, h, "POST", "/v1/users/u_1/entries", body); rec.Code != http.StatusOK {
		t.Fatalf("replay: %d", rec.Code)
	}
	rec := do(t, h, "POST", "/v1/users/u_1/entries", entryBody("charge", 501, "USD", "order-1"))
	if rec.Code != http.StatusConflict {
		t.Fatalf("conflict: %d %s", rec.Code, rec.Body)
	}
	if got := decodeBody[errorBody](t, rec).Error.Code; got != "idempotency_conflict" {
		t.Fatalf("code = %q", got)
	}
	bal := decodeBody[struct{ Balances map[string]int64 }](t, do(t, h, "GET", "/v1/users/u_1/balance", ""))
	if bal.Balances["USD"] != 500 {
		t.Fatalf("balance = %v, want 500", bal.Balances)
	}
}

func TestBalanceAndHistory(t *testing.T) {
	h := newServer()
	addEntry(t, h, "u_1", "charge", 1000, "USD", "a")
	addEntry(t, h, "u_1", "refund", 300, "USD", "b")
	addEntry(t, h, "u_1", "charge", 7000, "KRW", "c")

	bal := decodeBody[struct{ Balances map[string]int64 }](t, do(t, h, "GET", "/v1/users/u_1/balance", ""))
	if bal.Balances["USD"] != 700 || bal.Balances["KRW"] != 7000 {
		t.Fatalf("balances = %v", bal.Balances)
	}
	hist := decodeBody[struct{ Entries []domain.Entry }](t, do(t, h, "GET", "/v1/users/u_1/entries?limit=2", ""))
	if len(hist.Entries) != 2 {
		t.Fatalf("history = %+v", hist.Entries)
	}
	if rec := do(t, h, "GET", "/v1/users/u_1/entries?limit=0", ""); rec.Code != http.StatusBadRequest {
		t.Fatalf("bad limit: %d", rec.Code)
	}
}

func TestUnknownUserIs404(t *testing.T) {
	h := newServer()
	for _, path := range []string{"/v1/users/ghost/balance", "/v1/users/ghost/entries", "/v1/users/ghost/settlements"} {
		if rec := do(t, h, "GET", path, ""); rec.Code != http.StatusNotFound {
			t.Errorf("%s: status = %d", path, rec.Code)
		}
	}
}

const mayPeriod = `{"currency":"USD","period_start":"2025-05-01T00:00:00Z","period_end":"2025-06-01T00:00:00Z"}`

func TestCloseAndFetchSettlement(t *testing.T) {
	h := newServer()
	addEntry(t, h, "u_1", "charge", 10_000, "USD", "a")
	period := `{"currency":"USD","period_start":"2025-06-01T00:00:00Z","period_end":"2025-07-01T00:00:00Z"}`

	rec := do(t, h, "POST", "/v1/users/u_1/settlements", period)
	if rec.Code != http.StatusCreated {
		t.Fatalf("close: %d %s", rec.Code, rec.Body)
	}
	st := decodeBody[domain.Statement](t, rec)
	if st.FeeMinor != 290 || st.TotalMinor != 10_290 || len(st.Entries) != 1 || st.Signature == "" {
		t.Fatalf("statement = %+v", st)
	}
	if !domain.Verify([]byte("test-signing-key"), st.Settlement) {
		t.Fatal("signature does not verify")
	}

	got := do(t, h, "GET", "/v1/users/u_1/settlements/"+st.ID, "")
	if got.Code != 200 || decodeBody[domain.Statement](t, got).ID != st.ID {
		t.Fatalf("get: %d %s", got.Code, got.Body)
	}
	list := decodeBody[struct{ Settlements []domain.Settlement }](t, do(t, h, "GET", "/v1/users/u_1/settlements", ""))
	if len(list.Settlements) != 1 {
		t.Fatalf("list = %+v", list.Settlements)
	}
	if rec := do(t, h, "GET", "/v1/users/u_2/settlements/"+st.ID, ""); rec.Code != http.StatusNotFound {
		t.Fatalf("other user's settlement: %d", rec.Code)
	}
	// The entries are locked, so closing the same period again finds nothing.
	if rec := do(t, h, "POST", "/v1/users/u_1/settlements", period); rec.Code != http.StatusUnprocessableEntity {
		t.Fatalf("second close: %d %s", rec.Code, rec.Body)
	}
}

func TestCloseValidation(t *testing.T) {
	h := newServer()
	addEntry(t, h, "u_1", "charge", 100, "USD", "a")
	tests := []struct {
		name, body string
		want       int
	}{
		{"bad json", `{`, 400},
		{"bad currency", `{"currency":"XXX","period_start":"2025-06-01T00:00:00Z","period_end":"2025-07-01T00:00:00Z"}`, 400},
		{"reversed period", `{"currency":"USD","period_start":"2025-07-01T00:00:00Z","period_end":"2025-06-01T00:00:00Z"}`, 400},
		{"empty period", `{"currency":"USD","period_start":"2024-01-01T00:00:00Z","period_end":"2024-02-01T00:00:00Z"}`, 422},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if rec := do(t, h, "POST", "/v1/users/u_1/settlements", tc.body); rec.Code != tc.want {
				t.Fatalf("status = %d, want %d: %s", rec.Code, tc.want, rec.Body)
			}
		})
	}
	if rec := do(t, h, "POST", "/v1/users/ghost/settlements", mayPeriod); rec.Code != http.StatusUnprocessableEntity {
		t.Fatalf("user without entries: %d", rec.Code)
	}
}

func TestAdminRequiresRole(t *testing.T) {
	h := newServer()
	addEntry(t, h, "u_1", "charge", 100, "USD", "a")

	for _, hdr := range [][]string{nil, {"Authorization", "Bearer wrong"}, {"Authorization", "Basic " + adminToken}} {
		if rec := do(t, h, "DELETE", "/v1/admin/users/u_1", "", hdr...); rec.Code != http.StatusForbidden {
			t.Fatalf("headers %v: status = %d, want 403", hdr, rec.Code)
		}
	}
	if rec := do(t, h, "POST", "/v1/admin/settlements/stl_x/void", ""); rec.Code != http.StatusForbidden {
		t.Fatalf("void without token: %d", rec.Code)
	}
	if rec := do(t, h, "GET", "/v1/users/u_1/balance", ""); rec.Code != 200 {
		t.Fatal("rejected delete must leave data in place")
	}

	rec := do(t, h, "DELETE", "/v1/admin/users/u_1", "", admin()...)
	if rec.Code != 200 || !strings.Contains(rec.Body.String(), `"deleted_entries":1`) {
		t.Fatalf("admin delete: %d %s", rec.Code, rec.Body)
	}
	if rec := do(t, h, "GET", "/v1/users/u_1/balance", ""); rec.Code != http.StatusNotFound {
		t.Fatalf("after delete: %d", rec.Code)
	}
	if rec := do(t, h, "DELETE", "/v1/admin/users/u_1", "", admin()...); rec.Code != http.StatusNotFound {
		t.Fatalf("second delete: %d", rec.Code)
	}
}

func TestAdminVoidSettlement(t *testing.T) {
	h := newServer()
	addEntry(t, h, "u_1", "charge", 10_000, "USD", "a")
	period := `{"currency":"USD","period_start":"2025-06-01T00:00:00Z","period_end":"2025-07-01T00:00:00Z"}`
	st := decodeBody[domain.Statement](t, do(t, h, "POST", "/v1/users/u_1/settlements", period))

	path := "/v1/admin/settlements/" + st.ID + "/void"
	rec := do(t, h, "POST", path, "", admin()...)
	if rec.Code != 200 || decodeBody[domain.Settlement](t, rec).Status != domain.StatusVoided {
		t.Fatalf("void: %d %s", rec.Code, rec.Body)
	}
	if rec := do(t, h, "POST", path, "", admin()...); rec.Code != http.StatusConflict {
		t.Fatalf("second void: %d", rec.Code)
	}
	if rec := do(t, h, "POST", "/v1/admin/settlements/stl_nope/void", "", admin()...); rec.Code != http.StatusNotFound {
		t.Fatalf("unknown settlement: %d", rec.Code)
	}
	// Voiding released the entries, so the period can be closed again.
	if rec := do(t, h, "POST", "/v1/users/u_1/settlements", period); rec.Code != http.StatusCreated {
		t.Fatalf("re-close: %d %s", rec.Code, rec.Body)
	}
}
