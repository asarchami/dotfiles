---
name: python-performance
description: Optimizes Python performance through profiling (cProfile, PyInstrument), memory analysis (memray, tracemalloc), benchmarking (pytest-benchmark), and optimization strategies. Use when analyzing performance bottlenecks or finding memory leaks.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\U0001F680"
    homepage: https://github.com/wdm0006/python-skills
---

# Python Performance Optimization

## Profiling Quick Start

```bash
# PyInstrument (statistical, readable output)
python -m pyinstrument script.py

# cProfile (detailed, built-in)
python -m cProfile -s cumulative script.py

# Memory profiling
pip install memray
memray run script.py
memray flamegraph memray-*.bin
```

## PyInstrument Usage

```python
from pyinstrument import Profiler

profiler = Profiler()
profiler.start()
result = my_function()
profiler.stop()
print(profiler.output_text(unicode=True, color=True))
```

## Memory Analysis

```python
import tracemalloc

tracemalloc.start()
snapshot = tracemalloc.take_snapshot()
for stat in snapshot.statistics('lineno')[:10]:
    print(stat)
```

## Benchmarking (pytest-benchmark)

```python
def test_encode_benchmark(benchmark):
    result = benchmark(encode, 37.7749, -122.4194)
    assert len(result) == 12
```

```bash
pytest tests/ --benchmark-only
pytest tests/ --benchmark-compare
```

## Common Optimizations

```python
# Use set for membership (O(1) vs O(n))
valid = set(items)
if item in valid: ...

# Use deque for queue operations
from collections import deque
queue = deque()
queue.popleft()  # O(1) vs list.pop(0) O(n)

# Use generators for large data
def process(items):
    for item in items:
        yield transform(item)

# Cache expensive computations
from functools import lru_cache

@lru_cache(maxsize=1000)
def expensive(x):
    return compute(x)

# String building
result = "".join(str(x) for x in items)
```

## Optimization Checklist

```
Before Optimizing:
- [ ] Confirm there's a real problem
- [ ] Profile to find actual bottleneck
- [ ] Establish baseline measurements

Process:
- [ ] Algorithm improvements first
- [ ] Then data structures
- [ ] Then implementation details
- [ ] Measure after each change

After:
- [ ] Add benchmarks to prevent regression
- [ ] Verify correctness unchanged
- [ ] Document why optimization needed
```

## Cross-References

- `python-testing` — benchmark tests
- `python-code-quality` — data structure choices
