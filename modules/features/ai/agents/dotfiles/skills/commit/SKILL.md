# commit

## When to apply

Apply this skill whenever a commit is needed in a local version control system (git, jj, Fossil, etc.) — whether invoked explicitly via `/commit` or when the user asks to commit, save a checkpoint, or record changes in any VCS context.

## Steps

Follow these steps in order. Do not skip any step.

### 1. Group changes and commit each group

Inspect the VCS status and the conversation context (what was discussed and worked on this session). Identify how many distinct topics the changes cover — e.g. a refactor to one package, a bug fix, a config change, a docs update.

If multiple topics are present, split the changes accordingly: stage only the files relevant to each topic and produce a separate commit per topic. If everything clearly belongs to one topic, a single commit is fine.

For each group:

#### 1a. Determine commit message convention

Check in this order:
1. **commitlint config exists** (`commitlint.config.*`, `.commitlintrc.*`, or a `commitlint` key in `package.json`) — use it as the rule set.
2. **No commitlint config, but VCS log exists** — inspect the recent log (e.g. `git log --oneline -20`) and infer the project's convention (type vocabulary, scope style, subject casing, etc.).
3. **No log** — default to the Conventional Commits standard.

Regardless of which path is taken, **never use `!` (e.g. `feat!:`) or a `BREAKING CHANGE:` footer** unless the user explicitly instructs it.

#### 1b. Stage, validate, and commit

1. Stage only the files in this group.
2. Draft a commit message consistent with the convention determined above.
3. If a commitlint config is present, validate the message before committing:
   ```
   echo "<message>" | commitlint
   ```
   Fix and re-validate if it fails. Do not commit until it passes.
4. Commit using a HEREDOC to preserve formatting:
   ```
   git commit -m "$(cat <<'EOF'
   <message>
   EOF
   )"
   ```
5. Repeat for the next group.
