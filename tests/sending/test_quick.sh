#!/bin/bash
# Quick test to verify message sending works

echo "🔍 Quick Bridge Test"
echo "===================="
echo ""

cd "$(dirname "$0")"

# Step 1: Is bridge running?
echo "1️⃣  Checking if bridge is running..."
BRIDGE_PID=$(pgrep -f "python3.*bridge.py")
if [ -n "$BRIDGE_PID" ]; then
    echo "✅ Bridge is running (PID: $BRIDGE_PID)"
else
    echo "❌ Bridge is NOT running!"
    echo ""
    echo "Last error from log:"
    echo "---"
    tail -20 bridge.log | grep -A 5 "ERROR\|Traceback"
    echo "---"
    echo ""
    echo "To fix: ./setup_and_restart.sh"
    exit 1
fi

echo ""

# Step 2: Test message sending directly
echo "2️⃣  Testing direct message send (bypassing backend)..."
echo "Enter your phone number (e.g., +18176067157):"
read -r PHONE

if [ -z "$PHONE" ]; then
    echo "❌ No phone number provided"
    exit 1
fi

echo "Sending test message to $PHONE..."
osascript imessage_send.applescript "$PHONE" "🧪 Bridge test - $(date +%H:%M:%S)" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Message sent! Check your iPhone!"
else
    echo "❌ Message send FAILED!"
    echo "Check that Messages.app is open and logged into iCloud"
    exit 1
fi

echo ""
echo "===================="
echo "✅ Bridge can send messages!"
echo ""
echo "If you didn't receive it, check:"
echo "  - Messages.app is logged in"
echo "  - Phone number format: +1XXXXXXXXXX"
echo "  - Conversation exists in Messages"
echo ""
echo "Next: Test with echo mode:"
echo "  python3 test_echo_mode.py $PHONE"





