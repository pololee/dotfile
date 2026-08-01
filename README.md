# Polo's macOS setup

This repository tracks the configuration used on my Mac and provides a repeatable bootstrap path for a new machine.

## Current setup

- **Shell:** Zsh with Starship, fzf, eza, zoxide, and fnm
- **Terminal:** Ghostty with VictorMono Nerd Font and Catppuccin Mocha
- **Editor:** Neovim with LazyVim and Catppuccin Mocha
- **Automation:** Hammerspoon
- **Launcher and window management:** Raycast
- **Remote shell:** a portable Bash drop-in for SSH hosts

Kitty, iTerm2, Rectangle, and the old Sublime Text configuration are retired and are not part of the current setup.

## Repository layout

```text
.
├── Brewfile            # Curated Homebrew packages, apps, and fonts
├── packages/           # GNU Stow packages laid out relative to $HOME
│   ├── ghostty/
│   ├── git/
│   ├── hammerspoon/
│   ├── nvim/
│   ├── shell/
│   └── starship/
├── remote/bashrc       # Standalone remote SSH Bash configuration
├── docs/               # Setup and app-specific notes
└── scripts/            # Installation and validation commands
```

## Install

After installing Homebrew and cloning the repository:

```sh
./scripts/install
```

The script installs the curated Brew bundle and links the packages with GNU Stow. It does not overwrite conflicting files. See [the macOS setup guide](docs/mac-setup.md) for the remaining permissions and application setup.

For an SSH host, copy only the portable Bash configuration:

```sh
scp remote/bashrc host:~/.bashrc
```

## Validate

```sh
./scripts/check
```

Raycast's local config directory currently contains authentication data, so it is deliberately not mirrored here. See [the Raycast notes](docs/raycast.md).
