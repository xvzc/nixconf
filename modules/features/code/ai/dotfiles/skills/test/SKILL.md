---
name: test
description: Run relevant tests after implementation or when the user explicitly requests tests.
---

## Condition

Proceed when the implementation changes executable code, behavior, tests, or runtime-affecting configuration, or when the user explicitly requests tests. If the change is docs-only, comment-only, or non-behavioral, stop — no test run needed.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Detect project convention

Check how the project expects tests to run before choosing a command. Prefer project-provided commands over guessing raw tool invocations.

Look for project instructions and conventions, for example:
- `AGENTS.md`, `README.md` or similar repository guidance
- Task runner targets such as `Justfile` or `Makefile`
- `scripts.test` or related package scripts in `package.json`
- Language-specific test config, for example:
  - Jest / Vitest — JavaScript/TypeScript
  - pytest — Python
  - Cargo test — Rust

Use any other project- or language-specific configuration when it is more appropriate than the examples above.

### 2. Run or apply the relevant action

Run only the tests relevant to the changed code where possible (e.g. by file pattern or module). If scoped runs are not supported, run the full suite.

### 3. Report results

- If all tests pass: confirm and list how many ran.
- If any tests fail: show the failure output and stop. Do not proceed to commit or further steps until the user resolves the failures.
