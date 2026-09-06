#!/usr/bin/env zsh
# Interactive shell behaviour. History options live in 10-history.zsh.

# --- directory navigation ---------------------------------------------------
# Every cd pushes onto the stack, so `cd -<TAB>` offers recent directories. This
# complements zoxide rather than duplicating it: zoxide is "jump anywhere by
# frecency", this is "go back to where I just was".
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT       # don't print the stack on every cd
DIRSTACKSIZE=20

# A bare directory name cds into it, so `..` works without an alias. Note this
# does NOT cover `...` or `....` — those aren't directories. If you miss them,
# they need real aliases; zoxide's `z ..`-style jumps are the other option.
setopt AUTO_CD

# --- globbing ---------------------------------------------------------------
# EXTENDED_GLOB is set in 00-lib.zsh — 05-completion.zsh needs it before this file
# is reached.
setopt NUMERIC_GLOB_SORT  # file10 sorts after file9, not between file1 and file2

# Pass an unmatched glob through literally instead of erroring, so `git show HEAD^`
# and `git log HEAD~2` work unquoted — with EXTENDED_GLOB on, `^` and `~` are glob
# operators. The trade: a mistyped glob reaches the command as a literal rather
# than being rejected, so `rm *.txtt` becomes an argument error, not a no-op.
unsetopt NOMATCH

# --- misc -------------------------------------------------------------------
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS   # allow trailing # comments when pasting commands
setopt LONG_LIST_JOBS
unsetopt FLOW_CONTROL         # frees ctrl-s / ctrl-q for keybindings
