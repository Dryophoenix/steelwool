#!/bin/zsh

MAJOR_VERSION=1
MINOR_VERSION=0
PATCH_VERSION=0

# SteelWoolDiff is a tool that's meant to generate a "targets.txt"
# file with a checksum so that may presumably be legitimate.

# parse arguments

while [ "$#" -gt 0 ]; do
  case $1 in
  -s | --sensitivity)
    DIFF_SENSITIVITY=$2
    shift 2
    ;;
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


# source libsteelwool, and handle errors and unexpecteds.
{
  source /usr/local/share/SteelWool/libsteelwool.sh \
    || { printf "%s\n" "libsteelwool wasn't in its expected location, defaulting to scripts folder..." >&2
         source "$(dirname "$0")/libsteelwool.sh"; }
} || {
  printf "%s\n" "libsteelwool.sh could not be found. Is it in the right place?" >&2
  exit 1
}

assure_directories || {
  printf "%s\n" "assure_directories failed. Check permissions on ~/Library." >&2
  exit 1
}

while [ true ]; do
  rm "$datadir/chromebefore.txt" >/dev/null
  find "*/google" >> "$datadir/chromebefore.txt"
  find "*/Google" >> "$datadir/chromebefore.txt"
  
  while [ true ]; do
    read -p "Log into Chrome, then press Enter. (C)ancel: " response
    case $response in
      C|c)
        rm "$datadir/chromebefore.txt" \
        && printf "%s\n" "Okay, cancelling diff and exiting."
        exit 1
        ;;
      "")
        break 
        ;;
      *)
        printf "%s\n" "Unknown response $response."
        continue
        ;;
    esac
  done

  rm "$datadir/chromeafter.txt" >/dev/null
  find "*/google" >> "$datadir/chromeafter.txt"
  find "*/Google" >> "$datadir/chromeafter.txt"

  if [ $(wc -l < "$datadir/chromeafter.txt") -gt $((10 + $(wc -l < "$datadir/chromebefore.txt"))) ]; then
    break
  else
    while [ true ]; do
      read -p "There are fewer new lines than would be expected, did you log in? (y/n/(c)ancel): " response
      case $response in 
      y | Y | yes | Yes)
        printf "%s\n" "Okay, running diff."
        break
        ;;
      n | N | no | No)
        printf "%s\n" "Okay, log in."
        continue
        ;;
      c | C | cancel | Cancel) 
        printf "%s\n" "Okay, cancelling diff and exiting."
        exit 1
        ;;
      *)
        printf "%s\n" "Unknown response $response."
        ;;
      esac
    done
  fi
done

diff "$datadir/chromeafter.txt" "$datadir/chromebefore.txt" > "$datadir/targets.txt"
