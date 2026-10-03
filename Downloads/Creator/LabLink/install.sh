#!/bin/bash
# LabLinkD — Post-Install Script
# Builds, installs, and loads the daemon as a system-level LaunchDaemon.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_NAME="LabLinkD"
INSTALL_DIR="/usr/local/bin"
PLIST_NAME="com.lablink.daemon.plist"
LAUNCH_DAEMONS_DIR="/Library/LaunchDaemons"
LOG_DIR="/var/log/lablink"

echo "=== LabLinkD Installer ==="
echo "Installing as system-level LaunchDaemon (starts before user login)"

# 1. Build release binary
echo "[1/4] Building $BINARY_NAME (Release, arm64)..."
cd "$SCRIPT_DIR"
swift build -c release --arch arm64

# 2. Copy binary
echo "[2/4] Installing binary to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp ".build/release/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
sudo chmod 755 "$INSTALL_DIR/$BINARY_NAME"

# 3. Install plist to /Library/LaunchDaemons/
echo "[3/4] Installing LaunchDaemon plist..."
sudo cp "$SCRIPT_DIR/$PLIST_NAME" "$LAUNCH_DAEMONS_DIR/$PLIST_NAME"
sudo chown root:wheel "$LAUNCH_DAEMONS_DIR/$PLIST_NAME"
sudo chmod 644 "$LAUNCH_DAEMONS_DIR/$PLIST_NAME"

# Create log directory
sudo mkdir -p "$LOG_DIR"
sudo chmod 755 "$LOG_DIR"

# 4. Load daemon
echo "[4/4] Loading daemon..."
sudo launchctl unload "$LAUNCH_DAEMONS_DIR/$PLIST_NAME" 2>/dev/null || true
sudo launchctl load -w "$LAUNCH_DAEMONS_DIR/$PLIST_NAME"

echo "=== LabLinkD installed and loaded as system daemon. ==="
echo "Check status: sudo launchctl list | grep lablink"
echo "View logs:    cat /var/log/lablink/lablinkd.log"
echo "Uninstall:    sudo launchctl unload $LAUNCH_DAEMONS_DIR/$PLIST_NAME"
