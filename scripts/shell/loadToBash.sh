#!/usr/bin/env bash

# disable command not found message when loading in plugins
command_not_found_handle() {
    echo "easter egg!." > /dev/null
    return 127;
}

# load in plugins
loadpath=$DOTFILES/other/
in=${1:-$HOME/output.txt}
# expand variables to full filepath into new txt
envsubst < $loadpath/plugins.txt > $in
[ ! -f "$in" ] && { echo "$0 - File $in not found.";}
while read file ;
do
  # run the file on each line of txt and load it in
source "$file"
  if [ -f "$file" ]; then
    source "$file" &> /dev/null
  else
    echo "${file##*/} not loaded"
  fi
done < "${in}"
# delete created txt file
rm -f $in > /dev/null

# load in aliases
if [ -f $loadpath/aliasList.sh ]; then
    source $loadpath/aliasList.sh
fi
# load in extra commands
if [ -f $loadpath/commandsrc ]; then
    source $loadpath/commands.sh
fi

# reset command not found to its original (taken from ubuntu source code)
command_not_found_handle ()
{
    if [ -x /usr/lib/command-not-found ]; then
        /usr/lib/command-not-found -- "$1";
        return $?;
    else
        if [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1";
            return $?;
        else
            printf "%s: command not found\n" "$1" 1>&2;
            return 127;
        fi;
    fi
}
