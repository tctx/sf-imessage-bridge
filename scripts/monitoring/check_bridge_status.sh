#!/bin/bash
# Quick bridge status checker

cd "$(dirname "$0")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BRIDGE STATUS CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check LaunchAgent
echo "1️⃣  LaunchAgent Status:"
LAUNCHCTL_OUTPUT=$(launchctl list com.sf.imessage-bridge 2>/dev/null)
if [ -n "$LAUNCHCTL_OUTPUT" ]; then
    echo "$LAUNCHCTL_OUTPUT" | grep -E "LastExitStatus|PID" | head -2
    EXIT_STATUS=$(echo "$LAUNCHCTL_OUTPUT" | grep "LastExitStatus" | sed 's/.*= //;s/;//')
    if [ "$EXIT_STATUS" = "0" ] || [ -z "$EXIT_STATUS" ]; then
        echo "   ✅ LaunchAgent is active"
    else
        echo "   ❌ LaunchAgent error (exit status: $EXIT_STATUS)"
    fi
else
    echo "   ❌ LaunchAgent not loaded"
fi

echo ""

# Check running processes
echo "2️⃣  Running Processes:"
INSTANCE_COUNT=$(pgrep -f "bridge.py" | wc -l | tr -d ' ')
if [ "$INSTANCE_COUNT" -eq 0 ]; then
    echo "   ❌ No bridge processes running - BRIDGE IS DOWN!"
    echo ""
    echo "   🔧 To restart:"
    echo "   launchctl start com.sf.imessage-bridge"
elif [ "$INSTANCE_COUNT" -eq 1 ]; then
    BRIDGE_PID=$(pgrep -f "bridge.py")
    echo "   ✅ Bridge is running (PID: $BRIDGE_PID)"
    ps -p $BRIDGE_PID -o etime= | xargs echo "   Running for:"
else
    echo "   ⚠️  Multiple instances running: $INSTANCE_COUNT"
    echo "   PIDs:"
    pgrep -f "bridge.py" | while read pid; do
        ps -p $pid -o pid,etime,command= | sed 's/^/      /'
    done
    echo ""
    echo "   🔧 To fix (kill duplicates and restart):"
    echo "   pkill -f 'bridge.py' && launchctl start com.sf.imessage-bridge"
fi

echo ""

# Check lock file
echo "3️⃣  Lock File:"
if [ -f bridge.lock ]; then
    if lsof bridge.lock >/dev/null 2>&1; then
        LOCK_PID=$(lsof bridge.lock 2>/dev/null | tail -1 | awk '{print $2}')
        echo "   ✅ Lock file held by PID: $LOCK_PID"
    else
        echo "   ⚠️  Stale lock file (not held by any process)"
        echo "   🔧 To fix: rm bridge.lock"
    fi
else
    echo "   ℹ️  No lock file"
fi

echo ""

# Check recent errors
echo "4️⃣  Recent Errors (last 3 lines):"
if [ -f logs/bridge.stderr.log ]; then
    ERROR_COUNT=$(tail -50 logs/bridge.stderr.log 2>/dev/null | grep -c "Error\|ERROR\|Traceback" || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "   ⚠️  Found $ERROR_COUNT error(s) in recent logs"
        tail -3 logs/bridge.stderr.log 2>/dev/null | sed 's/^/      /'
    else
        echo "   ✅ No recent errors"
    fi
else
    echo "   ℹ️  No stderr log file"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Summary
echo ""
echo "📋 SUMMARY:"
if [ "$INSTANCE_COUNT" -eq 1 ] && [ "$EXIT_STATUS" = "0" ] 2>/dev/null; then
    echo "✅ Bridge is running properly!"
elif [ "$INSTANCE_COUNT" -eq 0 ]; then
    echo "❌ BRIDGE IS NOT RUNNING - ACTION REQUIRED"
    echo "   Run: launchctl start com.sf.imessage-bridge"
else
    echo "⚠️  Issues detected - see details above"
fi

echo ""

