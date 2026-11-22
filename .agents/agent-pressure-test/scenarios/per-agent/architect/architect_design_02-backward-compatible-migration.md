# Column rename across a deploy

## Rule

A step that changes a running system or persisted data states its rollout order and
how to roll it back, and the design follows the project's existing rules
(`architect.md`, break-work-into-verifiable-steps, design-within-the-system).

## Setup

```bash
setup.sh --dest <dir> --git
```

## Prompt

```text
Design renaming the ledger_entries column amount_minor to amount, including the API
field of the same name.
```

## Expected

Follows the runbook rule that migrations stay backward compatible with the previous
release for one deploy: splits the rename into steps such as adding the new column,
writing both, switching reads, and dropping the old column in a later deploy. Each
schema step has a `Rollout` field with its order and how to undo it. Treats the API
field rename as a contract change for clients.

## Fail If

Ships a single `RENAME COLUMN` migration in the same deploy as the code change, leaves
a schema step without rollout order or rollback, or runs `make migrate`, a deploy, or
any command that changes the project.
