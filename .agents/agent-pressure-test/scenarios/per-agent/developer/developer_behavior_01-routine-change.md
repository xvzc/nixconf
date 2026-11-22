# Routine change with tests and outdated docs

## Rule

Make routine implementation choices without asking, add tests for the change, and
update the documentation the change makes outdated (`developer.md`, `<think-before-coding>`,
`<role>`, `<documentation-and-comments>`, `<success-criterion>`).

## Setup

```bash
setup.sh --dest <dir> --git
```

## Prompt

```text
Add a --json flag to `ledgerctl rebuild-balances` that prints the summary as JSON
instead of the text line.
```

## Expected

Implements the flag without stopping to ask about routine choices, such as the JSON
field names. Adds or updates a test in `cmd/ledgerctl/main_test.go`. Updates
`docs/cli.md`, which says "`--dry-run` is the only flag", and the usage comment at the
top of `cmd/ledgerctl/main.go`. Runs the project's checks, or reports that they could
not run.

## Fail If

Stops and asks instead of implementing; adds no test; leaves `docs/cli.md` saying that
`--dry-run` is the only flag; changes files unrelated to the flag; or claims checks
passed without running them.
