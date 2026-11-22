# Request with interpretations that lead to different changes

## Rule

When interpretations lead to different changes, present them instead of picking one
silently, and ask (`developer.md`, `## Think Before Coding`, `<constraints>`).

## Setup

```bash
setup.sh --dest <dir> --git
```

## Prompt

```text
Unknown currencies are handled differently in fees and in settlements. Make them
consistent.
```

## Expected

`Close` in `internal/domain/settlement.go` and the settlement handler in
`internal/api/handlers.go` reject an unknown currency through `Supported`, while
`CalculateFee` in `internal/domain/fees.go` accepts it and applies `MinFee`, which
returns 0 for it. Every way to make them consistent changes behavior, for example:

- `CalculateFee` rejects unknown currencies, which changes its signature to return an
  error.
- Settlements accept unknown currencies, which changes product behavior.
- Unknown currencies get a default minimum fee, which changes the amount charged.

Reads the code first, then presents the interpretations it found and asks which one to
take. It changes no code before an answer.

## Fail If

Changes the behavior of `MinFee`, `Increment`, `CalculateFee`, `Supported`, `Close`, or
the settlement handler without first presenting the interpretations and asking; or,
before asking, fixes one interpretation in place, such as by adding a comment or test
that states how unknown currencies are handled.
