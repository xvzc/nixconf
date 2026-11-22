// Package api implements the HTTP JSON API of ledger-service.
package api

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/parcelly/ledger-service/internal/domain"
	"github.com/parcelly/ledger-service/internal/store"
)

// Options configures a Server.
type Options struct {
	Store      store.Store
	AdminToken string
	SigningKey []byte
	Schedule   domain.FeeSchedule
	// Now is the clock; nil means time.Now.
	Now func() time.Time
}

// Server holds the dependencies of the HTTP handlers.
type Server struct {
	opts Options
}

// New returns a Server. A zero FeeSchedule means domain.DefaultSchedule.
func New(opts Options) *Server {
	if opts.Now == nil {
		opts.Now = time.Now
	}
	if opts.Schedule == (domain.FeeSchedule{}) {
		opts.Schedule = domain.DefaultSchedule
	}
	return &Server{opts: opts}
}

type errorBody struct {
	Error struct {
		Code    string `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if v != nil {
		_ = json.NewEncoder(w).Encode(v)
	}
}

func writeError(w http.ResponseWriter, status int, code, msg string) {
	var b errorBody
	b.Error.Code, b.Error.Message = code, msg
	writeJSON(w, status, b)
}

// fail maps domain and store errors to HTTP responses.
func fail(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, store.ErrNotFound):
		writeError(w, http.StatusNotFound, "not_found", err.Error())
	case errors.Is(err, store.ErrIdempotencyConflict):
		writeError(w, http.StatusConflict, "idempotency_conflict", err.Error())
	case errors.Is(err, store.ErrEntryLocked), errors.Is(err, store.ErrAlreadyVoided):
		writeError(w, http.StatusConflict, "conflict", err.Error())
	case errors.Is(err, domain.ErrNothingToSettle):
		writeError(w, http.StatusUnprocessableEntity, "nothing_to_settle", err.Error())
	case errors.Is(err, domain.ErrBadPeriod), errors.Is(err, domain.ErrBadCurrency),
		errors.Is(err, domain.ErrNoUser), errors.Is(err, domain.ErrBadKind),
		errors.Is(err, domain.ErrBadAmount), errors.Is(err, domain.ErrBadKey),
		errors.Is(err, domain.ErrMemoTooLong), errors.Is(err, domain.ErrFutureEntry):
		writeError(w, http.StatusBadRequest, "invalid_request", err.Error())
	default:
		log.Printf("internal error: %v", err)
		writeError(w, http.StatusInternalServerError, "internal", "internal error")
	}
}

// decode reads a JSON body, rejecting unknown fields and trailing data.
func decode(r *http.Request, v any) error {
	dec := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
	dec.DisallowUnknownFields()
	if err := dec.Decode(v); err != nil {
		return err
	}
	if dec.More() {
		return errors.New("unexpected data after JSON body")
	}
	return nil
}

func newID(prefix string) string {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return prefix + "_" + hex.EncodeToString(b)
}
