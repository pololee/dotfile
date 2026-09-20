#!/usr/bin/env bash
# Undo what install.sh did: remove the symlinks it created and restore the
# files/directories it moved aside to <dest>.bak-<timestamp>.
#
#   ./revert.sh            restore the pre-install state
#   ./revert.sh --dry-run  print what would change, touch nothing
#
# Safety model:
#   - Only removes a destination if it is a symlink pointing back into THIS repo.
#     Anything else at a destination (a real file, a symlink elsewhere) is left
#     exactly where it is.
#   - Restores the newest <dest>.bak-* backup. install.sh is idempotent, so in
#     practice there is exactly one backup per destination, from the first run.
#   - The two ~/.local seed files install.sh copies from templates/ are removed
#     ONLY if they are still byte-identical to the template. In practice
#     ~/.gitconfig.local never is: install.sh writes your git identity into it,
#     so it counts as your content and is kept.
#
# What this does NOT do: it does not uninstall any Homebrew formulae/casks that
# `brew bundle` installed (see `brew bundle cleanup` or `brew remove`), and it
# does not delete app state that tools wrote elsewhere after first launch
# (~/.local/share/nvim, ~/.cache/zsh, Hammerspoon/Neovim first-run files, etc.).

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && {
  sed -n '2,20p' "$0"
  exit 0
}

if [[ ! -r "$DOTFILES/install.sh" ]]; then
  echo "error: cannot find install.sh next to this script" >&2
  exit 1
fi

# Parse the SAME LINKS table install.sh uses, so the two can never drift apart.
LINKS=()
while IFS= read -r entry; do
  read -r src dest <<<"$entry"
  LINKS+=( "$src $dest" )
done < <(
  sed -n '/^LINKS=(/,/^)/p' "$DOTFILES/install.sh" \
    | sed -n 's/^[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' \
    | awk 'NF == 2 {print $1, $2}'
)

(( ${#LINKS[@]} )) || { echo "error: could not parse LINKS from install.sh" >&2; exit 1; }

log() { printf '  %s\n' "$*"; }
run() { if (( DRY_RUN )); then log "would: $*"; else "$@"; fi; }

restore_one() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  # 1. Drop the symlink, but only if install.sh created it (points at our repo).
  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      log "unlink $2"
      run unlink "$dest"
    else
      log "skip   $2 (symlink to elsewhere, not ours)"
      return
    fi
  elif [[ -e "$dest" ]]; then
    log "skip   $2 (present but not our symlink — leaving it alone)"
    return
  fi

  # 2. Put back the newest backup, if install.sh made one. The timestamp in
  #    .bak-YYYYMMDDHHMMSS sorts chronologically, so the greatest name wins.
  shopt -s nullglob
  local newest="" b
  for b in "$dest".bak-*; do
    [[ -z $newest || $b > $newest ]] && newest="$b"
  done
  shopt -u nullglob

  if [[ -n $newest ]]; then
    log "restore $2 <- $(basename "$newest")"
    run mv "$newest" "$dest"
  fi
}

echo "revert dotfiles: $DOTFILES"
(( DRY_RUN )) && echo "(dry run — no changes)"
echo

for entry in "${LINKS[@]}"; do
  # shellcheck disable=SC2086
  set -- $entry
  restore_one "$1" "$2"
done

echo
# Remove the ~/.local seed files, but only the untouched ones. A modified file is
# your content now and must survive.
for pair in "zshrc.local.example:.zshrc.local" "gitconfig.local.example:.gitconfig.local"; do
  example="$DOTFILES/templates/${pair%%:*}"
  target="$HOME/${pair##*:}"
  if [[ -f "$target" && ! -L "$target" ]]; then
    if cmp -s "$example" "$target"; then
      log "remove  ${pair##*:} (seeded by install.sh, unmodified)"
      run rm -f "$target"
    else
      log "keep    ${pair##*:} (has your content — leaving it alone)"
    fi
  fi
done

# Best-effort: remove parent dirs install.sh may have created with mkdir -p, but
# only if they are now empty.
run rmdir "$HOME/.config/git" 2>/dev/null || true
run rmdir "$HOME/.config/lazygit" 2>/dev/null || true

echo
echo "Done. Start a new shell (or run: exec zsh)."
echo
echo "Remember: this only undoes install.sh's symlinks/backups. Homebrew packages"
echo "installed by 'brew bundle' are still installed."
