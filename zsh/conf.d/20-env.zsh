#!/usr/bin/env zsh
# Environment.

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LESSCHARSET="utf-8"   # stops less from rendering UTF-8 as binary
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Homebrew prefix, used by 99-plugins-last.zsh. Homebrew's own shellenv exports
# this; the fallback covers Apple Silicon before that has run.
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# `bat` as a pager elsewhere (git-delta, --help wrappers) reads better plain.
export BAT_STYLE="plain"

# Keep $path (and so $PATH) deduplicated automatically, first occurrence winning.
# This is what makes every `path=(new $path)` below and in 25-toolchains.zsh
# idempotent — re-sourcing a file, or a tool like `nodenv init` that prepends its
# shims every time it runs, can no longer grow PATH without bound.
typeset -U path PATH

# Optional PATH entries — each guarded so a machine that lacks the tool doesn't
# end up with a dead PATH component.
[[ -d $HOME/.local/bin ]] && path=($HOME/.local/bin $path)
export PATH
