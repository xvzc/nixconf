---
name: architectural-decision-record
description: Use when the user asks to record, write, or update an Architectural Decision Record (ADR) for a decision, such as "record this decision" or "write an ADR for X".
---

# Architectural Decision Record

Write an ADR for the decision the user names, structured for both machine parsing and
human reference.

## Writing Rules

- Take the context, decision, alternatives, and stakeholders from the user's request
  and the conversation. If any of them cannot be determined, ask the user before
  writing the ADR; do not invent them.
- Use precise, unambiguous language.
- Include both positive and negative consequences.
- Give every alternative a rejection reason.
- Number multi-item sections with coded bullets: a 3-letter code and a 3-digit number,
  such as `POS-001`, continuing the numbering across subsections.
- Omit a template item that has no content rather than filling it with a placeholder.
- Set `date` to today's date, and `status` to `Proposed` unless the user gives another
  status.

## File Location

Save the ADR as `docs/adr/adr-NNNN-<title-slug>.md`, relative to the repository root,
such as `docs/adr/adr-0001-database-selection.md`.

- Set `NNNN` to the next 4-digit number after the highest existing ADR in `docs/adr/`,
  or `0001` if there is none.
- Create `docs/adr/` if it does not exist.
- Never overwrite an existing ADR. When the new ADR supersedes one, set `supersedes` in
  the new ADR, and update the old ADR's `status` and `superseded_by` only if the user
  asks.

## Template

The documentation file must follow the template below, ensuring that all sections are filled out appropriately. The front matter for the markdown should be structured correctly as per the example following:

```markdown
---
title: "ADR-NNNN: [Decision Title]"
status: "Proposed"
date: "YYYY-MM-DD"
authors: "[Stakeholder Names/Roles]"
tags: ["architecture", "decision"]
supersedes: ""
superseded_by: ""
---

# ADR-NNNN: [Decision Title]

## Status
**Proposed** | Accepted | Rejected | Superseded | Deprecated

## Context

[Problem statement, technical constraints, business requirements, and environmental
factors requiring this decision.]

## Decision

[Chosen solution with clear rationale for selection.]

## Consequences

### Positive

- **POS-001**: [Beneficial outcomes and advantages]
- **POS-002**: [Performance, maintainability, scalability improvements]
- **POS-003**: [Alignment with architectural principles]

### Negative

- **NEG-001**: [Trade-offs, limitations, drawbacks]
- **NEG-002**: [Technical debt or complexity introduced]
- **NEG-003**: [Risks and future challenges]

## Alternatives Considered

### [Alternative 1 Name]

- **ALT-001**: **Description**: [Brief technical description]
- **ALT-002**: **Rejection Reason**: [Why this option was not selected]

### [Alternative 2 Name]

- **ALT-003**: **Description**: [Brief technical description]
- **ALT-004**: **Rejection Reason**: [Why this option was not selected]

## Implementation Notes

- **IMP-001**: [Key implementation considerations]
- **IMP-002**: [Migration or rollout strategy if applicable]
- **IMP-003**: [Monitoring and success criteria]

## References

- **REF-001**: [Related ADRs]
- **REF-002**: [External documentation]
- **REF-003**: [Standards or frameworks referenced]
```
