#!/bin/bash
# SAFE bridge startup - prevents multiple instances and spam

echo "🛡️  SAFE BRIDGE STARTUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

# Step 1: Kill ANY existing bridge processes
echo "1️⃣  Killing any existing bridge processes..."
pkill -9 -f "Python.*bridge.py" 2>/dev/null
pkill -9 -f "python3.*bridge.py" 2>/dev/null
sleep 2

# Check if any are still running
REMAINING=$(pgrep -f "bridge.py" | wc -l)
if [ "$REMAINING" -gt 0 ]; then
    echo "❌ WARNING: $REMAINING bridge process(es) still running!"
    echo "   Killing with extreme prejudice..."
    killall -9 Python 2>/dev/null
    killall -9 python3 2>/dev/null
    sleep 2
fi

# Verify all killed
if pgrep -f "bridge.py" > /dev/null; then
    echo "❌ FAILED: Bridge processes won't die!"
    echo "   You may need to restart your Mac"
    exit 1
fi

echo "✅ All bridge processes killed"
echo ""

# Step 2: Remove lock files
echo "2️⃣  Removing lock files..."
rm -f bridge.lock test_echo.state 2>/dev/null
echo "✅ Lock files removed"
echo ""

# Step 3: Check state
echo "3️⃣  Checking state..."
CURRENT_STATE=$(cat last_rowid.state 2>/dev/null || echo "0")
LATEST_MSG=$(sqlite3 ~/Library/Messages/chat.db "SELECT MAX(ROWID) FROM message WHERE service='iMessage'" 2>/dev/null || echo "0")

echo "   Current state: $CURRENT_STATE"
echo "   Latest message: $LATEST_MSG"

if [ "$CURRENT_STATE" -lt "$LATEST_MSG" ]; then
    echo "   ⚠️  State is behind - updating to prevent reprocessing old messages"
    echo "$LATEST_MSG" > last_rowid.state
    echo "   ✅ Updated state to $LATEST_MSG"
fi
echo ""

# Step 4: Verify .env
echo "4️⃣  Checking configuration..."
if ! grep -q "ENABLE_TYPING_INDICATOR" .env 2>/dev/null; then
    echo "   Adding ENABLE_TYPING_INDICATOR=true"
    echo "ENABLE_TYPING_INDICATOR=true" >> .env
fi
if ! grep -q "ENABLE_REACTIONS" .env 2>/dev/null; then
    echo "   Adding ENABLE_REACTIONS=true"
    echo "ENABLE_REACTIONS=true" >> .env
fi
echo "✅ Configuration OK"
echo ""

# Step 5: Warning about backend
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  WARNING: Your backend is slow!"
echo ""
echo "If your backend takes > 30 seconds to respond:"
echo "  - Bridge will crash"
echo "  - Multiple instances might start"
echo "  - Messages will be re-sent"
echo ""
echo "Before starting, check your backend:"
echo "  - Is it running?"
echo "  - Does it respond quickly (< 5 seconds)?"
echo "  - Is ngrok tunnel active?"
echo ""
read -p "Is your backend ready and fast? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "❌ Don't start the bridge until your backend is fixed!"
    echo ""
    echo "Alternative: Use echo mode for testing:"
    echo "  python3 test_echo_mode.py +YOUR_NUMBER"
    echo ""
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 6: Start bridge
echo "5️⃣  Starting bridge..."
mkdir -p logs
nohup python3 -u bridge.py > logs/bridge.log 2>&1 &
BRIDGE_PID=$!

sleep 3

# Verify it started
if kill -0 $BRIDGE_PID 2>/dev/null; then
    echo "✅ Bridge started successfully (PID: $BRIDGE_PID)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 To monitor:"
    echo "   tail -f logs/bridge.log"
    echo ""
    echo "⚠️  If you see duplicate messages being sent:"
    echo "   1. Run: pkill -9 -f bridge.py"
    echo "   2. Check for multiple instances: ps aux | grep bridge"
    echo "   3. Only restart when backend is fast!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Bridge failed to start!"
    echo ""
    echo "Check logs:"
    tail -20 logs/bridge.log
    exit 1
fi



