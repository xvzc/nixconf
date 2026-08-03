---
name: documentation
description: Update docs after implementation or when the user explicitly requests documentation updates.
---

## Condition

Proceed when the implementation changes user-facing or documented behavior, or when the user explicitly requests documentation updates.

First review what changed in this implementation. Ask:
- Was a new feature, option, flag, or behavior introduced?
- Was an existing feature modified in a user-visible way?
- Was anything removed or deprecated?

If none of the above, stop — no doc update needed.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Detect project convention

Check how the project expects documentation to be maintained before choosing what to update.

Look for project instructions and conventions, for example:
- `AGENTS.md`, `README.md` or similar repository guidance
- Docs directories or wiki files
- Inline docs conventions such as JSDoc, rustdoc, or docstrings
- Changelog guidance if relevant

Use any other project- or language-specific configuration when it is more appropriate than the examples above.

### 2. Run or apply the relevant action

Apply the minimum necessary updates to the relevant documentation targets based on what changed:
- `README.md` for user-facing feature changes
- Inline doc comments (JSDoc, rustdoc, etc.) for API changes
- Any project-specific docs directory, wiki files, or changelog referenced in the project instructions

Do not rewrite sections unrelated to the current change.

### 3. Report results

Briefly state what was updated and why, or confirm that no update was needed.
