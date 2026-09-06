# macOS setup

The steps that can't live in `install.sh`, in the order they have to happen.

## Bootstrap a new Mac

1. **Command-line tools** — `xcode-select --install`. Needed before Homebrew, and
   again later for treesitter parsers, which compile from source.
2. **Homebrew** — from [brew.sh](https://brew.sh). Do this before cloning, because
   `install.sh` and `scripts/check` both expect `git`, `jq` and friends.
3. **Clone** to `~/mycode/dotfiles`. Another path works, but export `DOTFILES` so
   `zsh/zshrc` can find `conf.d/`.
4. `./scripts/check` — validates the repo before it touches your `$HOME`.
5. `brew bundle` — CLI tools, GUI apps, fonts.
6. `./install.sh --dry-run`, then `./install.sh`.
7. `exec zsh`. `~/.zprofile` puts Homebrew on PATH; without that step nothing else
   in `conf.d/` finds its tools.
8. `nvim` — first launch installs plugins. Give it a minute.

## Manual steps, unavoidable

**Hammerspoon** needs Accessibility permission: System Settings → Privacy &
Security → Accessibility. Without it the hyper-key bindings and the Chrome
vertical-tabs module silently do nothing — no error, they just don't fire.

**Ghostty** as default terminal, if you want it: Ghostty → Settings, or set it in
the app's own preferences.

**Raycast** window-management shortcuts are configured in Raycast Settings →
Extensions → Window Management. Documented here rather than tracked, because the
files in `~/.config/raycast` are authentication credentials and installed
extension bundles, not portable preferences — see
[machine-local.md](machine-local.md). Either sign in to sync your settings, or set
the shortcuts by hand. Never commit a Raycast token file or an unreviewed settings
export.

**Identity** — `~/.gitconfig.local` needs an `email`, and on a personal machine
usually a different `[github] user` than a work one. `install.sh` seeds the file
from `templates/gitconfig.local.example`; commits will use the wrong address until
you edit it.

## Remote hosts

`remote/bashrc` is for boxes that don't have this repo checked out:

```sh
scp remote/bashrc host:~/.bashrc
```

It assumes no Homebrew, no macOS paths, and no Nerd Font — every tool is probed
with a fallback, so the same file works on a bare Linux host. It is deliberately
*not* in `install.sh`'s link table.

## What lives where

| Concern | File |
| --- | --- |
| Homebrew on PATH | `zsh/zprofile` → `~/.zprofile` |
| Shell settings | `zsh/conf.d/*.zsh` |
| Work/employer-specific | `~/.zshrc.local`, `~/.gitconfig.local` (untracked) |
| Centrally-managed shellinit | `~/.zshrc.pre.local` (untracked, loads first) |
| Repo validation | `scripts/check` |
