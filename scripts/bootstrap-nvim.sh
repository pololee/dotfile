#!/usr/bin/env bash
# Install Neovim plugins at the commits pinned in config/nvim/lazy-lock.json.
#
#   ./scripts/bootstrap-nvim.sh            normal run
#   ./scripts/bootstrap-nvim.sh --force    proceed even if the lockfile is dirty
#
# Why this exists instead of "just open nvim":
#
# The config sets `version = false`, so on a machine where a plugin isn't cloned
# yet lazy.nvim installs it at branch HEAD and then writes those commits back to
# lazy-lock.json. That file is a symlink into this repo, so a first `nvim` launch
# on a new machine silently rewrites your pins. Measured on a clean XDG sandbox:
# 19 of 33 pins moved.
#
# `Lazy! restore` does honour the lockfile, but only for plugins already on disk,
# and it re-persists the file as it goes. So one pass isn't enough on a fresh
# machine: the loop below alternates "put the lockfile back" with "restore" until
# every plugin's HEAD matches the committed pins.
#
# Idempotent, and a no-op once everything matches. The lockfile is restored from
# git on exit whatever happens, so a failed run can't leave the repo dirty and
# block the next one.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK="config/nvim/lazy-lock.json"
LOCK_ABS="$DOTFILES/$LOCK"
LOG="$(mktemp -t nvim-bootstrap)"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

command -v nvim >/dev/null || { echo "nvim not on PATH — run: brew bundle --file=$DOTFILES/Brewfile" >&2; exit 1; }
command -v jq   >/dev/null || { echo "jq not on PATH — run: brew bundle --file=$DOTFILES/Brewfile" >&2; exit 1; }

# The dirty check MUST come before any nvim invocation. Every `nvim` that loads
# this config triggers lazy.nvim's install-on-startup and rewrites the lockfile,
# so checking afterwards would report our own writes as your uncommitted work.
if ! git -C "$DOTFILES" diff --quiet -- "$LOCK" && (( ! FORCE )); then
  echo "$LOCK has uncommitted changes." >&2
  echo "Commit or stash them, or re-run with --force to discard them." >&2
  exit 1
fi

# nvim 0.11.2 is the floor the pinned LazyVim enforces
# (lua/lazyvim/plugins/init.lua bails below it).
#
# `-u NONE` is load-bearing: without it this probe loads init.lua, and lazy.nvim
# installs all 33 plugins at HEAD as a side effect of a version check.
if ! nvim --headless -u NONE '+lua os.exit(vim.fn.has("nvim-0.11.2") == 1 and 0 or 1)' 2>/dev/null; then
  echo "nvim $(nvim --version | head -1) is too old; the pinned LazyVim needs >= 0.11.2" >&2
  exit 1
fi

# Safe unconditionally from here: either the file matched HEAD, or --force said
# the working copy is expendable.
restore_lockfile() { git -C "$DOTFILES" checkout -- "$LOCK" 2>/dev/null || true; }
trap 'restore_lockfile; rm -f "$LOG"' EXIT

lazy() { nvim --headless "+Lazy! $1" +qa >>"$LOG" 2>&1 || true; }

# The real check: every installed plugin's HEAD equals its committed pin. Stronger
# than "is the lockfile clean", which only says lazy.nvim didn't rewrite it.
plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy"
count_drift() {
  local n=0 name installed pinned
  [[ -d $plugin_dir ]] || { echo 0; return; }
  for d in "$plugin_dir"/*/; do
    name="$(basename "$d")"
    installed="$(git -C "$d" rev-parse HEAD 2>/dev/null || echo none)"
    pinned="$(jq -r --arg k "$name" '.[$k].commit // "unpinned"' "$LOCK_ABS")"
    [[ "$pinned" != "unpinned" && "$installed" != "$pinned" ]] && n=$((n + 1))
  done
  echo "$n"
}

echo "installing plugins (quiet; log at $LOG)"
lazy install

for attempt in 1 2 3; do
  restore_lockfile
  lazy restore
  restore_lockfile
  drift="$(count_drift)"
  if [[ "$drift" == "0" ]]; then
    echo "pass $attempt: all plugins match the committed pins"
    break
  fi
  echo "pass $attempt: $drift plugin(s) still off-pin, retrying"
  if (( attempt == 3 )); then
    echo "giving up after 3 passes; $drift plugin(s) off-pin. Log: $LOG" >&2
    trap 'restore_lockfile' EXIT   # keep the log for debugging
    exit 1
  fi
done

cat <<'EOF'

Done. Two things this deliberately does not do:

  - Treesitter parsers compile on demand and need a C compiler. On a fresh Mac:
      xcode-select --install
  - Mason installs LSP servers and formatters under ~/.local/share/nvim/mason,
    which is not tracked here (upstream has no lockfile), so versions differ per
    machine. Open nvim and run :Mason to see what landed.
EOF
