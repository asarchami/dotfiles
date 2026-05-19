---
name: python-packaging
description: Packages and distributes Python projects using modern pyproject.toml, build backends (setuptools, hatchling), PyPI publishing with trusted publishing, and wheel building. Use when packaging projects for distribution, publishing to PyPI, or troubleshooting packaging issues.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\U0001F4E6"
    homepage: https://github.com/wdm0006/python-skills
---

# Python Packaging

## pyproject.toml Essentials

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-package"
version = "1.0.0"
description = "Short description"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=7.0", "ruff>=0.1", "mypy>=1.0"]

[project.urls]
Homepage = "https://github.com/user/package"

[project.scripts]
mycli = "my_package.cli:main"

[tool.setuptools.packages.find]
where = ["src"]
```

## Building

```bash
pip install build
python -m build              # Creates dist/
twine check dist/*           # Validate
```

## Publishing to PyPI

```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-xxx...
twine upload --repository testpypi dist/*  # Test first
twine upload dist/*                         # Production
```

## GitHub Actions (Trusted Publishing)

```yaml
# .github/workflows/publish.yml
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
      - run: pip install build && python -m build
      - uses: pypa/gh-action-pypi-publish@release/v1
```

## Dependency Best Practices

```toml
# DO: Minimum versions
dependencies = ["requests>=2.28", "click>=8.0"]

# DON'T: Exact pins
dependencies = ["requests==2.28.1"]

# DO: Optional for features
[project.optional-dependencies]
cli = ["click>=8.0"]
```

## Checklist

```
Before Release:
- [ ] pyproject.toml valid
- [ ] README.md informative
- [ ] LICENSE file exists
- [ ] Version set correctly
- [ ] twine check passes

After Release:
- [ ] pip install works
- [ ] Import works
- [ ] GitHub release created
```

## Cross-References

- `python-project-setup` — project structure, tooling
- `python-release-management` — SemVer, changelogs, release process
- `python-security` — dependency vulnerability scanning
