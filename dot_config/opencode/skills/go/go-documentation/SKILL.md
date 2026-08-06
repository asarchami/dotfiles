---
name: go-documentation
description: "Document Go projects for humans and AI — godoc comments, README, CONTRIBUTING, CHANGELOG, Example tests, API docs, llms.txt. Use when writing or filling in missing documentation, reviewing or auditing existing documentation for completeness and accuracy, adding code examples, setting up doc sites, or discussing documentation best practices."
license: MIT
---

# Go Documentation

**Leading word: document.** Documentation is a first-class deliverable written for the reader who has never seen the codebase — human or AI. The discipline is to **document** every exported symbol with a comment that says why and when, to make examples executable, and to work down the layered checklist in order: doc comments → README → CONTRIBUTING → CHANGELOG → type-specific and AI-friendly extras.

## Steps — write or fill in documentation

1. **Detect the project type.** Library (no `main`, meant to be imported) or application/CLI (`main` package, `cmd/` directory, produces a binary or image). Both apply for function comments, README, CONTRIBUTING, and CHANGELOG.

   *Done when: you can name the project type and the documentation layer it prioritizes.*

2. **Work through the checklist in priority order** — doc comments, package comment, README, LICENSE, getting started, working examples, CONTRIBUTING, CHANGELOG, then extras. Parallelize independent work with up to 5 sub-agents: one per package for doc comments, one per file (README, CONTRIBUTING, CHANGELOG, llms.txt) for project docs.

   *Done when: every applicable checklist item exists; Required items are never skipped.*

3. **Write doc comments for every exported symbol** — and complex internal functions; skip test functions. Start with the symbol name and a verb phrase; explain why and when, parameters, return values, and error cases, not what the code already shows. Include a usage example.

   *Done when: no exported symbol lacks a comment, and each comment says why/when plus errors rather than restating the code.*

4. **Build the README in the exact section order** — Title, Badges, Summary, Demo, Getting Started, Features/Specification, Contributing, Contributors, License. Copy the template from `./assets/templates/README.md`.

   *Done when: the README follows the section order and a stranger can run the getting-started path.*

5. **Add CONTRIBUTING and a changelog.** CONTRIBUTING lets a contributor get from clone to first PR in under 10 minutes (prerequisites, build, test, PR process); track changes with Keep a Changelog or GitHub Releases using `./assets/templates/CHANGELOG.md`. If setup takes longer, add a Makefile, docker-compose, or devcontainer to simplify it.

   *Done when: setup takes under 10 minutes and every release is documented.*

6. **Add type-specific layers.** Libraries: Go Playground demos linked with `// Play:` in doc comments, `ExampleXxx` test functions, godoc/pkg.go.dev preview, a website for large libraries, discoverability registration. Applications: installation methods (pre-built binaries, `go install`, Docker, Homebrew), comprehensive `--help`, and config docs for env vars, config files, and flags.

   *Done when: library examples are runnable via `go test`, and app help and install paths are documented.*

7. **Document the API if one exists.** REST → OpenAPI 3.x via swaggo/swag, event-driven → AsyncAPI, gRPC → Protobuf (buf, grpc-gateway). Prefer auto-generation from code annotations.

   *Done when: the API style has machine-readable docs that match the implementation.*

8. **Make it AI-friendly.** Add `llms.txt` at the repository root (`./assets/templates/llms.txt`); keep structured formats (OpenAPI, AsyncAPI, protobuf); keep doc comments consistently structured.

   *Done when: an AI agent can get a structured overview and locate APIs without reading source.*

9. **Document delivery.** Libraries: `go get github.com/{owner}/{repo}`. Applications: pre-built binary, `go install`, and Docker pull instructions.

   *Done when: the README tells users exactly how to obtain the project each way.*

## Steps — review or audit

1. **Check completeness against the checklist.** *Done when: no Required item is missing; Recommended gaps are flagged.*
2. **Audit each layer with up to 5 parallel sub-agents** — doc comments, README, CONTRIBUTING, CHANGELOG, library-specific extras. *Done when: every layer has a pass/fail verdict.*
3. **Check doc-comment style.** Comments start with the symbol name and a verb; explain why/when; parameters, returns, and errors are present. *Done when: no comment merely restates the code.*
4. **Verify examples are executable.** `go test` runs `ExampleXxx` functions. *Done when: every example compiles and passes.*
5. **Check README order and AI-readiness.** *Done when: the section order holds and `llms.txt` exists where required.*

## Reference

### Documentation checklist

| Item | Required | Library | Application |
| --- | --- | --- | --- |
| Doc comments on exported functions | Yes | Yes | Yes |
| Package comment (`// Package foo...`) | Yes | Yes | Yes |
| README.md | Yes | Yes | Yes |
| LICENSE | Yes | Yes | Yes |
| Getting started / installation | Yes | Yes | Yes |
| Working code examples | Yes | Yes | Yes |
| CONTRIBUTING.md | Recommended | Yes | Yes |
| CHANGELOG.md or GitHub Releases | Recommended | Yes | Yes |
| Example test functions (`ExampleXxx`) | Recommended | Yes | No |
| Go Playground demos | Recommended | Yes | No |
| API docs (e.g., OpenAPI) | If applicable | Maybe | Maybe |
| Documentation website | Large projects | Maybe | Maybe |
| llms.txt | Recommended | Yes | Yes |

### Doc comment format

```go
// CalculateDiscount computes the final price after applying tiered discounts.
// Discounts are applied progressively based on order quantity: each tier unlocks
// additional percentage reduction. Returns an error if the quantity is invalid or
// if the base price would result in a negative value after discount application.
//
// Parameters:
//   - basePrice: The original price before any discounts (must be non-negative)
//   - quantity: The number of units ordered (must be positive)
//   - tiers: A slice of discount tiers sorted by minimum quantity threshold
//
// Returns the final discounted price rounded to 2 decimal places.
// Returns ErrInvalidPrice if basePrice is negative.
// Returns ErrInvalidQuantity if quantity is zero or negative.
//
// Play: https://go.dev/play/p/abc123XYZ
//
// Example:
//
//	tiers := []DiscountTier{
//	    {MinQuantity: 10, PercentOff: 5},
//	    {MinQuantity: 50, PercentOff: 15},
//	}
//	finalPrice, err := CalculateDiscount(100.00, 75, tiers)
//	if err != nil {
//	    log.Fatalf("Discount calculation failed: %v", err)
//	}
func CalculateDiscount(basePrice float64, quantity int, tiers []DiscountTier) (float64, error) { ... }
```

For the full comment format, `Deprecated:` markers, interface docs, and file-level comments → **[Code Comments](./references/code-comments.md)**.

### README badges

```markdown
[![Go Version](https://img.shields.io/github/go-mod/go-version/{owner}/{repo})](https://go.dev/) [![License](https://img.shields.io/github/license/{owner}/{repo})](LICENSE) [![Build Status](https://img.shields.io/github/actions/workflow/status/{owner}/{repo}/test.yml?branch=main)](https://github.com/{owner}/{repo}/actions) [![Coverage](https://img.shields.io/codecov/c/github/{owner}/{repo})](https://codecov.io/gh/{owner}/{repo}) [![Go Report Card](https://goreportcard.com/badge/github.com/{owner}/{repo})](https://goreportcard.com/report/github.com/{owner}/{repo}) [![Go Reference](https://pkg.go.dev/badge/github.com/{owner}/{repo}.svg)](https://pkg.go.dev/github.com/{owner}/{repo})
```

### API documentation

| API Style | Format | Tool |
| --- | --- | --- |
| REST/HTTP | OpenAPI 3.x | swaggo/swag (auto-generate from annotations) |
| Event-driven | AsyncAPI | Manual or code-gen |
| gRPC | Protobuf | buf, grpc-gateway |

### Delivery commands

```bash
# Library
go get github.com/{owner}/{repo}

# Application: pre-built binary
curl -sSL https://github.com/{owner}/{repo}/releases/latest/download/{repo}-$(uname -s)-$(uname -m) -o /usr/local/bin/{repo}
# From source
go install github.com/{owner}/{repo}@latest
# Docker
docker pull {registry}/{owner}/{repo}:latest
```

### Deep references

- **[Library Documentation](./references/library.md)** — Playground demos, `ExampleXxx` tests, godoc, website sections, discoverability registration
- **[Application Documentation](./references/application.md)** — installation methods, CLI help, config docs, API documentation details
- **[Project Docs](./references/project-docs.md)** — README (`#readme`), CONTRIBUTING (`#contributingmd`), changelog (`#changelog`), delivery/Docker/Homebrew (`#delivery`)

### Templates

- `./assets/templates/README.md`
- `./assets/templates/CHANGELOG.md`
- `./assets/templates/llms.txt`

## Watch for

| Mistake | Fix |
| --- | --- |
| Doc comment restating the code | Explain why, when, constraints, and what can go wrong |
| Missing package comment | Always open the package with `// Package foo...` |
| Examples that aren't executable | Use `ExampleXxx` test functions verified by `go test` |
| README without getting started | Installation + minimal working example near the top |
| CONTRIBUTING that takes over 10 minutes to set up | Add a Makefile, docker-compose, or devcontainer |
| No structured docs for a public API | OpenAPI/AsyncAPI/Protobuf from code annotations |
| Documentation not consumable by AI | Add `llms.txt` and structured formats |

## Cross-references

- → See `go-style` for naming conventions in doc comments
- → See `go-testing` for Example test functions
- → See `go-project-layout` for where documentation files belong
- → See `go-swagger` for OpenAPI generation
