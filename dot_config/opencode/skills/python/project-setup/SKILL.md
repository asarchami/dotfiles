---
name: python-project-setup
description: Sets up professional Python library projects with modern tooling (pyproject.toml, uv, ruff, pytest, pre-commit, GitHub Actions). Use when creating new Python projects, modernizing existing projects to pyproject.toml, or configuring linting/testing/CI.
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

# Python Project Setup

## Quick Start

Create a new project with this structure:

```
my-project/
├── src/my_project/
│   ├── __init__.py
│   └── py.typed
├── tests/
├── pyproject.toml
├── Makefile
├── .pre-commit-config.yaml
└── .github/workflows/ci.yml
```

Use `src/` layout to prevent accidental imports of development code.

## Minimal pyproject.toml

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-project"
version = "0.1.0"
description = "What it does"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=7.0", "ruff>=0.1", "mypy>=1.0"]

[tool.setuptools.packages.find]
where = ["src"]
```

## Essential Commands

```bash
# Setup
pip install -e ".[dev]"
pre-commit install

# Daily workflow
ruff check src tests        # Lint
ruff format src tests       # Format
pytest                      # Test
mypy src                    # Type check
```

## Key Decisions

| Choice | Recommendation | Why |
|--------|---------------|-----|
| Layout | `src/` | Catches packaging bugs early |
| Build backend | setuptools | Mature, broad compatibility |
| Linter | ruff | Fast, replaces flake8+isort+black |
| Python range | `>=3.10` | Don't pin exact versions |
| Dependencies | Minimal | Move optional deps to extras |

## Checklist

```
Project Setup:
- [ ] src/ layout with py.typed marker
- [ ] pyproject.toml (not setup.py)
- [ ] Makefile with dev/test/lint/format
- [ ] .pre-commit-config.yaml
- [ ] .github/workflows/ci.yml
- [ ] README.md, LICENSE, CHANGELOG.md
- [ ] .gitignore
```

## Cross-References

- `python-packaging` — build backends, PyPI publishing
- `python-code-quality` — ruff, mypy configuration
- `python-testing` — pytest configuration
- `python-release-management` — versioning, changelogs
