#!/usr/bin/env zsh
# Language toolchains and their PATH entries.
#
# Scope rule: only toolchains actually present on a machine I use. Guarded lines
# for things nobody has installed cost nothing to run but everything to trust —
# after a while no one knows which are load-bearing. If you add a toolchain, add
# it here; if you stop using one, delete it rather than leaving the guard.
#
# Still dropped deliberately: cargo (`~/.cargo/env`) and opencode
# (`~/.opencode/bin`). The old `source ~/.local/bin/env` is gone too — 20-env.zsh
# already prepends `~/.local/bin` to path, so that file was redundant.
#
# Homebrew itself is handled earlier, in ~/.zprofile. Deduplication comes from
# `typeset -U path` in 20-env.zsh, so plain prepends here are safe to repeat.

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d $PNPM_HOME ]] && path=($PNPM_HOME $path)

# bun — installed via its own installer (~/.bun), not Homebrew.
export BUN_INSTALL="$HOME/.bun"
[[ -d $BUN_INSTALL/bin ]] && path=($BUN_INSTALL/bin $path)
[[ -s $BUN_INSTALL/_bun ]] && source $BUN_INSTALL/_bun

export PATH

# Node version manager. Deliberately NOT cached: `fnm env` embeds a per-shell
# FNM_MULTISHELL_PATH, so a cached copy would make every later shell share — and
# race over — one shell's directory. --use-on-cd auto-selects a directory's
# .node-version/.nvmrc. Costs a few ms; correctness is worth more.
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# Ruby version manager. `try` is a gem inside rv's Ruby, so this is also what
# puts `try` on PATH (see 50-tools.zsh). Unlike fnm, rbenv-style init output is
# shell-independent, so this one is safe to cache.
command -v rv >/dev/null && _cached_eval rv rv shell init zsh
