#!/bin/zsh

# SteelWool is a tool meant to "clean chrome". Jokes aside, it
# exists to solve a problem where students on a shared user account
# remained logged into Chrome for extended periods of time.
#
# Knowing that all it could take was one bad actor to access a student's
# Google account directly, I felt compelled to come up with a solution,
# given that I for some reason had admin access.
#
# That has become modern SteelWool, which now does the same for most
# browsers that are installed by default on lab computers, since
# most lab computers use Chrome, Safari, and Firefox.
#
# - Dryophoenix (Neph Hillis)

# --- BEGIN VARIABLE CHECKING AND DECLARATION ---

# - begin case processing and initial state -

# Here, 1 is truthy, 0 is falsy.
IS_VERBOSE=0
IS_LOGGING=0

while [ "$" -gt 0 ]; do
  case $1 in
  -v | --verbose)
    IS_VERBOSE=1
    shift
    ;;
  *)
    printf "%s\n" "Unknown argument $1" >&2
    shift
    ;;
  esac
done

# - begin flagger function declarations -

logging() {
  [ IS_LOGGING -eq 1 ]
}

verbose() {
  [ IS_VERBOSE -eq 1 ]
}

# Generate the config file. If the config folder doesn't exist,
# then generate it.
if [ -d ~/Library/Logs/net.dryophoenix.steelwool/steelwool.log ]; then
  mkdir ~/Library/Logs/net.dryophoenix.steelwool
fi

# Since the log folder does exist, use it. If not, something weird
# happened, so fail.
if [ -e ~/Library/Logs/net.dryophoenix.steelwool ]; then
  logdir="~/Library/Logs/net.dryophoenix.steelwool/steelwool.log"
  IS_LOGGING=1
else
  printf "%s\n" "The log file for steelwool cannot be created, turning logging off" >&2
  IS_LOGGING=0
fi

# SteelWool needs to determine the Chrome log folders.
