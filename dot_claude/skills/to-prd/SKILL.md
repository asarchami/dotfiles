---
name: to-prd
description: Turn requirements or conversation context into a structured PRD. Use when asked to create, update, or refine a PRD document.
---

# To PRD

Framework for writing and maintaining a Product Requirements Document.

## The 12 Dimensions

Every requirement section in a PRD should clarify these 12 dimensions:

1. **User / Stakeholder** — who benefits from this requirement?
2. **Problem statement** — what specific problem does this solve?
3. **User stories** — "As a [persona], I want [goal] so that [reason]"
4. **Acceptance criteria** — concrete, testable conditions for done
5. **Module sketch & deep module design** — major modules needed; look for deep module opportunities (significant complexity behind a narrow, stable interface with few exported symbols)
6. **Testing strategy** — unit, integration, e2e; what test fixtures/data are needed
7. **Non-functional requirements** — performance, reliability, security, scalability
8. **Edge cases** — boundaries: empty, error, default, concurrent, restart, reconnect, no data, rate limits
9. **Out of scope** — explicitly what is NOT covered
10. **Priority** — Must-have, Should-have, Nice-to-have
11. **Dependencies** — what other requirements or external things must exist first?
12. **Open questions** — what is still unknown or undecided?

## Deep Module Design

Actively look for opportunities to extract **deep modules** — modules that encapsulate significant complexity behind a simple, stable, testable interface (few exported symbols, minimal API surface). The goal is strong encapsulation: callers depend on a simple interface, not the internal complexity.

Distinguish between:
- **Deep modules** — packages hiding significant complexity behind a narrow interface (e.g. `internal/exchange/`, `internal/lua/`, `internal/db/`)
- **Shallow modules** — straightforward packages with minimal hidden complexity (e.g. `internal/config/`, `internal/symbol/`)
- **Thin binaries** — `cmd/*` packages that compose deep modules rather than containing significant logic

## PRD Section Template

Each requirement section should follow this structure:

```
### <Title>

**User / Stakeholder:** <who>

**Problem statement:** <what problem>

**User stories:**
- As a <persona>, I want <goal> so that <reason>

**Acceptance criteria:**
- [ ] <condition>
- [ ] <condition>

**Module sketch & deep module design:** <description of modules, calling out deep vs shallow>

**Testing strategy:** <unit/integration/e2e>

**Non-functional requirements:** <performance, reliability, etc.>

**Edge cases:** <boundary conditions>

**Out of scope:** <what is NOT covered>

**Priority:** <Must-have / Should-have / Nice-to-have>

**Dependencies:** <what must come first>

**Open questions:** <what is still unknown>
```

## Interview Guidance

When interviewing the user about requirements:

- Ask questions **one at a time**. Do not batch questions.
- Start with the most foundational / high-impact questions first (new sections, then cross-cutting implied changes) before drilling into specifics.
- For impacted existing sections, interview only about the specific dimensions that need updating — do not re-interview the entire section.
- If a question can be answered by exploring the codebase, explore instead.
- For each question, provide your recommended answer.
