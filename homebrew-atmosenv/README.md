# Homebrew Tap for atmosenv

This is the official Homebrew tap for [atmosenv](https://github.com/jamengual/atmosenv), an Atmos version manager inspired by tfenv.

## Installation

### Using Homebrew (recommended)

```bash
# Add the tap
brew tap jamengual/atmosenv

# Install atmosenv
brew install atmosenv
```

### Or install directly

```bash
brew install jamengual/atmosenv/atmosenv
```

## Usage

After installation, add atmosenv to your shell:

```bash
# For bash/zsh, add to your ~/.bashrc or ~/.zshrc:
eval "$(atmosenv init -)"

# For fish, add to ~/.config/fish/config.fish:
atmosenv init - | source
```

Then restart your shell or source the config file.

## Quick Start

```bash
# Install the latest Atmos version
atmosenv install latest

# Switch to the installed version
atmosenv use latest

# Verify installation
atmos version
```

## Updating

```bash
brew update
brew upgrade atmosenv
```

## Uninstalling

```bash
brew uninstall atmosenv
brew untap jamengual/atmosenv
```

## Troubleshooting

If you encounter issues, try:

```bash
# Check installation
brew doctor

# Reinstall
brew reinstall atmosenv
```

## License

Apache License 2.0 - see [LICENSE](https://github.com/jamengual/atmosenv/blob/main/LICENSE) for details.
