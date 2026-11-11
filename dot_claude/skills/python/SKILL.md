---
name: python
description: Foundation for writing, reviewing, and refactoring Python code — modern Python idioms (3.10 through 3.14), typing, error handling, asyncio and concurrency, API and module design, testing with pytest, and the uv/ruff/type-checker verification gate. Use whenever touching .py files, pyproject.toml, or Python tests, or when the user asks how to do something idiomatically in Python.
---

# Python

Standard library first for code. Reach for a third-party package only when the
standard library genuinely has no answer, and say so before adding it. The
assumed toolchain is uv, ruff, pytest, and a type checker.

This skill covers only what an agent tends to get wrong by default: idioms that
changed after most training data was written, and the handful of rules that
separate working Python from correct Python. Everything else is ordinary Python
knowledge.

## Before writing code

1. Read `requires-python` in `pyproject.toml`. Do not use syntax or APIs newer
   than its lower bound. Raising it is a decision for the user.
2. Look at how the surrounding package already does things (errors, logging,
   tests, type checker) and match it, unless it contradicts a rule below. Flag
   that conflict rather than silently picking one.
3. Manage everything through uv: `uv add pkg`, `uv add --dev pkg`, `uv run
   ...`. Never `pip install` into a project, and never hand-edit dependency
   lists and forget the lockfile.

## Verification gate

Run all of these before calling work done. Check each exit status directly,
never through a pipe into `tail` or `head`.

```sh
uv run ruff format --check .
uv run ruff check .
uv run <type checker> .   # whichever the project configures: mypy, pyright, ty
uv run pytest
```

The type checker is not optional. It catches real bugs, such as a possibly-None
value used unguarded, that tests often miss. If the project has no type checker
configured, say so rather than skipping the step silently.

## Modern Python

Prefer these over the older forms. The version is the minimum
`requires-python`.

| Instead of | Write | Since |
|---|---|---|
| `Optional[X]`, `Union[X, Y]` | `X \| None`, `X \| Y` | 3.10 |
| `List[int]`, `Dict[str, int]` from `typing` | `list[int]`, `dict[str, int]` | 3.9 |
| long `if`/`elif` chains on shape or type | `match` with class and mapping patterns | 3.10 |
| `zip(a, b)` that must be equal length | `zip(a, b, strict=True)`; `map(..., strict=True)` in 3.14 | 3.10 |
| `TypeVar("T")` plus `Generic[T]` | `def first[T](xs: list[T]) -> T`, `class Box[T]:` | 3.12 |
| `X: TypeAlias = ...` | `type X = ...` | 3.12 |
| `"ForwardRef"` strings, `from __future__ import annotations` | plain names; annotations are evaluated lazily | 3.14 |
| returning `"Self"` via a bound TypeVar | `typing.Self` | 3.11 |
| a comment saying a method overrides | `@typing.override` | 3.12 |
| `TypeGuard` for narrowing helpers | `typing.TypeIs` | 3.13 |
| a hand-written deprecation warning | `@warnings.deprecated("use g")` | 3.13 |
| `asyncio.gather` for structured work | `async with asyncio.TaskGroup() as tg:` | 3.11 |
| `asyncio.wait_for` | `async with asyncio.timeout(s):` | 3.11 |
| third-party `toml` | `tomllib` (read-only) | 3.11 |
| `datetime.utcnow()` (deprecated) | `datetime.now(datetime.UTC)`; always timezone-aware | 3.11 |
| `pytz` | `zoneinfo.ZoneInfo("Europe/London")` | 3.9 |
| `class Color(str, Enum)` | `enum.StrEnum` | 3.11 |
| manual chunking loops | `itertools.batched(xs, n)` | 3.12 |
| `dataclasses.replace` / `_replace` | `copy.replace(obj, x=2)` | 3.13 |
| `except (A, B):` | `except A, B:` (parentheses still needed with `as`) | 3.14 |
| f-strings for SQL, HTML, or shell built from input | t-strings (`t"..."` → `string.templatelib.Template`) processed by a renderer | 3.14 |
| `uuid.uuid4()` for sortable IDs | `uuid.uuid7()` | 3.14 |
| `shutil.copy` on paths | `Path.copy`, `Path.move` | 3.14 |
| third-party zstd | `compression.zstd` | 3.14 |

Behavior that changed underneath old advice:

- Annotations are lazy in 3.14. Code that reads `__annotations__` directly
  should use `annotationlib.get_annotations` instead.
- Free-threaded CPython (`python3.14t`) is officially supported but not the
  default. Don't assume the GIL is gone, and don't assume it protects your data
  either: shared mutable state still needs a `threading.Lock`.
- `return`, `break`, and `continue` inside `finally` raise a `SyntaxWarning`
  (3.14). Don't write them.

## Typing

- Annotate every public function, method, and class attribute. Leave locals to
  inference.
- Accept the loosest type you need, return the most specific: take
  `Iterable[T]` or `Mapping[K, V]` from `collections.abc`, return `list[T]` or
  `dict[K, V]`.
- `typing.Protocol` for structural interfaces at the point of use. Reach for
  `abc.ABC` only when you need shared implementation.
- Model structured data with `@dataclass(frozen=True, slots=True,
  kw_only=True)` or `TypedDict`, not bare `dict[str, Any]`.
- `Any` is a last resort. Prefer `object` when you just pass a value through.
- `typing.cast` and `# type: ignore[code]` need a reason in the commit or PR.
  Always give the error code.

## Errors

- Catch the narrowest exception, around the smallest block that can raise it.
  Never bare `except:`. `except Exception` only at a top-level boundary
  (request handler, CLI entry point, worker loop), and log it there.
- Chain when translating: `raise ConfigError(f"bad {path}") from err`. Use
  `from None` only when the original is genuinely noise.
- Handle each exception exactly once: re-raise it or log it and continue, never
  both.
- Define a small exception hierarchy per package (`class AppError(Exception)`,
  subclasses for conditions callers branch on). Don't raise bare `Exception`.
- Use `err.add_note(...)` (3.11) to add context without changing the type.
- `except* ValueError` for `ExceptionGroup`s from `TaskGroup`. `return`,
  `break`, and `continue` are not allowed inside an `except*` block.
- Use exceptions for errors, not `None` or sentinel return values. Don't use
  `assert` for validation; it disappears under `-O`.
- Clean up with `with` statements. Write context managers with
  `contextlib.contextmanager`, and use `contextlib.ExitStack` for a dynamic
  number of resources.

## Concurrency

- I/O-bound with many connections: `asyncio`. CPU-bound: `ProcessPoolExecutor`.
  Blocking library inside async code: `asyncio.to_thread`.
- Never call blocking I/O (`requests`, `time.sleep`, file reads of unknown
  size) inside a coroutine.
- Every task needs an owner. Create tasks inside a `TaskGroup`. A bare
  `asyncio.create_task` whose result isn't kept can be garbage-collected
  mid-flight and swallows its exception.
- Put timeouts on every network call: `asyncio.timeout`, or a client `timeout=`
  argument. The defaults are usually "forever".
- Bound concurrency with `asyncio.Semaphore` or a fixed worker count, never one
  task per item from unbounded input.
- `asyncio.Queue` for producer/consumer; call `q.shutdown()` (3.13) to stop
  consumers cleanly.

## Design

- Modules are named for what they provide (`orders`, `queue`), never `utils`,
  `helpers`, `common`, or `misc`.
- `src/` layout for packages. Keep the public API explicit with `__all__` in
  `__init__.py`; prefix internals with `_`.
- Functions over classes until there's state to hold. No class with one method
  and `__init__`.
- Keyword-only arguments (`*`) for anything beyond the first one or two
  positional parameters, and always for booleans.
- No I/O, network, or heavy work at import time. No global mutable state.
- Inject dependencies (clients, clocks, paths) as parameters with defaults,
  rather than reaching for module globals. This is what makes testing easy.
- Logging: `log = logging.getLogger(__name__)` per module, configured once at
  the entry point. Pass values as arguments (`log.info("loaded %s", path)`), not
  f-strings. No `print` in library code.
- Use `pathlib.Path` for paths, not `os.path` string juggling.

## Pitfalls

- Mutable default arguments (`def f(xs=[])`) are shared across calls. Use
  `None` and create inside, or `field(default_factory=list)` in dataclasses.
- Late-binding closures in loops capture the variable, not the value. Bind with
  a default argument or `functools.partial`.
- `subprocess.run([...], check=True)` with a list of arguments. Never
  `shell=True` with interpolated input.
- `pickle`, `yaml.load`, `eval`, and `exec` on untrusted input are code
  execution. Use `json`, `yaml.safe_load`, or `ast.literal_eval`.
- `random` is not for secrets. Use `secrets`.
- Floats for money are wrong. Use `decimal.Decimal`.
- `is` compares identity. Use it only for `None`, `True`, `False`, and
  sentinels.
- Naive datetimes compare silently wrong across zones. Keep everything aware
  and in UTC internally.
- Open text files with an explicit `encoding="utf-8"`.

## Testing

pytest, plus the standard library's `unittest.mock`.

- Plain `assert` statements. `@pytest.mark.parametrize` with `ids=` or
  `pytest.param(..., id=...)` for table-driven cases.
- `pytest.raises(SomeError, match="...")`. Always assert on the type, and on
  the message when it matters.
- Built-in fixtures: `tmp_path`, `monkeypatch`, `capsys`, `caplog`. Keep
  fixtures in `conftest.py` and scope them as narrowly as possible.
- Test behavior through the public API, not private helpers or call counts.
- Prefer fakes and injected dependencies over mocking. When you must mock,
  use `patch(..., autospec=True)` and patch where the name is looked up, not
  where it is defined.
- No real network, clock, or randomness in unit tests. Inject them.
- Don't `time.sleep` in tests to wait for something. Wait on the event,
  future, or queue directly.
