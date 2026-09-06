# dotfiles

Terminal and productivity config, shared across laptops. Portable by
construction: nothing employer-, host-, or credential-specific is tracked here —
that all lives in three untracked `*.local` files described in
[docs/machine-local.md](docs/machine-local.md).

macOS / zsh / Homebrew. Catppuccin Mocha throughout.

## Install on a new machine

```sh
xcode-select --install    # and install Homebrew from https://brew.sh first
git clone <this-repo> ~/mycode/dotfiles
cd ~/mycode/dotfiles
./scripts/check          # validate the repo before it touches $HOME
brew bundle              # tools the configs depend on
./install.sh --dry-run   # review
./install.sh             # symlink into $HOME
exec zsh
nvim                     # first launch installs plugins; give it a minute
```

Full bootstrap order and the manual macOS steps — Hammerspoon Accessibility,
Raycast shortcuts, git identity — are in [docs/mac-setup.md](docs/mac-setup.md).

`install.sh` is idempotent and moves anything it doesn't own to
`<dest>.bak-<timestamp>` rather than deleting it. Re-run it after a `git pull`
that adds a new config.

## Layout

```
zsh/
  zprofile                 → ~/.zprofile       Homebrew on PATH; runs before zshrc
  zshrc                    → ~/.zshrc          load-order orchestration only
  conf.d/
    00-lib.zsh                                 _cached_eval, zsh-cache-clear
    05-completion.zsh                          compinit (cached) + completion UX
    10-history.zsh                             overrides shellinit's tiny defaults
    15-options.zsh                             pushd stack, globbing, AUTO_CD
    20-env.zsh                                 locale, EDITOR, typeset -U path
    25-toolchains.zsh                          pnpm, nodenv
    30-aliases.zsh                             eza/bat, shell basics, git shorthands
    40-fzf.zsh                                 fd-backed, bat/eza previews
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
remote/bashrc              copied by hand to remote hosts — NOT symlinked
scripts/check              validate the repo without installing it
templates/                 seeds for the untracked ~/*.local files
docs/mac-setup.md          bootstrap order + the manual macOS steps
docs/machine-local.md      what's excluded, and why
Brewfile                   only what these configs actually need
install.sh                 idempotent symlinker with backups
```

`~/.zprofile` is load-bearing on a fresh Mac: Homebrew's installer doesn't put
itself on PATH, and every integration in `conf.d/` is guarded with `command -v`,
so without it the shell comes up looking fine while silently doing none of it.

`20-env.zsh` sets `typeset -U path`, which is what makes every PATH prepend in the
repo idempotent — including tools like `nodenv init` that re-prepend their shims
each time they run.

`zsh/zshrc` deliberately contains no settings — only the load order. Add
settings to a numbered file in `conf.d/`, or a new one; the glob picks it up.

Directory-level symlinks are used where the config is a whole tree the app owns
(`nvim`, `hammerspoon`) — a per-file list would need editing every time a plugin
spec or module is added. File-level symlinks are used where an app writes logs or
state beside its config, so that noise stays out of the repo (`herdr`). What nvim
writes into its own config dir is gitignored; see [Neovim](#neovim).

herdr is the terminal multiplexer; zellij was dropped once herdr replaced it.
`tmux` stays in the Brewfile because herdr's remote wrapper drives it, but there
is no tracked `tmux.conf`.

## Startup cost

Measured with `zsh -l -i -c exit`, 15 runs, and profiled with `zmodload zsh/zprof`.

| | before | after |
| --- | --- | --- |
| clean machine (no managed shellinit) | 329 ms, **and no completion at all** | **143 ms**, 1732 completions |
| this work laptop | 663 ms | 577 ms |

The clean-machine "before" is measured against commit `727b4a4`, not estimated. It
had `compdef=0` and an empty `_comps` — tab completion for git, gh and brew simply
did not exist, because nothing in the repo ran `compinit` and only the work
laptop's managed shellinit was covering for it.

Two things got it there:

- **`_cached_eval`** in `00-lib.zsh` replaces `eval "$(tool init zsh)"` with a
  cached file, regenerated only when the tool's binary is newer. That's 191 ms of
  subprocess down to 72 ms of `source`. `try` alone was 131 ms — it's an rbenv
  shim, so every shell paid ruby's startup.
- **`compinit -C`** with a dated dump in `05-completion.zsh`: the full security
  audit runs at most once a day, 7.6 ms on the fast path instead of ~231 ms.

The work laptop stays slower because the managed shellinit in `~/.zshrc.pre.local`
runs its own unconditional `compinit` (231 ms) plus 812 `compdef` calls before any
of this repo loads. Not fixable from here — `05-completion.zsh` detects it and
skips its own, so at least it isn't paid twice.

After upgrading a tool whose version is hidden behind a shim, run
`zsh-cache-clear`. Everything else invalidates on binary mtime.

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
with a transparent background, and neo-tree showing dotfiles. `lua/config/`
holds the starter's empty `options` / `keymaps` / `autocmds` stubs, and no
LazyVim extras are enabled (`lazyvim.json` has an empty `extras` list). That
comes to 33 plugins, every one a LazyVim default or a dependency of one.

Requires nvim >= 0.11.2 (LazyVim's floor) and a C compiler for treesitter
parsers — `xcode-select --install` on a fresh Mac. First launch installs
everything; give it a minute.

### Plugins are not pinned, deliberately

`lazy-lock.json` is gitignored. Tracking it looks like the obvious way to make
two laptops agree, and it does — but it costs more than it's worth here:

- The config sets `version = false`, so on a machine where a plugin isn't cloned
  yet lazy.nvim installs it at **branch HEAD** and writes those commits back to
  the lockfile. `~/.config/nvim` is a symlink into this repo, so a first `nvim`
  launch on a new machine silently rewrites the pins — measured in a clean XDG
  sandbox, 19 of 33 moved.
- `Lazy! restore` honours the lockfile, but only for plugins already on disk, and
  re-persists the file as it goes. Getting a fresh machine onto the pins needs an
  install → put-the-lockfile-back → restore loop, i.e. a bootstrap script that
  has to run *before* you ever open nvim.
- With nothing in the config but a colorscheme and one neo-tree option, there is
  almost no surface for a plugin update to break. The pinning was protecting two
  files.

So: a new machine installs whatever is current. Both laptops track upstream
instead of tracking each other, and there's no bootstrap step to forget.

Verified rather than assumed — a clean XDG sandbox with no lockfile installed
LazyVim 16.0.0 (a major bump from the 15.14.0 that was pinned) on nvim 0.12.5:
33 plugins, zero load errors, `catppuccin` active, treesitter parsers compiling,
and `catppuccin.transparent_background` behaving identically to the pinned set.

If an update ever does break something, `:Lazy` shows every plugin's history and
`git log` in `~/.local/share/nvim/lazy/<plugin>` finds the last good commit; pin
that one plugin with `commit = "..."` in a `lua/plugins/` file until upstream
fixes it. That's a rare, targeted fix rather than a permanent maintenance tax.

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
