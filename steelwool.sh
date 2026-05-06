#!/bin/zsh

MAJOR_VERSION=1
MINOR_VERSION=0
PATCH_VERSION=0

# SteelWool is a tool meant to "clean chrome". Jokes aside, it
# exists to solve a problem where students on a shared user account
# remained logged into Chrome for extended periods of time.
#
# Knowing that all it could take was one bad actor to access a student's
# Google account directly, I felt compelled to come up with a solution,
# given that I for some reason had admin access.
#
# This is only apparently a problem with Chrome, as Firefox and Safari
# can be configured to clear user data on exit. Chrome just likes
# having user data, so my job is to deny it of that.
#
# - Dryophoenix (Neph Hillis)

# ANSI color codes
ANSI_RED='\033[0;31m'
ANSI_YELLOW='\033[0;33m'
ANSI_RESET='\033[0m'

# Please do not give this program root.

if [ "$(id -u)" -eq 0 ]; then
  printf "%s\n" "SteelWool should never be run as root, quitting..." >&2
  exit 1
fi

# --- BEGIN VARIABLE CHECKING AND DECLARATION ---

# - begin case processing and initial state -

# Here, 1 is truthy, 0 is falsy.
IS_VERBOSE=0
IS_LOGGING=0
IS_DRY=0

while [ "$#" -gt 0 ]; do
  case $1 in
  -v | --verbose)
    IS_VERBOSE=1
    shift
    ;;
  -n | --dry-run)
    IS_DRY=1
    shift
    ;;
  -V | --version)
    printf "SteelWool version %d.%d.%d\n" "$MAJOR_VERSION" "$MINOR_VERSION" "$PATCH_VERSION"
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *)
    printf "%s\n" "Unknown argument $1" >&2
    shift
    ;;
  esac
done

# - begin flagger function declarations -

logging() {
  [ "$IS_LOGGING" -eq 1 ]
}

verbose() {
  [ "$IS_VERBOSE" -eq 1 ]
}

dry() {
  [ "$IS_DRY" -eq 1 ]
}

# Generate the x directory. If the x directory doesn't exist, then generate it.

# x = log
if [ ! -d "$HOME/Library/Logs/SteelWool" ]; then
  mkdir "$HOME/Library/Logs/SteelWool"
fi

# x = data; config
if [ ! -d "$HOME/Library/Application Support/SteelWool" ]; then
  mkdir "$HOME/Library/Application Support/SteelWool"
fi

# Create the x file in the x directory.

# x = log
if [ -e "$HOME/Library/Logs/SteelWool" ]; then
  logfile="$HOME/Library/Logs/SteelWool/steelwool.log"
  IS_LOGGING=1;
else
  printf "%s\n" "The log file for steelwool cannot be created, turning logging off" >&2
  IS_LOGGING=0;
fi

# x = data; config
if [ -e "$HOME/Library/Application Support/SteelWool" ]; then
  datadir="$HOME/Library/Application Support/SteelWool"
  configfile="$HOME/Library/Application Support/SteelWool/config.toml"
fi

# Since verbose means to tee the log into stdout, a few functions to simplify
# logging outright could be made.
logstd() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  if verbose; then
    printf "%s\n" "$1"
  fi

  if logging; then
    printf "%s %s\n" "$timestamp" "$1" >> "$logfile"
  fi
}

logwarn() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  printf "${ANSI_YELLOW}[WARN] %s${ANSI_RESET}\n" "$1" >&2

  if logging; then
    printf "%s [WARN] %s\n" "$timestamp" "$1" >> "$logfile"
  fi
}

logerr() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  printf "${ANSI_RED}[ERROR] %s${ANSI_RESET}\n" "$1" >&2;

  if logging; then
    printf "%s [ERROR] %s\n" "$timestamp" "$1" >> "$logfile"
  fi
}

# SteelWool needs to determine and delete the Chrome log folders.

# Specific note to any auditor:
# 
# Since these are "magic files", a further explanation is required.
#
# They are discovered on a MacOS Sequoia VM via UTM.
#
# The process was: 
# 1) download Chrome, initialize Chrome, quit.
# 2) find ~/Library/Application\ Support/<chrome_directory_root>, 
#    probably "Google" > ~/chromebefore.txt
# 3) start Chrome, log in as my user, let it sync.
# 4) find <that same root directory again> > ~/chromeafter.txt
# 5) diff ~/chromebefore.txt ~/chromeafter.txt > ~/targets.txt
# 
# And targets.txt is used here to determine what files should be removed
# to return it to initial state. 
#
# Because it can do this, it can be self maintained to an extent as well.
# that's todo for now, though.

if [ ! -e "$datadir/targets.txt" ]; then
  logerr "targets.txt not found. SteelWool requires a targets file to run. See the README for installation instructions."
  exit 1
fi

while IFS= read -r target; do
    if [ -e "$target" ]; then
        if dry; then
          logstd "DRY_RUN: would remove $target."
        else
          rm -rf "$target" && logstd "$target removed successfully." || logwarn "$target could not be removed."
        fi
    else
        logstd "$target not present, skipping."
    fi
done < "$datadir/targets.txt"

logstd "SteelWool has completed its run."

