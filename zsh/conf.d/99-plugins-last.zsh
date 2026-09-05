#!/usr/bin/env zsh
# zle plugins with a hard load-order requirement. zshrc sources this file LAST,
# after ~/.zshrc.local, so nothing machine-local can slip in behind it.
#
#   1. autosuggestions          — order-insensitive, but must precede (2) to be
#                                 wrapped correctly by it.
#   2. syntax-highlighting      — must come after every other zle widget is
#                                 defined, or those widgets lose highlighting.
#   3. history-substring-search — upstream requires it after (2).

_plug() { [[ -r $1 ]] && source $1 }

_plug "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
_plug "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
_plug "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

unfunction _plug

# Up/Down search history for lines matching what's already typed.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
