---
name: python-testing
description: Designs and implements pytest test suites for Python projects with fixtures, parametrization, mocking, coverage, and CI configuration. Use when creating tests, improving coverage, setting up testing infrastructure, or implementing property-based testing.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\U0001F9EA"
    homepage: https://github.com/wdm0006/python-skills
---

# Python Testing

## Quick Start

```bash
pytest                              # Run tests
pytest --cov=my_library             # With coverage
pytest -x                           # Stop on first failure
pytest -k "test_encode"             # Run matching tests
```

## Pytest Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra -q --cov=my_library --cov-fail-under=85"

[tool.coverage.run]
branch = true
source = ["src/my_library"]
```

## Test Structure

```
tests/
├── conftest.py           # Shared fixtures
├── test_encoding.py
└── test_decoding.py
```

## Essential Patterns

**Basic test:**
```python
def test_encode_valid_input():
    result = encode(37.7749, -122.4194)
    assert isinstance(result, str)
    assert len(result) == 12
```

**Parametrization:**
```python
@pytest.mark.parametrize("lat,lon,expected", [
    (37.7749, -122.4194, "9q8yy"),
    (40.7128, -74.0060, "dr5ru"),
])
def test_known_values(lat, lon, expected):
    assert encode(lat, lon, precision=5) == expected
```

**Fixtures:**
```python
@pytest.fixture
def sample_data():
    return [(37.7749, -122.4194), (40.7128, -74.0060)]

def test_batch(sample_data):
    results = batch_encode(sample_data)
    assert len(results) == 2
```

**Mocking:**
```python
def test_api_call(mocker):
    mocker.patch("my_lib.client.fetch", return_value={"data": []})
    result = my_lib.get_data()
    assert result == []
```

**Exception testing:**
```python
def test_invalid_raises():
    with pytest.raises(ValueError, match="latitude"):
        encode(91.0, 0.0)
```

## Test Principles

| Principle | Meaning |
|-----------|---------|
| Independent | No shared state between tests |
| Deterministic | Same result every run |
| Fast | Unit tests < 100ms each |
| Focused | Test behavior, not implementation |

## Checklist

```
Testing:
- [ ] Tests exist for public API
- [ ] Edge cases covered (empty, boundary, error)
- [ ] No external service dependencies (mock them)
- [ ] Coverage > 85%
- [ ] Tests run in CI
```

## Cross-References

- `python-hypothesis` — property-based testing with Hypothesis
- `python-mutation-testing` — test suite strength via mutation analysis
- `python-code-quality` — ruff, mypy, Pythonic idioms
