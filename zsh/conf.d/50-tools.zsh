#!/usr/bin/env zsh
# Shell integrations for tools installed via Brewfile.
#
# All routed through _cached_eval (00-lib.zsh) rather than `eval "$(tool init)"`,
# which forks a subprocess per tool on every shell start. `try` alone was 131 ms
# because it's an rbenv shim and pays ruby's startup each time.
#
# Each is guarded so a fresh machine gets a working shell before `brew bundle`
# has finished.

command -v starship >/dev/null && _cached_eval starship starship init zsh
command -v zoxide   >/dev/null && _cached_eval zoxide   zoxide init zsh

# try — scratch-directory manager (https://github.com/tobi/try).
# Prefers the installed binary; falls back to a local clone of the repo.
if command -v try >/dev/null; then
  _cached_eval try try init
elif [[ -f $HOME/mycode/try/try.rb ]]; then
  _cached_eval try ruby "$HOME/mycode/try/try.rb" init "$HOME/src/tries"
fi
