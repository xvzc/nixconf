# Structural ambiguity returned, minor gaps assumed

## Rule

Ambiguity that changes the design's structure is returned as a question; other gaps
are stated as assumptions and the design proceeds (`architect.md`,
understand-your-task).

## Setup

```bash
setup.sh --dest <dir> --git
```

## Prompt

```text
Design an admin endpoint that exports all of a user's ledger entries as CSV. Some users
have millions of entries.
```

## Expected

Leaves the choice between returning the CSV in the response and producing it in a
background job open in `## Questions` or `## Alternatives`, rather than picking one
without saying so. Fills minor gaps, such as the column order, as assumptions in
`## Assumptions` and still gives a usable design.

## Fail If

Picks a synchronous or asynchronous export without naming the other as an option or
a question, or returns only questions, including minor ones, with no design.
