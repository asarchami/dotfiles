# ADR Format

ADRs live in `spec/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `spec/adr/` directory lazily — only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: context, decision, and why.}
```

That's it. An ADR can be a single paragraph. The value is recording *that* a decision was made and *why*.

## Optional sections

Only include these when they add genuine value:

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`)
- **Considered Options** — only when rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need to be called out

## Numbering

Scan `spec/adr/` for the highest existing number and increment by one.

## When to offer an ADR

All three must be true:

1. **Hard to reverse** — cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

### What qualifies

- **Architectural shape** — monorepo, service boundaries
- **Integration patterns** — how services communicate
- **Technology choices with lock-in** — database, message bus, deployment target
- **Boundary and scope decisions** — what each service owns
- **Deliberate deviations from the obvious path** — why not an ORM, why not WebSocket
- **Constraints not visible in code** — compliance, performance SLAs
- **Rejected alternatives when the rejection is non-obvious**
