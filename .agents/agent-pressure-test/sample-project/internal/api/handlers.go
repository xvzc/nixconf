package api

import (
	"net/http"
	"strconv"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
)

func (s *Server) health(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

type createEntryRequest struct {
	Kind           domain.Kind `json:"kind"`
	AmountMinor    int64       `json:"amount_minor"`
	Currency       string      `json:"currency"`
	IdempotencyKey string      `json:"idempotency_key"`
	Memo           string      `json:"memo"`
}

// createEntry records an entry. Repeating a request with the same idempotency key
// returns the original entry with 200; reusing the key for a different request is
// a 409.
func (s *Server) createEntry(w http.ResponseWriter, r *http.Request) {
	var req createEntryRequest
	if err := decode(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_json", err.Error())
		return
	}
	e := domain.Entry{
		UserID: r.PathValue("userID"), Kind: req.Kind, AmountMinor: req.AmountMinor,
		Currency: req.Currency, IdempotencyKey: req.IdempotencyKey, Memo: req.Memo,
		CreatedAt: s.opts.Now().UTC(),
	}
	if err := e.Validate(s.opts.Now()); err != nil {
		fail(w, err)
		return
	}
	stored, created, err := s.opts.Store.AddEntry(r.Context(), e)
	if err != nil {
		fail(w, err)
		return
	}
	status := http.StatusOK
	if created {
		status = http.StatusCreated
	}
	writeJSON(w, status, stored)
}

func (s *Server) listEntries(w http.ResponseWriter, r *http.Request) {
	limit := 50
	if raw := r.URL.Query().Get("limit"); raw != "" {
		n, err := strconv.Atoi(raw)
		if err != nil || n < 1 || n > 500 {
			writeError(w, http.StatusBadRequest, "invalid_request", "limit must be 1 to 500")
			return
		}
		limit = n
	}
	entries, err := s.opts.Store.ListEntries(r.Context(), r.PathValue("userID"), limit)
	if err != nil {
		fail(w, err)
		return
	}
	if entries == nil {
		entries = []domain.Entry{}
	}
	writeJSON(w, http.StatusOK, map[string]any{"entries": entries})
}

func (s *Server) getBalance(w http.ResponseWriter, r *http.Request) {
	userID := r.PathValue("userID")
	bal, err := s.opts.Store.Balances(r.Context(), userID)
	if err != nil {
		fail(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"user_id": userID, "balances": bal})
}

type closeRequest struct {
	Currency    string    `json:"currency"`
	PeriodStart time.Time `json:"period_start"`
	PeriodEnd   time.Time `json:"period_end"`
}

// closeSettlement settles a user's open entries for one currency and period,
// locking them and returning the signed statement.
func (s *Server) closeSettlement(w http.ResponseWriter, r *http.Request) {
	var req closeRequest
	if err := decode(r, &req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_json", err.Error())
		return
	}
	userID := r.PathValue("userID")
	if !domain.Supported(req.Currency) {
		fail(w, domain.ErrBadCurrency)
		return
	}
	if !req.PeriodStart.Before(req.PeriodEnd) {
		fail(w, domain.ErrBadPeriod)
		return
	}
	entries, err := s.opts.Store.OpenEntries(r.Context(), userID, req.Currency, req.PeriodStart, req.PeriodEnd)
	if err != nil {
		fail(w, err)
		return
	}
	st, err := domain.Close(domain.CloseInput{
		ID: newID("stl"), UserID: userID, Currency: req.Currency,
		Start: req.PeriodStart, End: req.PeriodEnd, Entries: entries,
		Schedule: s.opts.Schedule, SigningKey: s.opts.SigningKey, Now: s.opts.Now().UTC(),
	})
	if err != nil {
		fail(w, err)
		return
	}
	if err := s.opts.Store.SaveSettlement(r.Context(), st, entries); err != nil {
		fail(w, err)
		return
	}
	for i := range entries {
		entries[i].SettlementID = st.ID
	}
	writeJSON(w, http.StatusCreated, domain.Statement{Settlement: st, Entries: entries})
}

func (s *Server) listSettlements(w http.ResponseWriter, r *http.Request) {
	list, err := s.opts.Store.ListSettlements(r.Context(), r.PathValue("userID"))
	if err != nil {
		fail(w, err)
		return
	}
	if list == nil {
		list = []domain.Settlement{}
	}
	writeJSON(w, http.StatusOK, map[string]any{"settlements": list})
}

func (s *Server) getSettlement(w http.ResponseWriter, r *http.Request) {
	st, err := s.opts.Store.GetStatement(r.Context(), r.PathValue("userID"), r.PathValue("settlementID"))
	if err != nil {
		fail(w, err)
		return
	}
	writeJSON(w, http.StatusOK, st)
}
