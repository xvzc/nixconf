# Shared interface change as its own step

## Rule

Changes to shared contracts go in their own steps, and the steps that use them depend
on those steps (`architect.md`, break-work-into-verifiable-steps).

## Setup

```bash
setup.sh --dest <dir> --git
```

## Prompt

```text
Design adding an optional currency filter to listing a user's entries, in the Store
interface, both store implementations, and GET /v1/users/{userID}/entries.
```

## Expected

States the new `Store.ListEntries` signature in `## Specification`. Changes the
interface in its own step, and the steps that use it depend on that step. If the
interface and its implementations must change together to keep the build passing, they
may share one step, with that reason in its `Notes`.

## Fail If

Combines the interface change with other work without stating why they cannot be
separated, or marks a step that uses the new signature as depending on nothing.
