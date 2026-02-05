# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make build          # Build binary (output: ./app)
make test           # Run tests (race detector + coverage)
make lint           # Run golangci-lint
make vet            # Run go vet
make fmt            # Format code
make run            # Build and run
make docs           # Generate documentation (markdown)
make clean          # Clean build artifacts

# Single package test
go test -v -race ./internal/config/...
go test -v -race ./cmd/...

# Single test
go test -v -race -run TestFunctionName ./internal/config/...

# Devbox
devbox shell
devbox run build
devbox run test
```

## Architecture

```
main.go → cmd.Execute()
cmd/
  root.go         # Root command, Viper/Logger init, persistent flags (--config, --debug, --log-format)
  version.go      # Version info (injected via ldflags: Version, Commit, BuildDate)
  completion.go   # Shell completion (bash/zsh/fish/powershell)
  docs.go         # Documentation generation (markdown/man/rest/yaml)
internal/
  apperrors/      # AppError type + sentinel errors (ErrNotFound, ErrInvalidInput, etc.)
  config/         # Config struct + Validator
  logger/         # log/slog wrapper (text/json format, component tracking)
```

**Config priority**: CLI flags > env vars (`APP_` prefix) > config file (YAML) > defaults

**Version injection**: `make build` injects `cmd.Version`, `cmd.Commit`, `cmd.BuildDate` via ldflags.

## Key Patterns

- **Error handling**: `apperrors.Wrap("operation.name", err)` for contextual wrapping. `apperrors.IsNotFound(err)` for type checking.
- **Logging**: `cmd.GetLogger().WithComponent("name")` for component-scoped logger.
- **Testing**: Table-driven tests + `t.Run()` subtests. Capture output with `cmd.SetOut(&buf)` + `bytes.Buffer`.
- **Adding commands**: Create file in `cmd/`, call `rootCmd.AddCommand(newCmd)` in `init()`. Write output to `cmd.OutOrStdout()`.

## Gotchas

- Don't shadow stdlib package names (`errors`, `log`, etc.)
- Convert `slog.Attr` to `[]any` when passing to `slog.Logger.With()`
- Use `fmt.Fprintf(cmd.OutOrStdout(), ...)` instead of `fmt.Printf` for testability
- Run `go mod tidy` to keep direct/indirect markers correct
