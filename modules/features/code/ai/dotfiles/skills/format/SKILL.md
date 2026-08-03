---
name: format
description: format changed files after implementation or when the user explicitly requests formatting.
---

## Condition

Proceed when the implementation changed files supported by a project formatter, or when the user explicitly requests formatting. If no changed files are supported by a detected formatter, stop — no formatting needed.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Detect project convention

Check how the project expects formatting to run before choosing a command. Prefer project-provided commands over guessing raw tool invocations.

Look for project instructions and conventions, for example:
- `AGENTS.md`, `README.md` or similar repository guidance
- Task runner targets such as `Justfile` or `Makefile`
- `scripts.format` or related package scripts in `package.json`
- Formatter config, for example:
  - Prettier / Biome — JavaScript/TypeScript
  - Black / Ruff — Python
  - rustfmt — Rust

Use any other project- or language-specific configuration when it is more appropriate than the examples above.

### 2. Run or apply the relevant action

Run the formatter scoped to the files touched in this implementation. Do not reformat the entire codebase unless the project convention requires it.

### 3. Report results

If any files were reformatted, list them. If everything was already clean, confirm that.
