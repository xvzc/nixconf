---
description: Toggle TDD mode on or off
argument-hint: on|off
---

# tdd

## Subcommands

### `on`

1. Save a project memory: TDD mode is **active**.
2. Reply: "TDD mode enabled."

While TDD mode is active, follow this cycle for every coding task — no exceptions:

#### 1. Natural language design

Describe the types, interfaces, and function signatures in plain language — no code yet. Present to the user and iterate until approved.

#### 2. Natural language test scenarios

List the test scenarios in plain language (happy path, edge cases, failure cases). Present to the user and iterate until approved.

#### 3. Red

Write the test code based on the approved scenarios. Run the tests and confirm they fail. If a test passes without any implementation, the test is wrong — fix it before proceeding.

#### 4. Green

Write the minimum implementation needed to make the tests pass. Run the tests and confirm they all pass.

#### 5. Refactor

Clean up the code while keeping all tests green.

If TDD is clearly inappropriate for a task (e.g. config, infra, pure refactoring with existing tests), say so explicitly and ask for permission to skip before proceeding.

---

### `off`

1. Update the project memory: TDD mode is **inactive**.
2. Reply: "TDD mode disabled."

Return to normal coding behavior.

---

If `$ARGUMENTS` is empty, check project memory for the current TDD mode state and report it (e.g. "TDD mode is currently on." or "TDD mode is currently off."). If no record exists, report "TDD mode is off."

Otherwise, execute the `$ARGUMENTS` subcommand above.
