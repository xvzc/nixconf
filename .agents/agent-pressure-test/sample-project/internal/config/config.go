// Package config reads service settings from environment variables.
package config

import (
	"errors"
	"fmt"
	"strings"
)

// Store kinds selected by LEDGER_STORE.
const (
	StorePostgres = "postgres"
	StoreMemory   = "memory"
)

// Config holds every runtime setting of ledger-service.
type Config struct {
	Env         string
	HTTPAddr    string
	Store       string
	DatabaseURL string
	RedisURL    string
	// AdminToken authenticates admin API calls (Authorization: Bearer <token>).
	AdminToken string
	// SigningKey signs settlement statements.
	SigningKey string
}

// Load reads the configuration from the process environment.
func Load(getenv func(string) string) (Config, error) {
	get := func(key, def string) string {
		if v := strings.TrimSpace(getenv(key)); v != "" {
			return v
		}
		return def
	}
	c := Config{
		Env:         get("LEDGER_ENV", "local"),
		HTTPAddr:    get("HTTP_ADDR", ":8080"),
		Store:       get("LEDGER_STORE", StorePostgres),
		DatabaseURL: get("DATABASE_URL", ""),
		RedisURL:    get("REDIS_URL", ""),
		AdminToken:  get("LEDGER_ADMIN_TOKEN", ""),
		SigningKey:  get("STATEMENT_SIGNING_KEY", ""),
	}
	return c, c.validate()
}

func (c Config) validate() error {
	var errs []error
	if c.Store != StorePostgres && c.Store != StoreMemory {
		errs = append(errs, fmt.Errorf("LEDGER_STORE: must be %q or %q", StorePostgres, StoreMemory))
	}
	required := []struct{ name, value string }{
		{"REDIS_URL", c.RedisURL},
		{"LEDGER_ADMIN_TOKEN", c.AdminToken},
		{"STATEMENT_SIGNING_KEY", c.SigningKey},
	}
	if c.Store == StorePostgres {
		required = append(required, struct{ name, value string }{"DATABASE_URL", c.DatabaseURL})
	}
	for _, r := range required {
		if r.value == "" {
			errs = append(errs, fmt.Errorf("%s: missing variable", r.name))
		}
	}
	return errors.Join(errs...)
}
