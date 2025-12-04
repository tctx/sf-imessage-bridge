#!/bin/bash
# Install the iMessage Bridge as a Launch Agent
# This will keep exactly one bridge running at all times

set -e

PLIST_NAME="com.sf.imessage-bridge.plist"
PLIST_SOURCE="/Users/syntheticfriends/Documents/projects/sf-imessage-bridge/$PLIST_NAME"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "📦 Installing iMessage Bridge Launch Agent..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$HOME/Library/LaunchAgents"

# Copy the plist file
cp "$PLIST_SOURCE" "$PLIST_DEST"
echo "✓ Copied plist to $PLIST_DEST"

# Unload if already loaded (ignore errors)
launchctl unload "$PLIST_DEST" 2>/dev/null || true
echo "✓ Unloaded any existing service"

# Load the launch agent
launchctl load "$PLIST_DEST"
echo "✓ Loaded launch agent"

# Start it immediately
launchctl start com.sf.imessage-bridge
echo "✓ Started service"

echo ""
echo "🎉 iMessage Bridge is now running as a Launch Agent!"
echo ""
echo "Useful commands:"
echo "  Check status:  launchctl list | grep imessage-bridge"
echo "  View logs:     tail -f ~/Documents/projects/sf-imessage-bridge/bridge.*.log"
echo "  Stop service:  launchctl stop com.sf.imessage-bridge"
echo "  Restart:       launchctl stop com.sf.imessage-bridge && launchctl start com.sf.imessage-bridge"
echo "  Uninstall:     launchctl unload ~/Library/LaunchAgents/$PLIST_NAME && rm ~/Library/LaunchAgents/$PLIST_NAME"
echo ""
echo "The bridge will:"
echo "  ✓ Start automatically on login/boot"
echo "  ✓ Restart automatically if it crashes"
echo "  ✓ Keep exactly one instance running (via bridge.lock)"

