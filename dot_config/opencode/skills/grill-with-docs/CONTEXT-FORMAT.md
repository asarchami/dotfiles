# Glossary Format (used for spec/glossary.md)

## Structure

```md
# Glossary

Domain terminology for this project. Resolved during requirements interviews —
terms are captured as they are calibrated.

## Language

**<Term>**:
{A concise description of what this term means in this project's context.}
_Avoid_: {synonyms that should not be used}

## Relationships

- An **<TermA>** produces one or more **<TermB>**
- A **<TermB>** belongs to exactly one **<TermA>**

## Example dialogue

> **Dev:** "When a **<TermA>** does X, do we create the **<TermB>** immediately?"
> **Domain expert:** "No — a **<TermB>** is only generated when Y happens."

## Flagged ambiguities

- "ambiguous-term" was used to mean both **<TermA>** and **<TermC>** — resolved: these are distinct concepts.
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Only include domain-specific terms.** General programming concepts (timeouts, error handling, utility patterns) don't belong.
- **Write an example dialogue.** A conversation between a dev and a domain expert that demonstrates how the terms interact naturally and clarifies boundaries between related concepts.
