#!/bin/zsh

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

if [ ! -f "$HOME/Library/Application Support/SteelWool/token" ]; then
  printf "%s\n" "SteelWoolDiff requires a Github token at $HOME/Library/Application Support/SteelWool/token. Exiting."
  exit 1
fi

if [ ! -d "$HOME/Library/Application Support/SteelWool/contents" ]; then
  mkdir "$HOME/Library/Application Support/SteelWool/contents"
fi

token=$(cat "$HOME/Library/Application Support/SteelWool/token")

while [ true ]; do
  rm "$datadir/chromebefore.txt" >/dev/null
  find "$HOME/Library/Application Support/Google/Chrome" >> "$datadir/chromebefore.txt"
  
  while [ true ]; do
    read "response?Log into Chrome, then press Enter. (C)ancel: "
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
  find "$HOME/Library/Application Support/Google/Chrome" >> "$datadir/chromeafter.txt"

  if [ $(wc -l < "$datadir/chromeafter.txt") -gt $((${DIFF_SENSITIVITY:-10} + $(wc -l < "$datadir/chromebefore.txt"))) ]; then
    break
  else
    while [ true ]; do
      read "response?There are fewer new lines than would be expected, did you log in? (y/n/(c)ancel): "
      case $response in
      y | Y | yes | Yes)
        printf "%s\n" "Okay, running diff."
        FORCE_DIFF=1
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
    if [ "${FORCE_DIFF:-0}" -eq 1 ]; then
      break
    fi
  fi
done

diff "$datadir/chromeafter.txt" "$datadir/chromebefore.txt" > "$datadir/contents/targets.txt"

# Compute SHA-256 of this script and compare against the canonical checksum on GitHub.
# This ensures only an unmodified, trusted version of steelwooldiff can push targets.
checksum=$(shasum -a 256 "$0" | awk '{print $1}')

diffsha=$(curl -s \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/dryophoenix/steelwool/contents/steelwooldiff.sha256 \
  | jq -r '.content' | base64 --decode | awk '{print $1}')

if [ "$checksum" != "$diffsha" ]; then
  printf "%s\n" "You are using a modified, outdated, or corrupted version of SteelWoolDiff. Quitting."
  exit 1
fi

# Compute checksum of targets.txt and write it to targets.sha256
targsum=$(shasum -a 256 "$datadir/contents/targets.txt" | awk '{print $1}')
printf "%s\n" "$targsum" > "$datadir/contents/targets.sha256"

# Get the sha file from git
targsha=$(curl -s \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/dryophoenix/steelwool/contents/targets.sha256 \
  | jq -r '.sha')

targtxtsha=$(curl -s \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/dryophoenix/steelwool/contents/targets.txt \
  | jq -r '.sha')

# Base64-encode the files so github can recieve them
contargsum=$(base64 < "$datadir/contents/targets.sha256")
contarg=$(base64 < "$datadir/contents/targets.txt")

# put the files in github
curl -s -X PUT \
     -H "Authorization: Bearer $token" \
     -H "Accept: application/vnd.github+json" \
     -d "{\"message\":\"update targets checksum\",\"content\":\"$contargsum\",\"sha\":\"$targsha\"}" \
     https://api.github.com/repos/dryophoenix/steelwool/contents/targets.sha256

curl -s -X PUT \
     -H "Authorization: Bearer $token" \
     -H "Accept: application/vnd.github+json" \
     -d "{\"message\":\"update targets.txt\",\"content\":\"$contarg\",\"sha\":\"$targtxtsha\"}" \
     https://api.github.com/repos/dryophoenix/steelwool/contents/targets.txt
