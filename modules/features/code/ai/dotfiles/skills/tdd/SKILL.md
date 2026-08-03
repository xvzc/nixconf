---
name: tdd
description: Use when the user explicitly requests TDD for a coding task.
---

## Steps

Follow this TDD cycle for the requested coding task — no exceptions unless TDD is clearly inappropriate.

### 1. Natural language design

Describe the types, interfaces, and function signatures in plain language — no code yet. Present to the user and iterate until approved.

### 2. Natural language test scenarios

List the test scenarios in plain language (happy path, edge cases, failure cases). Present to the user and iterate until approved.

### 3. Red

Write the test code based on the approved scenarios. Run the tests and confirm they fail. If a test passes without any implementation, the test is wrong — fix it before proceeding.

### 4. Green

Write the minimum implementation needed to make the tests pass. Run the tests and confirm they all pass.

### 5. Refactor

Clean up the code while keeping all tests green.

If TDD is clearly inappropriate for a task (e.g. config, infra, pure refactoring with existing tests), say so explicitly and ask for permission to skip before proceeding.
