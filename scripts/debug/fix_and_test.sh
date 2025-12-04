#!/bin/bash
# Fix bridge issues and test everything

echo "🔧 Bridge Fix & Test Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

# Get phone number
if [ -z "$1" ]; then
    echo "Usage: ./fix_and_test.sh +YOUR_PHONE_NUMBER"
    echo ""
    echo "Example:"
    echo "  ./fix_and_test.sh +18176067157"
    exit 1
fi

PHONE="$1"

echo "Testing with phone: $PHONE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Check current state
echo "📊 STEP 1: Checking current state"
echo ""

BRIDGE_PID=$(pgrep -f "python3.*bridge.py")
if [ -n "$BRIDGE_PID" ]; then
    echo "⚠️  Bridge is running but may have issues (PID: $BRIDGE_PID)"
    echo "   Last errors:"
    tail -10 bridge.log | grep -E "ERROR|Timeout|Failed" | tail -3
else
    echo "❌ Bridge is NOT running"
    echo "   Last crash reason:"
    tail -20 bridge.log | grep -E "ERROR|Timeout|Exception" | tail -2
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 2: Test direct send (no backend)
echo "📨 STEP 2: Testing direct message send (no backend)"
echo ""
echo "This tests if your Mac can send iMessages at all..."
echo ""

TEST_MSG="🧪 Direct test - $(date +%H:%M:%S)"
echo "Sending: $TEST_MSG"
echo "To: $PHONE"
echo ""

osascript imessage_send.applescript "$PHONE" "$TEST_MSG" 2>&1
SEND_EXIT=$?

if [ $SEND_EXIT -eq 0 ]; then
    echo ""
    echo "✅ DIRECT SEND WORKS!"
    echo "   Check your iPhone - you should see the test message"
    echo ""
    SEND_WORKS=true
else
    echo ""
    echo "❌ DIRECT SEND FAILED!"
    echo "   This means the basic sending mechanism is broken"
    echo ""
    echo "Fixes:"
    echo "  1. Open Messages.app"
    echo "  2. Make sure you're logged into iCloud"
    echo "  3. Send yourself a test message from $PHONE first"
    echo ""
    SEND_WORKS=false
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 3: Test typing indicator
echo "💬 STEP 3: Testing typing indicators"
echo ""

osascript show_typing_indicator.applescript "$PHONE" 2>&1
TYPING_EXIT=$?

if [ $TYPING_EXIT -eq 0 ]; then
    echo "✅ TYPING INDICATORS WORK!"
    echo "   Check your iPhone - you should have seen '...' bubble"
    TYPING_WORKS=true
else
    echo "⚠️  TYPING INDICATORS FAILED"
    echo "   Messages will still send, but no bubbles"
    echo "   Fix: Grant accessibility permissions"
    TYPING_WORKS=false
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 4: Check backend
echo "🌐 STEP 4: Checking backend connection"
echo ""

BACKEND_URL=$(grep "SF_API_URL" .env | cut -d= -f2)
echo "Backend: $BACKEND_URL"
echo ""

# Quick health check
echo "Testing backend response time..."
START=$(date +%s)
curl -s -o /dev/null -w "%{http_code}" -m 5 "$BACKEND_URL" 2>&1 > /dev/null
CURL_EXIT=$?
END=$(date +%s)
DURATION=$((END - START))

if [ $CURL_EXIT -eq 0 ] && [ $DURATION -lt 5 ]; then
    echo "✅ Backend responds in ${DURATION}s"
    BACKEND_WORKS=true
elif [ $DURATION -ge 5 ]; then
    echo "⚠️  Backend is SLOW (${DURATION}s+)"
    echo "   This is causing bridge to timeout and crash!"
    BACKEND_WORKS=false
else
    echo "❌ Backend not responding"
    echo "   Bridge will crash when trying to reach it"
    BACKEND_WORKS=false
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 5: Summary and recommendations
echo "📋 SUMMARY & NEXT STEPS"
echo ""

if [ "$SEND_WORKS" = true ]; then
    echo "✅ Message sending: WORKING"
else
    echo "❌ Message sending: BROKEN - Fix Messages.app first!"
fi

if [ "$TYPING_WORKS" = true ]; then
    echo "✅ Typing indicators: WORKING"
else
    echo "⚠️  Typing indicators: NOT WORKING - Grant permissions"
fi

if [ "$BACKEND_WORKS" = true ]; then
    echo "✅ Backend: RESPONDING"
else
    echo "❌ Backend: SLOW/DOWN - Bridge will crash"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Recommendations
if [ "$SEND_WORKS" = true ]; then
    echo "🎯 RECOMMENDED NEXT STEPS:"
    echo ""
    
    if [ "$BACKEND_WORKS" = false ]; then
        echo "⚠️  Your backend is the problem!"
        echo ""
        echo "Option 1: Test WITHOUT backend (Echo Mode)"
        echo "  python3 test_echo_mode.py $PHONE"
        echo "  This will echo your messages back (proves sending works)"
        echo ""
        echo "Option 2: Fix your backend"
        echo "  - Check why it's timing out"
        echo "  - Optimize response time to < 5 seconds"
        echo "  - Restart backend service"
        echo ""
        echo "Option 3: Use echo mode while debugging backend"
        echo "  This lets you verify the bridge works while fixing backend"
        echo ""
    else
        echo "✅ Everything looks good!"
        echo ""
        echo "To restart bridge with better error handling:"
        echo "  ./setup_and_restart.sh"
        echo ""
        echo "Then test with echo mode:"
        echo "  python3 test_echo_mode.py $PHONE"
        echo ""
    fi
else
    echo "❌ FIX MESSAGE SENDING FIRST!"
    echo ""
    echo "1. Open Messages.app"
    echo "2. Check you're logged into iCloud (Preferences → iMessage)"
    echo "3. Send yourself a message from $PHONE"
    echo "4. Run this script again"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"





