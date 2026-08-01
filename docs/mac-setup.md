# macOS setup

## Bootstrap

1. Install Apple's command-line tools: `xcode-select --install`.
2. Install Homebrew from [brew.sh](https://brew.sh/).
3. Clone this repository.
4. Run `scripts/install` from the repository root.
5. Open Hammerspoon and grant Accessibility permission when prompted.
6. Open Raycast and configure or sync Window Management shortcuts.

The installer uses GNU Stow to link each package into the home directory. Existing files are never overwritten by the script; move or back them up before retrying if Stow reports a conflict.

## Shell

Zsh is the primary local shell. `.zprofile` initializes Homebrew, while `.zshrc` configures Starship, fzf, eza, zoxide, fnm, and optional local toolchains. Machine-only additions belong in the untracked `~/.zshrc.local`.

For a remote host, copy `remote/bashrc` to `~/.bashrc`. It has graceful fallbacks and does not assume Homebrew or macOS paths.

## Editor and terminal

Ghostty uses VictorMono Nerd Font and Catppuccin Mocha. Neovim uses LazyVim with the same Catppuccin Mocha theme. LazyVim plugins are pinned by `lazy-lock.json`.
