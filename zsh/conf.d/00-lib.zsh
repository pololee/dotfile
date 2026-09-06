#!/usr/bin/env zsh
# Small helpers the rest of conf.d builds on. Loaded first.

# Set here rather than with the other options in 15-options.zsh because the glob
# qualifiers `(#q...)` in 05-completion.zsh depend on it, and 05 loads first.
setopt EXTENDED_GLOB

export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR"

# _cached_eval <cache-name> <command> [args...]
#
# Replaces `eval "$(tool init zsh)"` with a cached version. The init output is
# written once and sourced thereafter, regenerating only when the tool's binary is
# newer than the cache — so `brew upgrade` picks itself up.
#
# This is the single biggest startup win available here. Measured cost of the init
# subprocesses this replaces:
#
#   try init          131 ms   (an rbenv shim, so it pays ruby startup every time)
#   nodenv init       44 ms
#   starship init      9 ms
#   fzf --zsh          4 ms
#   zoxide init        3 ms
#
# Caveat: mtime tracks the *binary*. A version manager shim (like try's) doesn't
# change mtime when the underlying gem updates, so after upgrading such a tool run
# `zsh-cache-clear`. That's the trade for ~175 ms off every shell.
_cached_eval() {
  local name=$1; shift
  local cache="$ZSH_CACHE_DIR/$name.zsh"
  local bin=${commands[$1]}

  if [[ ! -s $cache ]] || [[ -n $bin && $bin -nt $cache ]]; then
    # >| overrides noclobber if a managed shellinit set it.
    if ! "$@" >| "$cache" 2>/dev/null; then
      rm -f "$cache"
      return 1
    fi
  fi
  source "$cache"
}

# Drop every generated cache, including the completion dump. Use after upgrading a
# tool whose shim hides the real version, or when completions go stale.
zsh-cache-clear() {
  rm -f "$ZSH_CACHE_DIR"/*.zsh "$ZSH_CACHE_DIR"/zcompdump*
  rm -rf "$ZSH_CACHE_DIR"/zcompcache
  print "zsh cache cleared — run: exec zsh"
}
