#!/bin/bash
# Setup and Restart Bridge with Enhanced Features

echo "🔧 Setting up iMessage Bridge..."
echo ""

cd "$(dirname "$0")"

# 1. Add missing .env variables if not present
echo "📝 Checking .env configuration..."
if ! grep -q "ENABLE_TYPING_INDICATOR" .env 2>/dev/null; then
    echo "ENABLE_TYPING_INDICATOR=true" >> .env
    echo "✅ Added ENABLE_TYPING_INDICATOR=true to .env"
fi

if ! grep -q "ENABLE_REACTIONS" .env 2>/dev/null; then
    echo "ENABLE_REACTIONS=true" >> .env
    echo "✅ Added ENABLE_REACTIONS=true to .env"
fi

echo ""
echo "Current .env configuration:"
cat .env
echo ""

# 2. Check AppleScript files exist
echo "📂 Checking AppleScript files..."
if [ ! -f "show_typing_indicator.applescript" ]; then
    echo "❌ ERROR: show_typing_indicator.applescript not found!"
    exit 1
fi
if [ ! -f "send_tapback.applescript" ]; then
    echo "❌ ERROR: send_tapback.applescript not found!"
    exit 1
fi
if [ ! -f "imessage_send.applescript" ]; then
    echo "❌ ERROR: imessage_send.applescript not found!"
    exit 1
fi
echo "✅ All AppleScript files found"
echo ""

# 3. Check accessibility permissions
echo "🔐 Checking accessibility permissions..."
echo "⚠️  IMPORTANT: You need to grant accessibility permissions for:"
echo "   - /usr/bin/osascript"
echo "   - Terminal.app (or your terminal)"
echo "   - Cursor (if using Cursor)"
echo ""
echo "Open: System Preferences → Security & Privacy → Privacy → Accessibility"
echo ""
read -p "Have you granted accessibility permissions? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️  Please grant permissions and run this script again"
    exit 1
fi

# 4. Kill old bridge
echo ""
echo "🛑 Stopping old bridge..."
pkill -9 -f "python3.*bridge.py" 2>/dev/null && echo "✅ Stopped old bridge process" || echo "ℹ️  No bridge process was running"
rm -f bridge.lock && echo "✅ Removed lock file" || true

# 5. Test typing indicator
echo ""
echo "🧪 Testing typing indicator..."
echo "Enter a phone number to test (e.g., +18176067157): "
read -r TEST_NUMBER
if [ -n "$TEST_NUMBER" ]; then
    echo "Testing typing indicator to $TEST_NUMBER..."
    osascript show_typing_indicator.applescript "$TEST_NUMBER" 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Typing indicator test passed!"
    else
        echo "❌ Typing indicator test failed - check permissions!"
        echo "You can continue, but typing bubbles may not work."
    fi
fi

# 6. Start new bridge
echo ""
echo "🚀 Starting bridge with verbose logging..."
mkdir -p logs
nohup python3 -u bridge.py > logs/bridge.log 2>&1 &
BRIDGE_PID=$!

sleep 2

# Check if bridge is running
if ps -p $BRIDGE_PID > /dev/null; then
    echo "✅ Bridge started successfully (PID: $BRIDGE_PID)"
    echo ""
    echo "📊 Watching logs (Ctrl+C to exit, bridge will continue running)..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -f logs/bridge.log
else
    echo "❌ Bridge failed to start!"
    echo "Check logs/bridge.log for errors:"
    tail -20 logs/bridge.log
    exit 1
fi

