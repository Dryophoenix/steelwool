#!/bin/zsh

# SteelWool install script.
# Must be run with sudo.

GITHUB_RAW="https://raw.githubusercontent.com/dryophoenix/steelwool/main"
GITHUB_API="https://api.github.com/repos/dryophoenix/steelwool"
INSTALL_BIN="/usr/local/bin"
INSTALL_SHARE="/usr/local/share/SteelWool"
DATA_DIR="$HOME/Library/Application Support/SteelWool"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

if [ "$(id -u)" -ne 0 ]; then
  printf "%s\n" "SteelWool install requires sudo. Please re-run with sudo." >&2
  exit 1
fi

# Install jq if missing
if ! command -v jq &>/dev/null; then
  printf "%s\n" "jq not found, installing..."
  arch=$(uname -m)
  if [ "$arch" = "arm64" ]; then
    jq_url="https://github.com/jqlang/jq/releases/latest/download/jq-macos-arm64"
  else
    jq_url="https://github.com/jqlang/jq/releases/latest/download/jq-macos-amd64"
  fi
  curl -sL "$jq_url" -o "$INSTALL_BIN/jq" || {
    printf "%s\n" "Failed to install jq. Aborting." >&2
    exit 1
  }
  chmod +x "$INSTALL_BIN/jq"
fi

# Create directories
mkdir -p "$INSTALL_SHARE"
mkdir -p "$DATA_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Install steelwool
curl -sL "$GITHUB_RAW/steelwool.sh" -o "$INSTALL_BIN/steelwool" || {
  printf "%s\n" "Failed to download steelwool.sh. Aborting." >&2
  exit 1
}
chmod +x "$INSTALL_BIN/steelwool"

# Install libsteelwool
curl -sL "$GITHUB_RAW/libsteelwool.sh" -o "$INSTALL_SHARE/libsteelwool.sh" || {
  printf "%s\n" "Failed to download libsteelwool.sh. Aborting." >&2
  exit 1
}

# Download and verify targets.txt
remotesum=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  "$GITHUB_API/contents/targets.sha256" \
  | jq -r '.content' | base64 --decode | awk '{print $1}')

curl -sL "$GITHUB_RAW/targets.txt" -o "$DATA_DIR/targets.txt" || {
  printf "%s\n" "Failed to download targets.txt. Aborting." >&2
  exit 1
}

localsum=$(shasum -a 256 "$DATA_DIR/targets.txt" | awk '{print $1}')

if [ "$localsum" != "$remotesum" ]; then
  printf "%s\n" "targets.txt checksum mismatch. Aborting." >&2
  exit 1
fi

# Install launchd plist
cat > "$LAUNCH_AGENTS_DIR/net.dryophoenix.steelwool.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>net.dryophoenix.steelwool</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/steelwool</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF

launchctl unload "$LAUNCH_AGENTS_DIR/net.dryophoenix.steelwool.plist" 2>/dev/null
launchctl load "$LAUNCH_AGENTS_DIR/net.dryophoenix.steelwool.plist"

printf "%s\n" "SteelWool installed successfully."
