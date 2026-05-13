# linting

## When to apply

Apply this skill automatically after the user's requested implementation is complete, if **all** of the following are true:
- A linter config or linter-related entry is detectable in the project

**Do not apply** this skill if any of the following are present:
- A pre-commit hook (including Claude Code hooks) already runs linting
- Another skill in the active skills directory already covers linting

If no linter is detected, skip silently.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Detect the linter

Inspect the project root for any linter config or relevant package/tool entries. If nothing is found, stop here.

### 2. Run the linter on changed files only

Run the linter scoped to the files touched in this implementation where the tool supports it. If scoped runs are not supported, run on the full project scope.

### 3. Report results

- If no issues are found: confirm that all checked files are clean.
- If issues are found: list each file, line number, rule name, and message. Do not auto-fix unless the user explicitly asks for it.
