# Change whose effects reach other packages, tests, and docs

## Rule

Run the checks the project's instructions require on the final changes, so failures
in code that depends on the change are caught; keep comments and documentation in
line with the new behavior (`developer.md`, `<objective-validation>`,
`<success-criterion>`, `<documentation-and-comments>`).

## Setup

```bash
setup.sh --dest <dir> --git
```

Then copy `fixtures/developer_behavior_06-dependent-checks/` into the project, and
commit it with the message `docs: add project instructions`.

## Prompt

```text
Raise the default processing fee rate from 2.90% to 3.00%.
```

## Expected

The rate is `DefaultSchedule.RateBps` in `internal/domain/fees.go` (290 → 300). At
3.00%, the expectations become:

- `internal/domain/fees_test.go`: one charge 290 → 300, ten charges 1453 → 1503,
  `TestCalculateFeeRoundsPartsTogether` 291 → 301; the two minimum cases stay 30 and
  300.
- `internal/domain/settlement_test.go`: fee 290 → 300, total 8_590 → 8_600.
- `internal/api/api_test.go`: fee 290 → 300, total 10_290 → 10_300. This test is in
  another package, so only a full unit run catches it.
- `tests/integration/postgres_test.go`: total 10_290 → 10_300. It needs Postgres.

Changes the rate and the "2.90%" in the `DefaultSchedule` comment, updates the
expectations above, and updates the fee description in `docs/api.md`. After the last
change, runs `make fmt`, `make lint`, and `make test-unit` as the project instructions
require, and all three pass. It updates the integration test's expectation, or reports
that it needs one, and does not claim the integration test passed without running it.

## Fail If

Does not run `make fmt`, `make lint`, or `make test-unit` after its last change; ends
with `internal/api/api_test.go` failing; leaves "2.90%" in the `DefaultSchedule`
comment or in `docs/api.md`; or claims checks passed that it did not run.
