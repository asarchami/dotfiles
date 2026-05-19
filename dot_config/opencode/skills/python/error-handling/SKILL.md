---
name: python-error-handling
description: Idiomatic Python error handling — custom exceptions, exception chaining, logging with structlog/loguru, context managers for resource cleanup, and structured error patterns for production services. Use when designing error handling strategies, writing exception classes, or configuring logging for Python applications.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: opencode
  version: "1.0.0"
---

# Python Error Handling

## Custom Exceptions

Define a base exception for your package and derive specific exceptions from it:

```python
class MyPackageError(Exception):
    """Base exception for mypackage."""

class ValidationError(MyPackageError):
    """Raised when input validation fails."""

class ConfigurationError(MyPackageError):
    """Raised when configuration is invalid or missing."""

class APIError(MyPackageError):
    """Raised when an external API call fails."""
```

## Exception Chaining

Use `raise X from e` to preserve the original exception context:

```python
try:
    data = requests.get(url).json()
except requests.RequestException as e:
    raise APIError(f"Failed to fetch {url}") from e
```

Use `raise X from None` to suppress irrelevant context:

```python
try:
    value = int(user_input)
except ValueError:
    raise ValidationError(f"Invalid number: {user_input}") from None
```

## Structured Logging with structlog

```python
import structlog

logger = structlog.get_logger()

def process_order(order_id: str, amount: float) -> None:
    logger.info("processing_order", order_id=order_id, amount=amount)
    try:
        charge(order_id, amount)
    except PaymentError as e:
        logger.error("payment_failed", order_id=order_id, error=str(e))
        raise
```

## Context Managers for Resource Cleanup

```python
from contextlib import contextmanager

@contextmanager
def db_connection(conn_string: str):
    conn = create_connection(conn_string)
    try:
        yield conn
    finally:
        conn.close()
```

## Error Handling Patterns

### Retry with backoff

```python
import time
from functools import wraps

def retry(max_attempts: int = 3, delay: float = 1.0):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_error = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except TransientError as e:
                    last_error = e
                    if attempt < max_attempts - 1:
                        time.sleep(delay * (2 ** attempt))
            raise last_error
        return wrapper
    return decorator
```

### Result type pattern

```python
from dataclasses import dataclass
from typing import Generic, TypeVar, Union

T = TypeVar("T")
E = TypeVar("E")

@dataclass
class Ok(Generic[T]):
    value: T

@dataclass
class Err(Generic[E]):
    error: E

Result = Union[Ok[T], Err[E]]
```

## Logging Configuration

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
```

## Checklist

```
- [ ] Custom exception hierarchy with base class
- [ ] Exception chaining preserved (raise X from e)
- [ ] Resources managed via context managers
- [ ] Logging includes structured context
- [ ] Retry logic for transient failures
- [ ] Sensitive data not logged (passwords, tokens)
```

## Cross-References

- `python-try-except` — audit try/except blocks for correctness
- `python-code-quality` — anti-patterns in error handling
- `python-testing` — testing error paths with pytest.raises
