# dotfiles

Terminal and productivity config, shared across laptops. Portable by
construction: nothing employer-, host-, or credential-specific is tracked here —
that all lives in three untracked `*.local` files described in
[docs/machine-local.md](docs/machine-local.md).

macOS / zsh / Homebrew. Catppuccin Mocha throughout.

## Install on a new machine

```sh
git clone <this-repo> ~/mycode/dotfiles
cd ~/mycode/dotfiles
brew bundle                    # tools the configs depend on
./install.sh --dry-run         # review
./install.sh                   # symlink into $HOME
./scripts/bootstrap-nvim.sh    # plugins at the pinned commits — run BEFORE opening nvim
exec zsh
```

Run `bootstrap-nvim.sh` before the first `nvim` launch. Launching nvim first
installs plugins at upstream HEAD and rewrites `lazy-lock.json` in this repo —
see [Neovim](#neovim) for why.

`install.sh` is idempotent and moves anything it doesn't own to
`<dest>.bak-<timestamp>` rather than deleting it. Re-run it after a `git pull`
that adds a new config.

Two manual steps macOS can't automate: grant Hammerspoon Accessibility
permission (System Settings → Privacy & Security → Accessibility), and set
Ghostty as the default terminal if you want it.

## Layout

```
zsh/
  zshrc                    → ~/.zshrc          load-order orchestration only
  conf.d/
    10-history.zsh                             overrides shellinit's tiny defaults
    20-env.zsh                                 locale, EDITOR, Homebrew prefix, PATH
    30-aliases.zsh                             eza/bat, shell basics, git shorthands
    40-fzf.zsh                                 keybinds via `fzf --zsh` + colors
    50-tools.zsh                               starship, zoxide, try
    99-plugins-last.zsh                        zle plugins with hard ordering
git/
  gitconfig                → ~/.gitconfig      delta, aliases, perf knobs
  ignore                   → ~/.config/git/ignore
hammerspoon/               → ~/.hammerspoon    hyper-key launcher + 5 modules
config/
  nvim/                    → ~/.config/nvim    LazyVim
  starship.toml            → ~/.config/starship.toml
  ghostty/config           → ~/.config/ghostty/config
  herdr/config.toml        → ~/.config/herdr/config.toml
  lazygit/config.yml       → ~/.config/lazygit/config.yml
templates/                 seeds for the untracked ~/*.local files
docs/machine-local.md      what's excluded, and why
Brewfile                   only what these configs actually need
install.sh                 idempotent symlinker with backups
```

`zsh/zshrc` deliberately contains no settings — only the load order. Add
settings to a numbered file in `conf.d/`, or a new one; the glob picks it up.

Directory-level symlinks are used where the app only reads (`hammerspoon`) or
where files it writes are worth tracking (`nvim`'s `lazy-lock.json`). File-level
symlinks are used where an app drops logs beside its config (`herdr`).

herdr is the terminal multiplexer; zellij was dropped once herdr replaced it.
`tmux` stays in the Brewfile because herdr's remote wrapper drives it, but there
is no tracked `tmux.conf`.

## Hammerspoon

Hyper key is `ctrl+cmd`. `modules/config_reloader.lua` watches the directory, so
edits apply on save with no reload step.

| Chord | Action |
| --- | --- |
| `hyper` + `o` / `s` / `;` / `'` / `i` | Chrome / Slack / Cursor / VS Code / Ghostty |
| `hyper` + `h` | Window hints (vimperator style) |
| `hyper` + `d` | Ring the mouse pointer for 3s |
| `cmd` + `s` in Chrome | Toggle the vertical tab sidebar via the Accessibility API |

`modules/scroll_direction.lua` inverts discrete mouse-wheel scrolling while
leaving trackpad gestures alone.

## Neovim

Stock [LazyVim](https://lazyvim.github.io) plus two overrides: Catppuccin Mocha
with a transparent background, and neo-tree showing dotfiles. No LazyVim extras
are enabled (`lazyvim.json` has an empty `extras` list), so the plugin set is
33 plugins, all of them LazyVim defaults or their dependencies. Nothing to
remember — `lazy-lock.json` is the inventory.

Requires nvim >= 0.11.2 (the floor the pinned LazyVim enforces) and a C compiler
for treesitter parsers — `xcode-select --install` on a fresh Mac.

### Why bootstrap-nvim.sh exists

`lazy-lock.json` is tracked, which is what makes two laptops agree. But the
config sets `version = false`, so on a machine where a plugin isn't cloned yet
lazy.nvim installs it at **branch HEAD** and then writes those commits back to
the lockfile. Since `~/.config/nvim` is a symlink into this repo, a first `nvim`
launch on a new machine silently rewrites your pins. Measured in a clean XDG
sandbox: 19 of 33 pins moved.

`Lazy! restore` does honour the lockfile — but only for plugins already on disk,
and it re-persists the file as it goes. So the working order is install → put the
lockfile back → restore, which is what `scripts/bootstrap-nvim.sh` does. It then
verifies by comparing every plugin's git HEAD to its pin, rather than trusting
that the lockfile looks clean.

It refuses to start on a dirty lockfile so it can't eat pin edits you meant to
keep (`--force` overrides), and it restores the lockfile from git on exit however
it ends, so a failed run can't leave the repo dirty and block the next one.

Verified from a clean XDG sandbox: 33 plugins installed at the committed pins,
lockfile untouched, `catppuccin` active, no plugin load errors, idempotent on a
second run. The only `:checkhealth lazy` complaints are the luarocks ones lazy
itself tells you to ignore.

### Updating plugins

Not required — the lockfile reproduces a known-good set, and the pins are the
reason a six-month-old config still starts cleanly. When you do want to update,
do it on one laptop and let the others follow:

```sh
nvim +Lazy                     # `U` to update, or :Lazy update
# use it for a day, then:
cd ~/mycode/dotfiles && git add config/nvim/lazy-lock.json && git commit
```

On the other laptop: `git pull && ./scripts/bootstrap-nvim.sh`.

Never commit a lockfile you haven't run. The one caveat worth knowing: `brew`
installs whatever nvim is current while the plugins stay pinned, so the gap
between the two only grows. Pins from more than a few months back paired with a
brand-new nvim is the one combination likely to break — if a fresh laptop
misbehaves, updating plugins is the first thing to try.

## Changes from the pre-repo config

Fixes:

- `~/.fzf_init.zsh` (22 KB vendored) → `source <(fzf --zsh)`, so it can't drift
  from the installed fzf. Falls back to `~/.fzf.zsh` on older versions.
- `reload` was `source ~/.zshrc`, which re-sourced the zle plugins and broke the
  history-substring-search keybinds. Now `exec zsh`.
- `git.user.email` is no longer tracked — it's in `~/.gitconfig.local`, so a
  personal laptop can't accidentally author commits with a work address.
- Added `init.defaultBranch = main`, `pull.ff = only`, `rebase.autoStash`,
  `diff.algorithm = histogram`; dropped `core.preloadindex` and
  `core.untrackedCache` duplicates.

Dropped rather than carried over — all of these were in the old `~/.zshrc` and
will disappear from the shell once `install.sh` runs:

| Dropped | Why |
| --- | --- |
| `zellij` config + Brewfile entry | herdr replaced it |
| `..` / `...` / `....` aliases | zoxide covers the same ground |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` / `..._SONNET_MODEL` | Claude Code's own settings are the right layer; env vars here fight `/model` |
| `~/conductor/.venv/bin` on `PATH` | internal tool — belongs in `~/.zshrc.local` |

## Not covered here

Raycast, Claude Code, and Codex settings are excluded for reasons in
[docs/machine-local.md](docs/machine-local.md) — the short version is that all
three rewrite their own config files, so symlinks lose.
