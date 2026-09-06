#!/usr/bin/env zsh
# The completion system.
#
# This file exists because nothing else was setting it up. On a work laptop the
# managed shellinit in ~/.zshrc.pre.local runs `compinit`; on a personal machine
# nothing did, so tab completion for git, gh, brew and friends was simply absent —
# the same class of silent gap as a missing ~/.zprofile.

# fpath must be final before compinit runs. Homebrew drops completions here, which
# is how `gh`, `brew` et al. get theirs.
[[ -n $HOMEBREW_PREFIX && -d $HOMEBREW_PREFIX/share/zsh/site-functions ]] &&
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
typeset -U fpath

# Skip entirely if something already initialised completion — compinit is ~230 ms
# here (a full compaudit + compdump), so running it twice is the most expensive
# no-op available.
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  _zsh_compdump="$ZSH_CACHE_DIR/zcompdump"

  # `compinit -C` skips the security audit of every fpath directory, which is most
  # of the cost. Do the full audited run at most once a day; use the fast path in
  # between. The glob qualifier means "exists and modified less than 24h ago".
  if [[ -n ${_zsh_compdump}(#qN.mh-24) ]]; then
    compinit -C -d "$_zsh_compdump"
  else
    compinit -d "$_zsh_compdump"
  fi
  unset _zsh_compdump
fi

# Needed for `menu select` below.
zmodload -i zsh/complist

# --- completion behaviour ---------------------------------------------------
# Arrow-key selectable menu instead of cycling blindly through matches.
zstyle ':completion:*' menu select

# Case-insensitive, then partial-word, then substring. Lets `cd dow<TAB>` find
# Downloads and `ls fo/ba` expand to foo/bar.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Cache slow completions (brew, apt, gh) on disk.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# Group matches under headers, so a big list is scannable.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches%f'

# Only colourise if something set LS_COLORS — eza doesn't, so this is usually
# skipped rather than applying an empty colour map.
[[ -n $LS_COLORS ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Don't offer the directory you're already in for cd ../<TAB>.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Complete processes with a useful command line, for kill/killall.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
