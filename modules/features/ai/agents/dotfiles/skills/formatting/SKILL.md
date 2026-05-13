# formatting

## When to apply

Apply this skill automatically after the user's requested implementation is complete, if **all** of the following are true:
- A formatting instruction exists in the project (e.g. `.editorconfig`, `prettier`, `rustfmt`, `gofmt`, `black`, `stylua`, or any formatter config file)

**Do not apply** this skill if any of the following are present:
- A pre-commit hook already enforces formatting (e.g. `husky`, `lefthook`, `.pre-commit-config.yaml` with a formatter hook)
- Another skill in the active skills directory already covers formatting

## Steps

Follow these steps in order. Do not skip any step.

### 1. Run the formatter on changed files only

Run the formatter scoped to the files touched in this implementation. Do not reformat the entire codebase unless the project convention requires it.

### 2. Report

If any files were reformatted, list them. If everything was already clean, confirm that.
