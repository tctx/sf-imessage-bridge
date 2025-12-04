#!/bin/bash
# Test message sending directly (bypassing backend)

echo "📨 iMessage Bridge - Direct Send Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

# Get phone number
if [ -z "$1" ]; then
    echo "Enter phone number to test (e.g., +18176067157):"
    read -r PHONE_NUMBER
else
    PHONE_NUMBER="$1"
fi

if [ -z "$PHONE_NUMBER" ]; then
    echo "❌ No phone number provided"
    exit 1
fi

echo "Testing with: $PHONE_NUMBER"
echo ""

# Test 1: Direct AppleScript call
echo "1️⃣  Testing direct AppleScript send..."
echo "   Sending: 'Test message from bridge - $(date +%H:%M:%S)'"
echo ""

START_TIME=$(date +%s)
osascript imessage_send.applescript "$PHONE_NUMBER" "Test message from bridge - $(date +%H:%M:%S)" 2>&1
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ AppleScript call succeeded (took ${DURATION}s)"
    echo "   Check your iPhone - you should see the message!"
else
    echo "❌ AppleScript call FAILED (exit code: $EXIT_CODE)"
    echo "   Check error message above"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 2: Typing indicator
echo "2️⃣  Testing typing indicator..."
echo ""

START_TIME=$(date +%s)
osascript show_typing_indicator.applescript "$PHONE_NUMBER" 2>&1
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Typing indicator succeeded (took ${DURATION}s)"
    echo "   Check your iPhone - you should have seen '...' bubble!"
else
    echo "⚠️  Typing indicator failed (exit code: $EXIT_CODE)"
    echo "   Message sending still works, but bubbles won't show"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 3: Typing indicator + message (like bridge does)
echo "3️⃣  Testing full flow (typing indicator + message)..."
echo ""

echo "Showing typing indicator..."
osascript show_typing_indicator.applescript "$PHONE_NUMBER" 2>&1

echo "Waiting 2 seconds (simulating typing)..."
sleep 2

echo "Sending message..."
osascript imessage_send.applescript "$PHONE_NUMBER" "Full flow test - you should have seen typing bubble first! - $(date +%H:%M:%S)" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Full flow completed"
    echo ""
    echo "Check your iPhone:"
    echo "  1. Did you see '...' typing bubble?"
    echo "  2. Did message arrive after ~2 seconds?"
    echo "  3. Does timing feel natural?"
else
    echo "❌ Full flow failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 4: Multiple messages in sequence
echo "4️⃣  Testing multiple messages (like conversation)..."
echo ""

MESSAGES=(
    "Hey! This is the first message."
    "And here's a quick follow-up."
    "Just checking you get all three!"
)

for i in "${!MESSAGES[@]}"; do
    MSG="${MESSAGES[$i]}"
    echo "Message $((i+1)): $MSG"
    
    # Show typing indicator
    osascript show_typing_indicator.applescript "$PHONE_NUMBER" 2>&1 > /dev/null
    
    # Wait realistic time based on length
    CHAR_COUNT=${#MSG}
    DELAY=$(echo "scale=1; $CHAR_COUNT / 55 + 0.5" | bc)
    echo "   Typing for ${DELAY}s..."
    sleep "$DELAY"
    
    # Send message
    osascript imessage_send.applescript "$PHONE_NUMBER" "$MSG" 2>&1 > /dev/null
    
    # Pause before next message
    if [ $i -lt $((${#MESSAGES[@]} - 1)) ]; then
        echo "   Pausing 0.5s before next message..."
        sleep 0.5
    fi
    
    echo ""
done

echo "✅ Multi-message test complete"
echo ""
echo "Check your iPhone:"
echo "  - Should see 3 separate messages"
echo "  - Each with its own typing bubble"
echo "  - Natural timing between them"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
echo "📊 TEST SUMMARY"
echo ""
echo "If you received all messages on your iPhone:"
echo "  ✅ Bridge message sending is WORKING"
echo "  ✅ AppleScript is configured correctly"
echo "  ✅ Messages.app integration is functional"
echo ""
echo "If typing bubbles appeared:"
echo "  ✅ Typing indicators are WORKING"
echo "  ✅ Accessibility permissions are correct"
echo ""
echo "If something didn't work:"
echo "  - Check your iPhone Messages app"
echo "  - Verify the phone number is correct"
echo "  - Check error messages above"
echo "  - Run: ./diagnose.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

