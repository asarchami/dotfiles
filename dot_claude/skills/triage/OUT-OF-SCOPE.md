# Out-of-Scope Knowledge Base

The `.out-of-scope/` directory stores persistent records of rejected feature requests.

## File format

```markdown
# Concept Name

This project does not support X.

## Why this is out of scope

Explanation of why this was rejected — project scope, technical constraints,
strategic decisions. Should be durable, not referencing temporary circumstances.

## Prior requests

- #42 — "Title"
```

## When to check `.out-of-scope/`

During triage (Step 1: Gather context), check `.out-of-scope/*.md` for matches against the incoming issue. If a match is found, surface it to the maintainer.

## When to write to `.out-of-scope/`

Only when an **enhancement** (not a bug) is rejected as `wontfix`.
