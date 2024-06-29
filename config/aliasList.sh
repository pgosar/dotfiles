#!/usr/bin/env bash

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
	rm="rip" \
	cp="cp -iv" \
	mv="mv -iv"

# packages
alias \
	yt="youtube-dl --add-metadata -ic" \
	fd="~/.cargo/bin/fd" \
	mlp="mlp --no-browser" \
	icat="kitty +kitten icat" \
	hg="kitty +kitten hyperlinked_grep" \
	kd="kitty +kitten diff"

# other
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
