---
name: python-code-quality
description: Improves Python code quality through ruff linting, mypy type checking, Pythonic idioms, and refactoring. Use when reviewing code for quality issues, adding type hints, configuring static analysis tools, or refactoring Python code.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\u2728"
    homepage: https://github.com/wdm0006/python-skills
---

# Python Code Quality

## Quick Reference

| Tool | Purpose | Command |
|------|---------|---------|
| ruff | Lint + format | `ruff check src && ruff format src` |
| mypy | Type check | `mypy src` |

## Ruff Configuration

Minimal config in pyproject.toml:

```toml
[tool.ruff]
line-length = 88
target-version = "py310"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP"]
```

## MyPy Configuration

```toml
[tool.mypy]
python_version = "3.10"
disallow_untyped_defs = true
warn_return_any = true
```

## Type Hints Patterns

```python
# Basic
def process(items: list[str]) -> dict[str, int]: ...

# Optional
def fetch(url: str, timeout: int | None = None) -> bytes: ...

# Callable
def apply(func: Callable[[int], str], value: int) -> str: ...

# Generic
T = TypeVar("T")
def first(items: Sequence[T]) -> T | None: ...
```

## Common Anti-Patterns

```python
# Bad: Mutable default
def process(items: list = []):
    ...

# Good: None default
def process(items: list | None = None):
    items = items or []
```

```python
# Bad: Bare except
try:
    ...
except:
    pass

# Good: Specific exception
try:
    ...
except ValueError as e:
    logger.error(e)
```

## Pythonic Idioms

```python
# Iteration
for item in items:           # Not: for i in range(len(items))
for i, item in enumerate(items):  # When index needed

# Dictionary access
value = d.get(key, default)  # Not: if key in d: value = d[key]

# Context managers
with open(path) as f:        # Not: f = open(path); try: finally: f.close()

# Comprehensions (simple only)
squares = [x**2 for x in numbers]
```

## Module Organization

```
src/my_library/
├── __init__.py      # Public API exports
├── _internal.py     # Private (underscore prefix)
├── exceptions.py    # Custom exceptions
├── types.py         # Type definitions
└── py.typed         # Type hint marker
```

## Checklist

```
Code Quality:
- [ ] ruff check passes
- [ ] mypy passes (strict mode)
- [ ] Public API has type hints
- [ ] No mutable default arguments
- [ ] Specific exception handling
- [ ] py.typed marker present
```

## Cross-References

- `python-tighten-types` — systematic type annotation tightening
- `python-testing` — pytest test patterns
- `python-error-handling` — exception patterns, logging
- `python-lint` — comprehensive lint configuration
