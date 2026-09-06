#!/usr/bin/env zsh
# Language toolchains and their PATH entries.
#
# Scope rule: only toolchains actually present on a machine I use. Guarded lines
# for things nobody has installed cost nothing to run but everything to trust —
# after a while no one knows which are load-bearing. If you add a toolchain, add
# it here; if you stop using one, delete it rather than leaving the guard.
#
# Dropped deliberately, all of them carried over from an older dotfiles repo with
# no trace left on this machine: cargo (`~/.cargo/env`), bun (`~/.bun`), opencode
# (`~/.opencode/bin`), a uv-style `~/.local/bin/env` script, and fnm. Re-add if a
# laptop actually grows one.
#
# Homebrew itself is handled earlier, in ~/.zprofile. Deduplication comes from
# `typeset -U path` in 20-env.zsh, so plain prepends here are safe to repeat.

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d $PNPM_HOME ]] && path=($PNPM_HOME $path)

export PATH

# Node version manager. nodenv, not fnm — two shim directories on PATH is how you
# get a `node` that doesn't match the `.node-version` you're looking at.
command -v nodenv >/dev/null && eval "$(nodenv init - zsh)"
