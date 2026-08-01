alias vim="nvim"

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"
export BAT_STYLE="plain"
export LESSCHARSET="utf-8"

if (( $+commands[eza] )); then
  alias ls="eza --icons=auto --color=auto --group-directories-first --classify=auto"
  alias ll="eza --icons=auto --color=auto --group-directories-first -al --classify=auto"
fi

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
if (( $+commands[rv] )); then
  eval "$(rv shell init zsh)"
fi
if (( $+commands[try] )); then
  eval "$("${commands[try]}" init "${TRY_PATH:-$HOME/src/tries}")"
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

if (( $+commands[brew] )); then
  _brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix)}"
  [[ -f "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  if [[ -f "$_brew_prefix/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$_brew_prefix/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
  fi
  [[ -f "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  unset _brew_prefix
fi

# Optional, untracked machine-specific additions.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
