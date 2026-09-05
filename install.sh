#!/usr/bin/env bash
# Symlink this repo's configs into $HOME. Idempotent: safe to re-run after a
# `git pull`, and re-running never touches a link it already owns.
#
#   ./install.sh            link everything
#   ./install.sh --dry-run  print what would change, touch nothing
#
# Anything already at a destination and NOT owned by this repo is moved aside to
# <dest>.bak-<timestamp> rather than deleted.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# src (relative to repo)            dest (relative to $HOME)
#
# Directories are linked whole where the config is a tree the app owns (nvim,
# hammerspoon); anything those apps write back into it is gitignored. Where an app
# drops logs or state next to its config — herdr — individual files are linked
# instead, so that noise stays out of the repo.
LINKS=(
  "zsh/zshrc                        .zshrc"
  "git/gitconfig                    .gitconfig"
  "git/ignore                       .config/git/ignore"
  "hammerspoon                      .hammerspoon"
  "config/nvim                      .config/nvim"
  "config/starship.toml             .config/starship.toml"
  "config/ghostty/config            .config/ghostty/config"
  "config/herdr/config.toml         .config/herdr/config.toml"
  "config/lazygit/config.yml        .config/lazygit/config.yml"
)

log()  { printf '  %s\n' "$*"; }
run()  { if (( DRY_RUN )); then log "would: $*"; else "$@"; fi; }

link_one() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    log "SKIP  $2 (missing in repo: $1)"
    return
  fi

  # Already ours? Nothing to do.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log "ok    $2"
    return
  fi

  run mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    log "backup $2 -> $2.bak-$STAMP"
    run mv "$dest" "$dest.bak-$STAMP"
  fi

  log "link  $2 -> $1"
  run ln -s "$src" "$dest"
}

echo "dotfiles: $DOTFILES"
(( DRY_RUN )) && echo "(dry run — no changes)"
echo

for entry in "${LINKS[@]}"; do
  # shellcheck disable=SC2086
  set -- $entry
  link_one "$1" "$2"
done

echo
# Seed the machine-local escape hatches so a fresh machine has somewhere obvious
# to put employer- or host-specific config. Never overwritten if present.
for pair in "zshrc.local.example:.zshrc.local" "gitconfig.local.example:.gitconfig.local"; do
  example="$DOTFILES/templates/${pair%%:*}"
  target="$HOME/${pair##*:}"
  if [[ -e "$target" ]]; then
    log "ok    ${pair##*:} (exists, left alone)"
  elif [[ -e "$example" ]]; then
    log "seed  ${pair##*:} from templates/${pair%%:*}"
    run cp "$example" "$target"
  fi
done

echo
echo "Done. Open a new shell (or run: exec zsh)."
echo
echo "Next:"
echo "  brew bundle --file=$DOTFILES/Brewfile"
echo "  nvim                # first launch installs plugins; give it a minute"
echo "  xcode-select --install   # if treesitter parsers fail to compile"
