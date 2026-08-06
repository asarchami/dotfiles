---
name: go-cli
description: "Go CLI development — build command trees that compose with the shell: Cobra/Viper structure, flag binding, config layering, exit codes, stdout/stderr discipline, version embedding, signal handling, completions. Use when building a new CLI, extending a command tree, or reviewing an existing CLI for Unix conventions."
license: MIT
---

# Go CLI

**Leading word: shell.** A Go CLI earns its place by composing with the **shell** — pipeable stdout, quiet diagnostics on stderr, predictable exit codes, and completions that feel native. The discipline: shell-shaped defaults — Cobra + Viper unless trivial — with every stream and exit code deliberate.

## Steps — build

1. **Choose the stack.** Cobra + Viper by default for commands, flags, and config layering; stdlib `flag` for trivial single-purpose tools with no subcommands.

   *Done when: the stack is chosen with a reason, and trivial tools don't pull in Cobra.*

2. **Layout the tree.** One file per command under `cmd/myapp/`; `main.go` only calls `Execute()`.

   *Done when: every command lives in its own file under cmd/myapp/ and main.go does nothing but call Execute().*

3. **Configure the root command.** Set `SilenceUsage: true` and `SilenceErrors: true`; initialize Viper config in `PersistentPreRunE` so it loads before every subcommand; bind every configurable flag to Viper with `viper.BindPFlag` under a `SetEnvPrefix` namespace.

   *Done when: root silences usage/errors, config is initialized before every subcommand, and every configurable flag is bound to Viper.*

4. **Validate arguments and flags.** Use Cobra's built-in validators for positional args and `MarkFlagRequired` / `MarkFlagsMutuallyExclusive` / `MarkFlagsOneRequired` for flag constraints; register `RegisterFlagCompletionFunc` for flag values.

   *Done when: positional args are validated and required/exclusive flags are declared.*

5. **Write through the command streams.** Use `cmd.OutOrStdout()` / `cmd.ErrOrStderr()` so tests can capture output; logs and diagnostics go to stderr, program output to stdout.

   *Done when: no command writes directly to os.Stdout or os.Stderr.*

6. **Embed version at build time.** Inject via `ldflags` from git tags; expose a `version` subcommand.

   *Done when: version reports a build-time-injected value, not a hardcoded string.*

7. **Handle signals and output formats.** `signal.NotifyContext` for graceful shutdown; support an `--output` flag (table/json/plain) so scripts can parse results; colors via `fatih/color`, which auto-disables off-terminal.

   *Done when: SIGINT/SIGTERM trigger graceful shutdown and machine-readable output is available.*

8. **Ship completions.** Add the Cobra-generated completion command for bash/zsh/fish/powershell plus per-flag completions.

   *Done when: completions install for all four shells and custom flag values complete.*

## Steps — extend

1. **Read the existing tree first.** Add the subcommand in its own file, registered consistently with current naming, flags, and Viper bindings.

   *Done when: the new command matches existing conventions and is registered.*

2. **Bind and validate the new surface.** Every new flag gets `BindPFlag`, validators, and a completion function.

   *Done when: new flags work via flag, env (`MYAPP_`), and config file, and are validated.*

## Steps — review

1. **Check error flow.** Commands return errors from `RunE` — no `os.Exit()` inside, so Cobra's error handling and deferred cleanup run; `main()` decides the exit code; usage prints only with `--help`.

   *Done when: no os.Exit appears in commands and usage is not dumped on error.*

2. **Check stream discipline.** stdout carries only pipeable program output; logs, errors, and diagnostics go to stderr.

   *Done when: piping the CLI produces clean data.*

3. **Check the Unix conventions.** Exit codes follow the table below, version is injected via ldflags, and a missing config file is tolerated (`viper.ConfigFileNotFoundError` ignored).

   *Done when: exit codes, version, and config-optional behavior follow the reference tables.*

## Reference

### Stack

| Concern | Package / Tool |
| --- | --- |
| Commands & flags | `github.com/spf13/cobra` |
| Configuration | `github.com/spf13/viper` |
| Flag parsing | `github.com/spf13/pflag` (via Cobra) |
| Colored output | `github.com/fatih/color` |
| Table output | `github.com/olekukonko/tablewriter` |
| Interactive prompts | `github.com/charmbracelet/bubbletea` |
| Version injection | `go build -ldflags` |
| Distribution | `goreleaser` |

### Layout

```
myapp/
├── cmd/myapp/
│   ├── main.go              # package main, only calls Execute()
│   ├── root.go              # Root command + Viper init
│   ├── serve.go             # "serve" subcommand
│   ├── migrate.go           # "migrate" subcommand
│   └── version.go           # "version" subcommand
├── go.mod
└── go.sum
```

### Viper precedence

1. CLI flags
2. Environment variables (`MYAPP_PORT`)
3. Config file
4. Defaults set in code

### Exit codes

| Code | Meaning | When to Use |
| --- | --- | --- |
| 0 | Success | Operation completed normally |
| 1 | General error | Runtime failure |
| 2 | Usage error | Invalid flags or arguments |
| 64-78 | BSD sysexits | Specific error categories |
| 126 | Cannot execute | Permission denied |
| 127 | Command not found | Missing dependency |
| 128+N | Signal N | Terminated by signal (130 = SIGINT) |

### Argument validators

| Validator | Description |
| --- | --- |
| `cobra.NoArgs` | Fails if any args provided |
| `cobra.ExactArgs(n)` | Requires exactly n args |
| `cobra.MinimumNArgs(n)` | Requires at least n args |
| `cobra.MaximumNArgs(n)` | Allows at most n args |
| `cobra.RangeArgs(min, max)` | Requires between min and max |
| `cobra.ExactValidArgs(n)` | Exactly n args, must be in ValidArgs |

### Example config (.myapp.yaml)

```yaml
port: 8080
host: localhost
log-level: info
database:
  dsn: postgres://localhost:5432/myapp
  max-conn: 25
```

With root Viper init, these are equivalent: flag `--port 9090`, env `MYAPP_PORT=9090`, config file `port: 9090`.

### Worked examples (assets)

- [main.go](./assets/examples/main.go), [root.go](./assets/examples/root.go), [serve.go](./assets/examples/serve.go)
- [flags.go](./assets/examples/flags.go), [args.go](./assets/examples/args.go), [config.go](./assets/examples/config.go)
- [version.go](./assets/examples/version.go), [exit_codes.go](./assets/examples/exit_codes.go), [output.go](./assets/examples/output.go)
- [signal.go](./assets/examples/signal.go), [completion.go](./assets/examples/completion.go), [cli_test.go](./assets/examples/cli_test.go)

## Watch for

| Mistake | Fix |
| --- | --- |
| Writing to `os.Stdout` directly | Use `cmd.OutOrStdout()` so tests can capture output |
| `os.Exit()` inside `RunE` | Return an error; let `main()` decide |
| Not binding flags to Viper | `viper.BindPFlag` for every configurable flag |
| Missing `viper.SetEnvPrefix` | Namespace env vars (`MYAPP_PORT`) |
| Logging to stdout | Logs to stderr — stdout is the pipeable stream |
| Printing usage on every error | `SilenceUsage: true`; usage only with `--help` |
| Requiring a config file | Ignore `viper.ConfigFileNotFoundError` — config optional |
| Config init outside `PersistentPreRunE` | Initialize config before any subcommand runs |
| Hardcoded version string | Inject via `ldflags` from git tags |
| No `--output` format | Add JSON/table/plain for machine consumption |

## Cross-references

- → See `go-project-layout` for repository structure
- → See `go-dependency-injection` for wiring at the composition root
- → See `go-testing` for capturing command output in tests
- → See `go-patterns` for graceful shutdown patterns
