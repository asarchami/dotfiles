---
name: python-cli
description: Builds command-line interfaces for Python projects using Click or Typer. Includes command groups, argument handling, progress bars, shell completion, and CLI testing with CliRunner. Use when adding CLI functionality or building standalone command-line tools.
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Python.
metadata:
  author: wdm0006
  version: "1.0.0"
  openclaw:
    emoji: "\U0001F4C8"
    homepage: https://github.com/wdm0006/python-skills
---

# Python CLI Development

## Framework Selection

**Click** (Recommended): Mature, extensive features
**Typer**: Modern, type-hint focused
**argparse**: Zero dependencies, standard library

## Click Quick Start

```python
import click

@click.group()
@click.version_option(version='1.0.0')
def cli():
    """My CLI tool."""
    pass

@cli.command()
@click.argument('input_file', type=click.Path(exists=True))
@click.option('--output', '-o', default='-', help='Output file')
@click.option('--verbose', '-v', is_flag=True)
def process(input_file, output, verbose):
    """Process an input file."""
    if verbose:
        click.echo(f"Processing {input_file}")
```

## Entry Point (pyproject.toml)

```toml
[project.scripts]
mycli = "my_package.cli:cli"

[project.optional-dependencies]
cli = ["click>=8.0"]
```

## Common Patterns

```python
# File I/O with stdin/stdout support
@click.argument('input', type=click.File('r'), default='-')
@click.argument('output', type=click.File('w'), default='-')

# Progress bar
with click.progressbar(items, label='Processing') as bar:
    for item in bar:
        process(item)

# Colored output
click.secho("Success!", fg='green', bold=True)
click.secho("Error!", fg='red', err=True)
```

## Testing with CliRunner

```python
from click.testing import CliRunner
from mypackage.cli import cli

def test_process():
    runner = CliRunner()
    result = runner.invoke(cli, ['process', 'input.txt'])
    assert result.exit_code == 0
    assert 'expected output' in result.output
```

## Shell Completion

```bash
_MYCLI_COMPLETE=bash_source mycli > ~/.mycli-complete.bash
_MYCLI_COMPLETE=zsh_source mycli > ~/.mycli-complete.zsh
```

## CLI Checklist

```
Setup:
- [ ] Entry point in pyproject.toml
- [ ] --help works for all commands
- [ ] --version displays version

UX:
- [ ] Errors go to stderr with non-zero exit
- [ ] Helpful error messages
- [ ] stdin/stdout support where appropriate

Testing:
- [ ] Tests for all commands
- [ ] Test error cases
- [ ] Test stdin processing
```

## Cross-References

- `python-packaging` — entry points in pyproject.toml
- `python-testing` — testing with CliRunner
- `python-api-design` — naming conventions
