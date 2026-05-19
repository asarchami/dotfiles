---
name: grill-with-docs
description: Grilling session that sharpens terminology, updates the domain glossary, and offers ADRs as decisions crystallise. Use during requirements gathering or anytime fuzzy language needs to be pinned down.
---

# Grill with Docs

Interview the user relentlessly about every aspect of a plan until reaching shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one. For each question, provide your recommended answer.

Ask questions **one at a time**, waiting for feedback before continuing.

If a question can be answered by exploring the codebase, explore instead.

## Domain awareness

During codebase exploration, also look for existing documentation:

- `spec/glossary.md` — domain terminology (equivalent to CONTEXT.md)
- `spec/adr/` — architecture decision records

Create files lazily — only when you have something to write.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `spec/glossary.md`, call it out immediately. "The glossary defines 'bar' as OHLCV data for a specific time, but you seem to mean a tick — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Alpaca account or the bot's internal portfolio tracking?"

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios that probe edge cases and force precision about boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it.

### Update glossary inline

When a term is resolved, update `spec/glossary.md` right there. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md). Do not batch — capture as they happen.

### Offer ADRs sparingly

Only offer to create an ADR in `spec/adr/` when **all three** are true:
1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).
