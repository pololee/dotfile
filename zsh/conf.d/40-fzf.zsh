#!/usr/bin/env zsh
# fzf: key bindings, completion, Catppuccin Mocha colors, and previews.

command -v fzf >/dev/null || return 0

# `fzf --zsh` emits the same key-bindings + completion that older setups vendored
# into ~/.fzf.zsh / ~/.fzf_init.zsh. Generating it means it tracks the installed
# fzf version instead of drifting from it, so nothing needs checking in here.
# Cached via 00-lib.zsh. The fallback keeps a pre-0.48 fzf working.
if fzf --zsh >/dev/null 2>&1; then
  _cached_eval fzf fzf --zsh
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

# --- fd as the file source --------------------------------------------------
# Much faster than fzf's default `find`, and it respects .gitignore — so Ctrl-T in
# a repo stops offering node_modules and build output. --hidden keeps dotfiles
# findable, which matters a lot in a dotfiles repo; .git is excluded explicitly
# since --hidden would otherwise walk it.
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# --- previews ---------------------------------------------------------------
# Ctrl-T (files): syntax-highlighted head of the file. Falls back to a directory
# listing when the selection is a directory, and stays quiet on binaries.
if command -v bat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview '
    if [ -d {} ]; then eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {};
    else bat --style=numbers --color=always --line-range :300 {} 2>/dev/null;
    fi' --preview-window right:60%:wrap"
fi

# Alt-C (cd): show what's in the directory before jumping into it.
if command -v eza >/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always --color=always {}' --preview-window right:50%"
fi
