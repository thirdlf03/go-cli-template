# app

A CLI application built with Go.

## Installation

### Using `go install`

```bash
go install github.com/thirdlf03/go-cli-template@latest
```

### Build from Source

```bash
git clone https://github.com/thirdlf03/go-cli-template.git
cd go-cli-template
make build
```

## Usage

```bash
app --help
app version
app --debug
app --log-format json
app completion bash
app docs --format markdown --output ./docs
```

## Configuration

Configuration priority (highest to lowest):

1. Command-line flags
2. Environment variables (prefix: `APP_`)
3. Configuration file (`./config.yaml`, `./config/config.yaml`, `$HOME/config.yaml`)
4. Default values

```bash
app --config /path/to/config.yaml
```

## Development

### Using Devbox (Recommended)

```bash
devbox shell
devbox run build
devbox run test
devbox run lint
```

### Make Commands

```bash
make build    # Build binary
make test     # Run tests
make lint     # Run linter
make fmt      # Format code
make vet      # Run go vet
make run      # Build and run
make docs     # Generate documentation
make clean    # Clean build artifacts
make help     # Show all commands
```

## Project Structure

```
├── cmd/                   # Command implementations
│   ├── root.go            # Root command, Viper/Logger init
│   ├── version.go         # Version command
│   ├── completion.go      # Shell completion
│   └── docs.go            # Documentation generation
├── internal/
│   ├── apperrors/         # Error handling
│   ├── config/            # Configuration management
│   └── logger/            # Structured logging
├── config/
│   └── config.yaml.example
├── .github/
│   ├── workflows/         # GitHub Actions (CI, Release)
│   └── dependabot.yaml
├── .goreleaser.yaml
├── Makefile
├── main.go
└── go.mod
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
