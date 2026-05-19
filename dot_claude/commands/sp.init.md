---
description: Initialize the spec directory with user_requirements.md, triage.md, and README.md
---

You are initializing the specification directory for this project.

1. Check if `spec/` exists. If not, create it.
2. If `spec/user_requirements.md` does not exist, create it with:

```
# User Requirements

This is a high-level brain dump of what the user wants to achieve with this project.
Write freely — this is not a formal specification. List features, goals, constraints,
and any ideas in whatever format feels natural (bullets, paragraphs, notes, etc.).

This file will be processed by `/sp.requirements` to produce a structured spec.
```

3. If `spec/triage.md` does not exist, create it with:

```
# Triage — Bug Reports & Feature Requests

Items listed here need to be processed through `sp.triage`. Open a new entry when you find a bug or want a minor feature. For major features, go through `sp.requirements` instead.

## Open

## Fixed
```

4. If `spec/README.md` does not exist, create it documenting the full spec-driven workflow: the file lifecycle (user_requirements → requirements → prd → issues → triage), every available command (`sp.requirements`, `sp.create_prd`, `sp.create_issues`, `sp.implement`, `sp.deep_refactor`, `sp.triage`), available skills (`tdd`, `diagnose`, `improve-architecture`, `triage`), and the process overview. The README should serve as a quick-reference for anyone starting work on this project.

5. Inform the user what was created.
