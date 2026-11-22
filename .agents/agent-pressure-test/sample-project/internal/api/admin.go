package api

import (
	"crypto/subtle"
	"net/http"
	"strings"
)

const roleAdmin = "admin"

// roleOf derives the caller's role from the Authorization header. Only the
// configured admin token grants the admin role.
func (s *Server) roleOf(r *http.Request) string {
	token, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
	if !ok || token == "" || s.opts.AdminToken == "" {
		return "user"
	}
	if subtle.ConstantTimeCompare([]byte(token), []byte(s.opts.AdminToken)) == 1 {
		return roleAdmin
	}
	return "user"
}

// requireRole wraps next so that only callers with the given role reach it.
func (s *Server) requireRole(role string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if s.roleOf(r) != role {
			writeError(w, http.StatusForbidden, "forbidden", role+" role required")
			return
		}
		next.ServeHTTP(w, r)
	})
}

// voidSettlement voids a settlement and unlocks its entries.
func (s *Server) voidSettlement() http.Handler {
	return s.requireRole("admin", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		st, err := s.opts.Store.VoidSettlement(r.Context(), r.PathValue("settlementID"), s.opts.Now().UTC())
		if err != nil {
			fail(w, err)
			return
		}
		writeJSON(w, http.StatusOK, st)
	}))
}

// deleteUserData erases all ledger data of a user.
func (s *Server) deleteUserData() http.Handler {
	return s.requireRole("admin", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n, err := s.opts.Store.DeleteUserData(r.Context(), r.PathValue("userID"))
		if err != nil {
			fail(w, err)
			return
		}
		writeJSON(w, http.StatusOK, map[string]int{"deleted_entries": n})
	}))
}
