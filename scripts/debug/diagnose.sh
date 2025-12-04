#!/bin/bash
# Quick diagnostic script to check bridge setup

echo "🔍 iMessage Bridge Diagnostics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

# 1. Check .env
echo "1️⃣  Checking .env configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    echo ""
    echo "Configuration:"
    cat .env | grep -v "API_KEY" | sed 's/API_KEY=.*/API_KEY=***REDACTED***/'
    echo ""
    
    if grep -q "ENABLE_TYPING_INDICATOR" .env; then
        echo "✅ ENABLE_TYPING_INDICATOR found"
    else
        echo "❌ ENABLE_TYPING_INDICATOR missing! Add: ENABLE_TYPING_INDICATOR=true"
    fi
    
    if grep -q "ENABLE_REACTIONS" .env; then
        echo "✅ ENABLE_REACTIONS found"
    else
        echo "❌ ENABLE_REACTIONS missing! Add: ENABLE_REACTIONS=true"
    fi
else
    echo "❌ No .env file found!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 2. Check AppleScript files
echo "2️⃣  Checking AppleScript files..."
for script in "show_typing_indicator.applescript" "send_tapback.applescript" "imessage_send.applescript"; do
    if [ -f "$script" ]; then
        echo "✅ $script exists"
    else
        echo "❌ $script MISSING!"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. Check bridge process
echo "3️⃣  Checking bridge process..."
BRIDGE_PID=$(pgrep -f "python3.*bridge.py")
if [ -n "$BRIDGE_PID" ]; then
    echo "✅ Bridge is running (PID: $BRIDGE_PID)"
    
    # Check how long it's been running
    START_TIME=$(ps -p $BRIDGE_PID -o lstart=)
    echo "   Started: $START_TIME"
else
    echo "❌ Bridge is NOT running!"
    echo "   Start with: python3 bridge.py"
fi

if [ -f "bridge.lock" ]; then
    echo "⚠️  Lock file exists"
else
    echo "ℹ️  No lock file"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 4. Check recent logs
echo "4️⃣  Recent bridge activity (last 10 lines)..."
if [ -f "logs/bridge.log" ]; then
    echo ""
    tail -10 logs/bridge.log
    echo ""
    
    # Check for errors
    ERROR_COUNT=$(grep -c "ERROR\|✗\|❌" logs/bridge.log 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "⚠️  Found $ERROR_COUNT error(s) in log"
        echo ""
        echo "Recent errors:"
        grep "ERROR\|✗\|❌" logs/bridge.log | tail -5
    else
        echo "✅ No errors in log"
    fi
else
    echo "❌ No logs/bridge.log found!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 5. Check typing indicator
echo "5️⃣  Checking typing indicator logs..."
if [ -f "logs/bridge.log" ]; then
    TYPE_COUNT=$(grep -c "\[TYPE\]" logs/bridge.log 2>/dev/null || echo "0")
    if [ "$TYPE_COUNT" -gt 0 ]; then
        echo "✅ Found $TYPE_COUNT typing indicator log entries"
        echo ""
        echo "Last typing indicator attempt:"
        grep "\[TYPE\]" logs/bridge.log | tail -5
    else
        echo "❌ No typing indicator logs found!"
        echo "   Either typing is disabled or bridge hasn't processed messages yet"
    fi
else
    echo "❌ No logs/bridge.log found!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 6. Check reactions
echo "6️⃣  Checking reaction logs..."
if [ -f "logs/bridge.log" ]; then
    REACT_COUNT=$(grep -c "\[REACT\]" logs/bridge.log 2>/dev/null || echo "0")
    if [ "$REACT_COUNT" -gt 0 ]; then
        echo "✅ Found $REACT_COUNT reaction log entries"
        echo ""
        echo "Last reaction attempt:"
        grep "\[REACT\]" logs/bridge.log | tail -5
    else
        echo "ℹ️  No reaction logs found"
        echo "   This is normal if backend hasn't sent any reactions"
    fi
else
    echo "❌ No logs/bridge.log found!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 7. Summary
echo "📊 SUMMARY"
echo ""

ISSUES=0

if [ ! -f ".env" ] || ! grep -q "ENABLE_TYPING_INDICATOR" .env; then
    echo "❌ Missing .env configuration"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -f "show_typing_indicator.applescript" ]; then
    echo "❌ Missing AppleScript files"
    ISSUES=$((ISSUES + 1))
fi

if [ -z "$BRIDGE_PID" ]; then
    echo "❌ Bridge not running"
    ISSUES=$((ISSUES + 1))
fi

if [ -f "logs/bridge.log" ]; then
    ERROR_COUNT=$(grep -c "ERROR\|✗\|❌" logs/bridge.log 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "⚠️  Errors detected in logs ($ERROR_COUNT)"
        ISSUES=$((ISSUES + 1))
    fi
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ No obvious issues detected!"
    echo ""
    echo "If typing bubbles still not working:"
    echo "1. Check accessibility permissions (System Preferences → Security & Privacy)"
    echo "2. Restart bridge: ./setup_and_restart.sh"
    echo "3. Test manually: osascript show_typing_indicator.applescript \"+YOUR_NUMBER\""
else
    echo "Found $ISSUES issue(s) - see details above"
    echo ""
    echo "Recommended action:"
    echo "./setup_and_restart.sh"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

