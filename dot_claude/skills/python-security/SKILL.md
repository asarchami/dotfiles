---
name: python-security
description: Audits Python projects for security vulnerabilities using Bandit, pip-audit, Semgrep, and detect-secrets. Identifies SQL injection, command injection, hardcoded credentials, weak cryptography, and insecure deserialization. Use when reviewing security or setting up security scanning in CI.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\U0001F6E1\uFE0F"
    homepage: https://github.com/wdm0006/python-skills
---

# Python Security Auditing

## Quick Start

```bash
# Static analysis
bandit -r src/ -ll                    # High severity only
pip-audit                             # Dependency vulnerabilities
detect-secrets scan > .secrets.baseline  # Secrets detection
```

## Tool Configuration

**Bandit (.bandit):**
```yaml
exclude_dirs: [tests/, docs/, .venv/]
skips: [B101]  # assert_used - OK in tests
```

## Common Vulnerabilities

| Issue | Bandit ID | Fix |
|-------|-----------|-----|
| SQL injection | B608 | Use parameterized queries |
| Command injection | B602 | subprocess without shell=True |
| Hardcoded secrets | B105, B106 | Environment variables |
| Weak crypto | B303 | Use SHA-256+, bcrypt for passwords |
| Pickle untrusted data | B301 | Use JSON instead |
| Path traversal | B108 | Validate with Path.resolve() |

## Secure Patterns

```python
# SQL - Parameterized query
conn.execute("SELECT * FROM users WHERE id = ?", (user_id,))

# Commands - No shell
subprocess.run(["cat", filename], check=True)

# Secrets - Environment
API_KEY = os.environ.get("API_KEY")

# Paths - Validate
base = Path("/data").resolve()
file_path = (base / filename).resolve()
if not file_path.is_relative_to(base):
    raise ValueError("Invalid path")
```

## CI Integration

```yaml
# .github/workflows/security.yml
- run: bandit -r src/ -ll
- run: pip-audit
- run: detect-secrets scan --all-files
```

## Audit Checklist

```
Code:
- [ ] No SQL injection (parameterized queries)
- [ ] No command injection (no shell=True)
- [ ] No hardcoded secrets
- [ ] No weak crypto (MD5/SHA1)
- [ ] Input validation on external data
- [ ] Path traversal prevention

Dependencies:
- [ ] pip-audit clean
- [ ] Minimal dependencies
- [ ] From trusted sources

CI:
- [ ] Security scan on every PR
- [ ] Weekly dependency scan
```

## Cross-References

- `python-code-quality` — ruff linting
- `python-packaging` — dependency management
