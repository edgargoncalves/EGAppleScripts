#!/usr/bin/env zsh

# This script creates a new Emacs frame or reuses an existing. Assumes
# there is an Emacs server running on the background, otherwise
# emacsclient will launch it.

# To use this (I use https://github.com/d12frosted/homebrew-emacs-plus/):
# - Save this code under /Applications/Emacs.app/Contents/MacOS/clientscript
# - chmod +X /Applications/Emacs.app/Contents/MacOS/clientscript
# - ln /Applications/Emacs.app/Contents/MacOS/clientscript /usr/local/bin/e
# - Create

# Ensures this script is callable on a Run Shell Script automator workflow
export PATH=/usr/local/bin:$PATH

#Checks if there's a frame open
emacsclient -n -e "(if (> (length (frame-list)) 1) 't)" 2> /dev/null | grep t &> /dev/null

if [ "$?" -eq "1" ]; then
   #No server runnin? Start one.
    emacsclient -a '' -nqc "$@" &> /dev/null
    exit
else
    if [ -z "$@"]; then
        #Server running, but we didn't call this with a file to open - just present us a frame
	emacsclient -nq --eval "(progn (select-frame-set-input-focus (selected-frame)))" &> /dev/null
 	exit
    else
        #server running, and we want a file shown. Gimme gimme!
	emacsclient -nq "$@" &> /dev/null
	exit
    fi
    exit
fi
