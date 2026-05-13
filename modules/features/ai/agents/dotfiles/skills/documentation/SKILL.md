# documentation

## When to apply

Apply this skill automatically after the user's requested implementation is complete, if **all** of the following are true:
- A documentation instruction exists in the project (e.g. `CLAUDE.md`, `docs/`, `README.md`, or any project-level doc convention)
- The implementation introduced a feature change or addition that may need to be reflected in documentation

**Do not apply** this skill if any of the following are present:
- The project already has an automated doc-generation or doc-sync tool configured (e.g. `typedoc`, `sphinx`, `mkdocs` with CI hooks)
- Another skill in the active skills directory already covers documentation

## Steps

Follow these steps in order. Do not skip any step.

### 1. Determine whether documentation needs updating

Review what changed in this implementation. Ask:
- Was a new feature, option, flag, or behavior introduced?
- Was an existing feature modified in a user-visible way?
- Was anything removed or deprecated?

If none of the above, stop — no doc update needed.

### 2. Identify affected documents

Locate the relevant documentation targets based on what changed:
- `README.md` for user-facing feature changes
- Inline doc comments (JSDoc, rustdoc, etc.) for API changes
- Any project-specific docs directory or wiki files referenced in the project instructions

### 3. Update documentation

Apply the minimum necessary updates to reflect the change. Do not rewrite sections unrelated to the current change.

### 4. Report

Briefly state what was updated and why, or confirm that no update was needed.
