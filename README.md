# atmosenv

[![Tests](https://github.com/jamengual/atmosenv/actions/workflows/test.yml/badge.svg)](https://github.com/jamengual/atmosenv/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**atmosenv** is an [Atmos](https://atmos.tools/) version manager inspired by [tfenv](https://github.com/tfutils/tfenv).

Just like tfenv manages Terraform versions, atmosenv manages Atmos versions - allowing you to easily switch between different versions on a per-project basis using `.atmos-version` files.

## Features

- Install and manage multiple Atmos versions
- Automatic version switching based on `.atmos-version` files
- Per-project version pinning
- Homebrew installation support
- Cross-platform (macOS, Linux)
- Shell completion for bash, zsh, and fish

## Installation

### Using Homebrew (recommended)

```bash
brew tap jamengual/atmosenv
brew install atmosenv
```

### Manual Installation

```bash
git clone https://github.com/jamengual/atmosenv.git ~/.atmosenv
```

Then add atmosenv to your PATH. Add the following to your shell configuration:

**Bash** (`~/.bashrc` or `~/.bash_profile`):
```bash
export PATH="$HOME/.atmosenv/bin:$PATH"
eval "$(atmosenv init -)"
```

**Zsh** (`~/.zshrc`):
```bash
export PATH="$HOME/.atmosenv/bin:$PATH"
eval "$(atmosenv init -)"
```

**Fish** (`~/.config/fish/config.fish`):
```fish
set -gx PATH $HOME/.atmosenv/bin $PATH
atmosenv init - | source
```

> **Important:** atmosenv must be at the **beginning** of your PATH to take precedence over any other `atmos` binary you may have installed (e.g., via Homebrew). This is the same pattern used by tfenv, rbenv, and other version managers.

## Quick Start

```bash
# Install the latest Atmos version
atmosenv install latest

# Switch to the installed version
atmosenv use latest

# Verify installation
atmos version

# List installed versions
atmosenv list

# List available versions
atmosenv list-remote
```

## Usage

### Installing Versions

```bash
# Install a specific version
atmosenv install 1.201.0

# Install the latest version
atmosenv install latest

# Install version from .atmos-version file
atmosenv install
```

### Switching Versions

```bash
# Switch to a specific version
atmosenv use 1.201.0

# Switch to version from .atmos-version file
atmosenv use
```

### Project-Specific Versions

Create a `.atmos-version` file in your project root:

```bash
echo "1.201.0" > .atmos-version
```

atmosenv will automatically use this version when running `atmos` commands in this directory.

### Listing Versions

```bash
# List installed versions
atmosenv list

# List available remote versions
atmosenv list-remote

# List more versions
atmosenv list-remote -n 50

# Include pre-release versions
atmosenv list-remote --prereleases
```

### Uninstalling Versions

```bash
# Uninstall a specific version
atmosenv uninstall 1.200.0

# Uninstall without confirmation
atmosenv uninstall -f 1.200.0
```

## Commands

| Command | Description |
|---------|-------------|
| `atmosenv install [VERSION]` | Install a specific Atmos version |
| `atmosenv use [VERSION]` | Switch to a specific version |
| `atmosenv uninstall VERSION` | Uninstall a specific version |
| `atmosenv list` | List installed versions |
| `atmosenv list-remote` | List available versions |
| `atmosenv version-name` | Print current version |
| `atmosenv version-file` | Print path to version file |
| `atmosenv init` | Configure shell environment |
| `atmosenv help` | Show help message |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ATMOSENV_CONFIG_DIR` | `~/.config/atmosenv` | Configuration directory |
| `ATMOSENV_ATMOS_VERSION` | - | Override version selection |
| `ATMOSENV_AUTO_INSTALL` | `true` | Auto-install missing versions |
| `ATMOSENV_LOG_LEVEL` | `INFO` | Log level (DEBUG, INFO, WARN, ERROR) |

## Version Resolution

atmosenv resolves the Atmos version to use in this order:

1. `ATMOSENV_ATMOS_VERSION` environment variable (highest priority)
2. `.atmos-version` file in current directory
3. `.atmos-version` file in parent directories (traverses up to root)
4. `~/.atmos-version` file
5. `~/.config/atmosenv/version` file
6. Latest installed version (fallback)

## Directory Structure

```
~/.config/atmosenv/
├── version           # Default version file
└── versions/         # Installed versions
    ├── 1.200.0/
    │   └── atmos     # Atmos binary
    └── 1.201.0/
        └── atmos
```

## How It Works

atmosenv manages Atmos versions by:

1. **Downloading binaries** from GitHub releases to `~/.config/atmosenv/versions/`
2. **Providing a shim** (`atmos`) that intercepts commands and routes them to the correct version
3. **Reading `.atmos-version` files** to determine which version to use per-project
4. **Verifying checksums** to ensure binary integrity

The shim pattern allows transparent version switching without modifying your PATH for each version.

## Comparison with Other Tools

| Feature | atmosenv | tenv | asdf |
|---------|----------|------|------|
| Atmos-specific | Yes | Yes | Via plugin |
| Shell-based | Yes | No (Go) | Yes |
| `.atmos-version` | Yes | Yes | `.tool-versions` |
| Homebrew | Yes | Yes | Yes |
| Auto-install | Yes | Yes | No |

## Development

### Running Tests

```bash
# Run basic tests
./test/run.sh

# Run all tests including installation tests
ATMOSENV_TEST_INSTALL=true ./test/run.sh

# Run specific test file
./test/run.sh test_basic.sh
```

### Project Structure

```
atmosenv/
├── bin/              # User-facing executables
│   ├── atmosenv      # Main entry point
│   └── atmos         # Wrapper shim
├── lib/              # Shared libraries
│   ├── bashlog.sh    # Logging framework
│   ├── helpers.sh    # Core utilities
│   └── atmosenv-version-file.sh
├── libexec/          # Subcommand implementations
│   ├── atmosenv-install
│   ├── atmosenv-use
│   ├── atmosenv-list
│   └── ...
├── test/             # Test suite
├── Formula/          # Homebrew formula
└── .github/workflows/
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`./test/run.sh`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [tfenv](https://github.com/tfutils/tfenv) - The inspiration for this project
- [Cloud Posse](https://cloudposse.com/) - Creators of Atmos
- [rbenv](https://github.com/rbenv/rbenv) - The original version manager pattern
- Pepe Amengual ([@jamengual](https://github.com/jamengual)) - Creator of atmosenv

## Related Projects

- [Atmos](https://atmos.tools/) - The tool this manages
- [tfenv](https://github.com/tfutils/tfenv) - Terraform version manager
- [tenv](https://github.com/tofuutils/tenv) - Universal version manager for OpenTofu, Terraform, Terragrunt, and Atmos
