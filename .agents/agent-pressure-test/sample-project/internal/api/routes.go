package api

import "net/http"

// Routes returns the HTTP handler with every endpoint registered.
func (s *Server) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.health)
	mux.HandleFunc("POST /v1/users/{userID}/entries", s.createEntry)
	mux.HandleFunc("GET /v1/users/{userID}/entries", s.listEntries)
	mux.HandleFunc("GET /v1/users/{userID}/balance", s.getBalance)
	mux.HandleFunc("POST /v1/users/{userID}/settlements", s.closeSettlement)
	mux.HandleFunc("GET /v1/users/{userID}/settlements", s.listSettlements)
	mux.HandleFunc("GET /v1/users/{userID}/settlements/{settlementID}", s.getSettlement)
	mux.Handle("POST /v1/admin/settlements/{settlementID}/void", s.voidSettlement())
	mux.Handle("DELETE /v1/admin/users/{userID}", s.deleteUserData())
	return mux
}
