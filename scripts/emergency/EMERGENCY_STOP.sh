#!/bin/bash
# EMERGENCY STOP - Kill ALL bridge processes immediately

echo "🚨 EMERGENCY STOP - KILLING ALL BRIDGE PROCESSES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Kill by name
pkill -9 -f "Python.*bridge.py" 2>/dev/null
pkill -9 -f "python3.*bridge.py" 2>/dev/null
pkill -9 -f "test_echo_mode.py" 2>/dev/null

sleep 2

# Check for survivors
REMAINING=$(ps aux | grep -E "[Pp]ython.*bridge" | grep -v grep | wc -l)

if [ "$REMAINING" -gt 0 ]; then
    echo "⚠️  Found $REMAINING remaining processes, killing harder..."
    ps aux | grep -E "[Pp]ython.*bridge" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    sleep 1
fi

# Final check
if ps aux | grep -E "[Pp]ython.*bridge" | grep -v grep > /dev/null; then
    echo "❌ SOME PROCESSES WON'T DIE!"
    echo ""
    echo "Remaining processes:"
    ps aux | grep -E "[Pp]ython.*bridge" | grep -v grep
    echo ""
    echo "Manual kill required:"
    ps aux | grep -E "[Pp]ython.*bridge" | grep -v grep | awk '{print "kill -9 " $2}'
else
    echo "✅ ALL BRIDGE PROCESSES KILLED"
fi

# Clean up
cd "$(dirname "$0")"
rm -f bridge.lock test_echo.state 2>/dev/null
echo "✅ Lock files removed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Bridge stopped. To restart SAFELY:"
echo "  ./start_bridge_safe.sh"
echo ""
echo "To test WITHOUT backend (safe):"
echo "  python3 test_echo_mode.py +YOUR_NUMBER"
echo ""





