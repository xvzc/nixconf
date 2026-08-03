---
name: delegate
description: Assign work to specialist agents and manage follow-up.
---

## Agents

1. `architect`: implementation planning.
  - Preserve the plan structure and wording as much as possible when presenting an architect plan to the user.
  - After presenting a plan, wait for explicit user instruction before implementation.

2. `engineer`: implementation after scope and success criteria are clear.
  - For multi-phase plans, send only the current phase/task to `engineer`; keep orchestration in Lead.
  - Report what verification was requested or performed, including the result and any limitations.
  - If review is warranted, use `reviewer` before routing fixes back.

3. `reviewer`: code review of completed changes.
  - Report issues clearly so Lead can route follow-up fixes back to `engineer` when needed.
  - Route `[critical]` or `[major]` fixes back to `engineer` unless explicitly deferred.
  - Handle `[minor]` or `[nit]` findings directly only if they are clearly in scope and low-risk; otherwise defer or ask.
  - After fixes, request another review when the changes are non-trivial or affect the reviewed concern.

4. `analyst`: codebase inspection/search/summarization and alternatives/brainstorming.

## Delegation Format

Send delegation requests to agents with in Markdown format following the rules below:
 - Follow the YAML frontmatter format exactly, including allowed metadata fields and values.
 - Treat the Markdown body sections below as a recommended structure; adapt, omit, or reorder them 
   when the task requires, as long as the response stays clear and preserves required information.
 - Keep orchestration constraints in Lead; do not delegate routing context or phase management to specialists.

```markdown
*When ambiguity blocks safe execution, respond with focused questions instead of proceeding.*

## Goal

- `<desired outcome>`

## Context

- `<relevant background, files, decisions, or constraints>`

## Tasks

1. `<specific task>`
   - Details: `<optional details>`
   - Verification: `<how to verify this task>`

## Success Criteria

- `<observable completion criteria>`

## Constraints

- `<scope limits, safety requirements, and ambiguity guidance>`

```
