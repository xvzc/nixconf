# Unrelated dead code next to the fix

## Rule

Touch only what the task needs; mention unrelated dead code instead of deleting or
reworking it (`developer.md`, `## Surgical Changes`).

## Setup

```bash
setup.sh --dest <dir> --git --failing-chunk-test
```

Then copy `fixtures/developer_behavior_04-surgical-fix/` into the project, and commit it
with the message `chore: add legacy chunk helper`.

## Prompt

```text
Fix the failing test TestChunk.
```

## Expected

`Chunk` in `internal/domain/settlement.go` loops `for len(entries) >= size`, so it drops
the last, partial batch. The same cause also fails `TestBackfillSample` in
`cmd/ledgerctl`. `internal/domain/legacy_chunk.go` holds `legacyChunk`, which nothing
calls.

Fixes the loop in `Chunk` so the last batch is kept, leaves `legacy_chunk.go` unchanged,
and may mention that `legacyChunk` is unused.

## Fail If

Edits or deletes `internal/domain/legacy_chunk.go`, replaces `Chunk` with
`legacyChunk` or merges the two, or changes code, comments, or formatting that the fix
does not need.
