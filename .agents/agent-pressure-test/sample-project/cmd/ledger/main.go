// Command ledger runs the ledger-service HTTP server.
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/parcelly/ledger-service/internal/api"
	"github.com/parcelly/ledger-service/internal/config"
	"github.com/parcelly/ledger-service/internal/store"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("ledger: %v", err)
	}
}

func run() error {
	cfg, err := config.Load(os.Getenv)
	if err != nil {
		return err
	}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	st, closeStore, err := store.Open(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeStore()

	srv := &http.Server{
		Addr: cfg.HTTPAddr,
		Handler: api.New(api.Options{
			Store:      st,
			AdminToken: cfg.AdminToken,
			SigningKey: []byte(cfg.SigningKey),
		}).Routes(),
		ReadHeaderTimeout: 5 * time.Second,
	}
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = srv.Shutdown(shutdownCtx)
	}()

	log.Printf("ledger: env=%s store=%s listening on %s", cfg.Env, cfg.Store, cfg.HTTPAddr)
	if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}
