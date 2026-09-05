#!/usr/bin/env zsh
# Environment.

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="nvim"

# Homebrew prefix, used by 99-plugins-last.zsh. Homebrew's own shellenv exports
# this; the fallback covers Apple Silicon before that has run.
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# `bat` as a pager elsewhere (git-delta, --help wrappers) reads better plain.
export BAT_STYLE="plain"

# Claude Code model aliases: point /model's Opus and Sonnet entries at the
# 1M-context variants.
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-5[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-5[1m]"

# Optional PATH entries — each guarded so a machine that lacks the tool doesn't
# end up with a dead PATH component.
[[ -d $HOME/.local/bin ]] && path=($HOME/.local/bin $path)
[[ -d $HOME/conductor/.venv/bin ]] && path=($HOME/conductor/.venv/bin $path)
export PATH
