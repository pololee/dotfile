#!/usr/bin/env zsh
# History. Deliberately sourced after ~/.zshrc.pre.local so these win over any
# centrally-managed shellinit, which tends to ship a tiny 2000/1000 default.

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY       # record timestamp + duration
setopt SHARE_HISTORY          # share across concurrent shells/panes
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a re-run command
setopt HIST_IGNORE_SPACE      # skip commands prefixed with a space
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # expand !! onto the line instead of running blind
