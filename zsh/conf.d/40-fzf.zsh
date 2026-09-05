#!/usr/bin/env zsh
# fzf: key bindings, completion, and Catppuccin Mocha colors.

command -v fzf >/dev/null || return 0

# `fzf --zsh` emits the same key-bindings + completion that older setups vendored
# into ~/.fzf.zsh / ~/.fzf_init.zsh. Generating it means it tracks the installed
# fzf version instead of drifting from it, so nothing needs checking in here.
# The fallback keeps a machine with a pre-0.48 fzf working.
if fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
elif [[ -r $HOME/.fzf.zsh ]]; then
  source $HOME/.fzf.zsh
fi

# One assignment, layout and colors together: two separate exports would silently
# clobber each other, which is how the colors got lost the first time.
export FZF_DEFAULT_OPTS=" \
--height 40% --layout=reverse --border --multi \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a"

# Ctrl-R: wrap long commands into a preview pane instead of truncating them.
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"
