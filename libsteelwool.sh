# This is a header file. Do not execute.

MAJOR_VERSION=0
MINOR_VERSION=0
PATCH_VERSION=0

# Most of this was taken from steelwool.sh so that it could be
# sourced by steelwooldiff.sh; refer to steelwool.sh for
# in-script documentation.

# ANSI color codes
ANSI_RED='\033[0;31m'
ANSI_YELLOW='\033[0;33m'
ANSI_RESET='\033[0m'

# Here, 1 is truthy, 0 is falsy.
IS_VERBOSE=0
IS_LOGGING=0
IS_DRY=0

# - begin flagger function definitions -

logging() {
  [ "$IS_LOGGING" -eq 1 ]
}

verbose() {
  [ "$IS_VERBOSE" -eq 1 ]
}

dry() {
  [ "$IS_DRY" -eq 1 ]
}

# - begin function definitions -

# Generate the x directory. If the x directory doesn't exist, then generate it.

assure_directories() {
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
    logdir="$HOME/Library/Logs/SteelWool"
    IS_LOGGING=1
  else
    printf "%s\n" "The log file for steelwool cannot be created, turning logging off" >&2
    IS_LOGGING=0
  fi

  # x = data; config
  if [ -e "$HOME/Library/Application Support/SteelWool" ]; then
    datadir="$HOME/Library/Application Support/SteelWool"
    configfile="$HOME/Library/Application Support/SteelWool/config.toml"
  fi
}

# Since verbose means to tee the log into stdout, a few functions to simplify
# logging outright could be made.
logstd() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  if verbose; then
    printf "%s\n" "$1"
  fi

  if logging; then
    printf "%s %s\n" "$timestamp" "$1" >>"$logfile"
  fi
}

logwarn() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  printf "${ANSI_YELLOW}[WARN] %s${ANSI_RESET}\n" "$1" >&2

  if logging; then
    printf "%s [WARN] %s\n" "$timestamp" "$1" >>"$logfile"
  fi
}

logerr() {
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  printf "${ANSI_RED}[ERROR] %s${ANSI_RESET}\n" "$1" >&2

  if logging; then
    printf "%s [ERROR] %s\n" "$timestamp" "$1" >>"$logfile"
  fi
}
