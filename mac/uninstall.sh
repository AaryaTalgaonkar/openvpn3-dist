#!/bin/bash

set -e

LABEL="com.openvpn.agent"
PLIST="/Library/LaunchDaemons/com.openvpn.agent.plist"
APP="/Applications/IITDelhiVPN.app"
LOG="/var/log/ovpnagent.error.log"

echo "Stopping OpenVPN agent..."

# Stop the launch daemon if loaded
if launchctl list | grep -q "$LABEL"; then
    sudo launchctl bootout system "$PLIST"
fi

echo "Removing launch daemon..."
if [ -f "$PLIST" ]; then
    sudo rm "$PLIST"
fi

echo "Removing logs..."
if [ -f "$LOG" ]; then
    sudo rm "$LOG"
fi

echo "Removing application..."
if [ -d "$APP" ]; then
    sudo rm -rf "$APP"
fi

echo "Uninstall complete."
