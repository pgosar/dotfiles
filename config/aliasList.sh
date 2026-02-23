#!/usr/bin/env bash

OS="$(uname)"

# random
alias \
       ls="eza -F --color=auto --group-directories-first" \
       sl="eza -F --color=auto --group-directories-first" \
       lsa="eza -F --color=auto --group-directories-first -a" \
       grep="grep --color=auto" \
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
       mv="mv -iv"

if [ "$OS" = "Linux" ]; then
  alias rm="rip"
elif [ "$OS" = "Darwin" ]; then
  alias rm="rip -i"
fi

# packages
alias \
       mlp="mlp --no-browser" \
       icat="kitty +kitten icat" \
       hg="kitty +kitten hyperlinked_grep" \
       kd="kitty +kitten diff"

if [ "$OS" = "Linux" ]; then
  alias \
         hh="hstr" \
         yt="youtube-dl --add-metadata -ic" \
         fd="~/.cargo/bin/fd" \
         save="kitty @ ls > ~/.local/kitty.app/kitty-dump.json; cat ~/.local/kitty.app/kitty-dump.json |
python3 ~/.local/kitty.app/kitty-convert-dump.py > ~/.local/kitty.app/kitty-session.kitty" \
         wiki="wikiSummary.py" \
         lock="swaylock \
         --screenshots \
         --clock \
         --indicator \
         --indicator-radius 100 \
         --indicator-thickness 7 \
         --effect-blur 7x5 \
         --effect-vignette 0.5:0.5 \
         --ring-color bb00cc \
         --key-hl-color 880033 \
         --line-color 00000000 \
         --inside-color 00000088 \
         --separator-color 00000000 \
         --fade-in 0.2"
fi

# other
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
