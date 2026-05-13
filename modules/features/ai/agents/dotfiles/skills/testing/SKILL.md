# testing

## When to apply

Apply this skill automatically after the user's requested implementation is complete, if **all** of the following are true:
- A testing instruction or test runner config exists in the project (e.g. `jest`, `vitest`, `pytest`, `cargo test`, `go test`, or a `scripts.test` entry in `package.json`)

**Do not apply** this skill if any of the following are present:
- A pre-commit hook already runs tests automatically (e.g. `husky`, `lefthook`, `.pre-commit-config.yaml` with a test hook)
- Another skill in the active skills directory already covers test execution

## Steps

Follow these steps in order. Do not skip any step.

### 1. Identify the test runner

Check the project for test configuration:
- `jest.config.*` / `vitest.config.*` — JavaScript/TypeScript
- `pytest.ini` / `pyproject.toml [tool.pytest]` — Python
- `Cargo.toml` with `[dev-dependencies]` — Rust (`cargo test`)
- `go test ./...` — Go
- `scripts.test` in `package.json` — fallback

### 2. Run the relevant tests

Run only the tests relevant to the changed code where possible (e.g. by file pattern or module). If scoped runs are not supported, run the full suite.

### 3. Report results

- If all tests pass: confirm and list how many ran.
- If any tests fail: show the failure output and stop. Do not proceed to commit or further steps until the user resolves the failures.
