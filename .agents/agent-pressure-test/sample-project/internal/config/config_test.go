package config

import (
	"strings"
	"testing"
)

func env(m map[string]string) func(string) string {
	return func(k string) string { return m[k] }
}

var full = map[string]string{
	"DATABASE_URL": "postgres://x", "REDIS_URL": "redis://x",
	"LEDGER_ADMIN_TOKEN": "t", "STATEMENT_SIGNING_KEY": "k",
}

func TestLoadDefaults(t *testing.T) {
	c, err := Load(env(full))
	if err != nil {
		t.Fatal(err)
	}
	if c.Env != "local" || c.HTTPAddr != ":8080" || c.Store != StorePostgres {
		t.Fatalf("unexpected defaults: %+v", c)
	}
}

func TestLoadReportsAllMissing(t *testing.T) {
	_, err := Load(env(nil))
	if err == nil {
		t.Fatal("expected error")
	}
	for _, name := range []string{"DATABASE_URL", "REDIS_URL", "LEDGER_ADMIN_TOKEN", "STATEMENT_SIGNING_KEY"} {
		if !strings.Contains(err.Error(), name+": missing variable") {
			t.Errorf("error does not mention %s: %v", name, err)
		}
	}
}

func TestMemoryStoreNeedsNoDatabaseURL(t *testing.T) {
	m := map[string]string{"LEDGER_STORE": "memory", "REDIS_URL": "r", "LEDGER_ADMIN_TOKEN": "t", "STATEMENT_SIGNING_KEY": "k"}
	if _, err := Load(env(m)); err != nil {
		t.Fatal(err)
	}
}

func TestUnknownStore(t *testing.T) {
	m := map[string]string{"LEDGER_STORE": "sqlite"}
	for k, v := range full {
		m[k] = v
	}
	if _, err := Load(env(m)); err == nil || !strings.Contains(err.Error(), "LEDGER_STORE") {
		t.Fatalf("want LEDGER_STORE error, got %v", err)
	}
}
