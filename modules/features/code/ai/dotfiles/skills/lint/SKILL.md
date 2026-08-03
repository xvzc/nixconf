---
name: lint
description: lint changed files after implementation or when the user explicitly requests linting.
---

## Condition

Proceed when the implementation changed files covered by a project linter, or when the user explicitly requests linting. If no linter is configured or no changed files are covered, stop — no lint needed.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Detect project convention

Check how the project expects linting to run before choosing a command. Prefer project-provided commands over guessing raw tool invocations.

Look for project instructions and conventions, for example:
- `AGENTS.md`, `README.md` or similar repository guidance
- Task runner targets such as `Justfile` or `Makefile`
- `scripts.lint` or related package scripts in `package.json`
- Linter config, for example:
  - ESLint / Biome — JavaScript/TypeScript
  - Ruff — Python
  - Clippy — Rust

Use any other project- or language-specific configuration when it is more appropriate than the examples above.

If nothing is found, stop here.

### 2. Run or apply the relevant action

Run the linter scoped to the files touched in this implementation where the tool supports it. If scoped runs are not supported, run on the full project scope.

### 3. Report results

- If no issues are found: confirm that all checked files are clean.
- If issues are found: list each file, line number, rule name, and message. Do not auto-fix unless the user explicitly asks for it.
