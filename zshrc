ZSH_THEME="robbyrussell"

DISABLE_UNTRACKED_FILES_DIRTY="true"

alias create='bundle exec rake db:create'
alias migrate='bundle exec rake db:migrate; RAILS_ENV=test rake db:migrate'
alias rollback='bundle exec rake db:rollback; RAILS_ENV=test rake db:rollback'
alias bi='bundle install'
alias rake='noglob bundle exec rake'
alias trake='RAILS_ENV=test bundle exec rake'
alias rails='bundle exec rails'
alias trails='RAILS_ENV=test bundle exec rails'

rtestfunc() {
  if [ $# -eq 1 ]
  then
    echo -e "\n\e[92mRunning test file\e[39m"
    bundle exec ruby -I test $1
  else
    echo -e "\n\e[92Running individual test\e[39m"
    bundle exec ruby -I test $1 -n $2
  fi
}
alias rtest=rtestfunc

export TERM=xterm-256color

cleanLocalMergedBranches() {
  echo "Before cleanup:"
  git branch;
  echo "Cleaning up:";
  git branch --merged master | grep -v -e 'master' -e '\*' | xargs -n 1 git branch -d && git remote prune origin
  echo "After cleanup:"
  git branch;
}
alias cleanlocal=cleanLocalMergedBranches
