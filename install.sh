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

# Capture the current git identity (from the not-yet-replaced ~/.gitconfig) so the
# seed prompt below can offer it as a default.
PRE_NAME="$(git config --global --get user.name 2>/dev/null || true)"
PRE_EMAIL="$(git config --global --get user.email 2>/dev/null || true)"

# src (relative to repo)            dest (relative to $HOME)
#
# Directories are linked whole where the config is a tree the app owns (nvim,
# hammerspoon); anything those apps write back into it is gitignored. Where an app
# drops logs or state next to its config — herdr — individual files are linked
# instead, so that noise stays out of the repo.
LINKS=(
  "zsh/zprofile                     .zprofile"
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
seed_gitconfig_local() {
  local example="$1" target="$2"

  if (( DRY_RUN )); then
    log "seed  .gitconfig.local (would prompt for git name/email)"
    return 0
  fi

  local name="$PRE_NAME" email="$PRE_EMAIL" name_in email_in
  [[ -z $name ]] && name="$(id -F 2>/dev/null || true)"

  # Only prompt on a real TTY; piped/CI runs fall back to the existing identity.
  if [[ -t 0 ]]; then
    printf '\nGit identity — written to %s (never committed):\n' "$target"
    read -r -p "  Full name [${name:-leave unset}]: " name_in || true
    [[ -n $name_in ]] && name="$name_in"
    read -r -p "  Email [${email:-<none>}]: " email_in || true
    [[ -n $email_in ]] && email="$email_in"
  fi

  cp "$example" "$target"
  [[ -n $name ]] && git config --file "$target" user.name "$name"
  [[ -n $email ]] && git config --file "$target" user.email "$email"

  if [[ -n $email ]]; then
    log "seed  .gitconfig.local (git identity set)"
  else
    log "seed  .gitconfig.local (template only — edit it to set your email)"
  fi
}

for pair in "zshrc.local.example:.zshrc.local" "gitconfig.local.example:.gitconfig.local"; do
  example="$DOTFILES/templates/${pair%%:*}"
  target="$HOME/${pair##*:}"
  if [[ -e "$target" ]]; then
    log "ok    ${pair##*:} (exists, left alone)"
  elif [[ -e "$example" ]]; then
    if [[ "${pair##*:}" == ".gitconfig.local" ]]; then
      seed_gitconfig_local "$example" "$target"
    else
      log "seed  ${pair##*:} from templates/${pair%%:*}"
      run cp "$example" "$target"
    fi
  fi
done

echo
echo "Done. Open a new shell (or run: exec zsh)."
echo
echo "Next:"
echo "  brew bundle --file=$DOTFILES/Brewfile"
echo "  nvim                # first launch installs plugins; give it a minute"
echo "  xcode-select --install   # if treesitter parsers fail to compile"
