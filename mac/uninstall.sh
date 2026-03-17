#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

LABEL="com.openvpn.agent"
PLIST="/Library/LaunchDaemons/com.openvpn.agent.plist"
APP="/Applications/IITDelhiVPN.app"
LOG="/var/log/ovpnagent.error.log"

echo "Stopping OpenVPN agent..."

if launchctl list | grep -q "$LABEL"; then
    launchctl bootout system "$PLIST"
fi

echo "Removing launch daemon..."
[ -f "$PLIST" ] && rm "$PLIST"

echo "Removing logs..."
[ -f "$LOG" ] && rm "$LOG"

echo "Removing application..."
[ -d "$APP" ] && rm -rf "$APP"

echo "Uninstall complete."
