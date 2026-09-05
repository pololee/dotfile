#!/usr/bin/env zsh
# Shell integrations for tools installed via Brewfile. Each is guarded so a
# fresh machine gets a working shell before `brew bundle` has finished.

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"

# try — scratch-directory manager (https://github.com/tobi/try).
# Prefers the installed binary; falls back to a local clone of the repo.
if command -v try >/dev/null; then
  eval "$(try init)"
elif [[ -f $HOME/mycode/try/try.rb ]]; then
  eval "$(ruby $HOME/mycode/try/try.rb init $HOME/src/tries)"
fi
