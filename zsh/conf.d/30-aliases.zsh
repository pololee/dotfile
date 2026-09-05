#!/usr/bin/env zsh
# Aliases. Employer- and machine-specific ones live in ~/.zshrc.local.

alias vim="nvim"

# Modern replacements
alias ls="eza --icons=auto --color=auto --group-directories-first --classify=auto"
alias ll="eza --icons=auto --color=auto --group-directories-first -al --classify=auto"
alias la="ll -a"
alias l="ls -la"
alias bat="bat --paging=never"

# Shell basics
alias c="clear"
alias h="history"
alias grep="grep --color=auto"
alias tree="tree -C"

# git — short forms layered on top of the aliases in git/gitconfig
alias gs="git status"
alias gd="git diff"
alias gdc="git diff --cached"
alias gl="git log --oneline -10"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gm="git merge"
alias gr="git rebase"
alias gri="git rebase -i"
alias ga="git add"
alias gaa="git add -A"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gsh="git stash"
alias gshp="git stash pop"

# Force github.com when the default GH_HOST is an enterprise instance.
alias gh-com="GH_HOST=github.com gh"

# Files and system
alias count="find . -type f | wc -l"
alias sizeof="du -sh"
alias myip="curl -s http://whatismyip.akamai.com/"
alias ports="lsof -iTCP -sTCP:LISTEN -n -P"

# This repo
alias zshrc="$EDITOR ${DOTFILES:-$HOME/mycode/dotfiles}/zsh"
alias reload="exec zsh"
alias dotfiles="cd ${DOTFILES:-$HOME/mycode/dotfiles}"
