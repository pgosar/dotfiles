#!/usr/bin/env bash

# random
alias \
  ls="eza -F --icons --color=auto --group-directories-first" \
  sl="eza -F --icons --color=auto --group-directories-first" \
  lsa="eza -F --icons --color=auto --group-directories-first -a" \
  grep="grep --color=auto" \
  cat="bat" \
  py="bpython" \
  cd="cd -P" \
  v="nvim" \
  ps="procs" \
  :q="exit"

# git stuff
alias \
  gcom="git commit -a" \
  log="git log --graph --date=relative --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ad)%Creset'" \
  gst="git status" \
  amend="git commit --amend --no-edit" \
  reword="git commit --amend" \
  untrack="git rm --cache" \
  uncommit="git reset --soft HEAD^" \
  groot='cd $(git rev-parse --show-toplevel 2>/dev/null)'

# verbosity and prompting
alias \
  mkdir="mkdir -pv" \
  cp="cp -iv" \
  mv="mv -iv" \
  rm="rip -i"

# other
alias icat="kitty +kitten icat"
