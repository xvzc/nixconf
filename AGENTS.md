Validate Nix changes with `make check` and `make build`, not `nix build` directly.
Activate with `make switch` only when explicitly asked.

For an agent pressure test, follow `.agents/agent-pressure-test/INSTRUCTION.md`. Use the
directory that `make agents` prints as `<agent-config-dir>`.
