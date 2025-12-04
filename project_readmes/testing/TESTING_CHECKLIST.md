# 🧪 Testing Checklist - AppleScript Enhancements

**Use this checklist to verify all features are working correctly.**

---

## ✅ Pre-Flight Checks

### 1. Verify Accessibility Permissions
- [ ] Open **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
- [ ] Verify these are added and checked:
  - [ ] `/usr/bin/osascript` ✅
  - [ ] `/Applications/Utilities/Terminal.app` ✅
  - [ ] **Cursor** (if using Cursor) ✅

### 2. Check Environment
```bash
# Check .env file exists
cat .env | grep ENABLE

# Should show:
# ENABLE_TYPING_INDICATOR=true
# ENABLE_REACTIONS=true
```

### 3. Verify Messages.app
- [ ] Messages.app is logged into iCloud
- [ ] Test conversation exists (send yourself a message)

---

## 🔧 Unit Tests (Individual Features)

### Test 1: Basic Message Sending
```bash
osascript imessage_send.applescript "+YOUR_NUMBER" "Test message"
```

**Expected:**
- ✅ Message sends to your number
- ✅ Appears in Messages.app
- ✅ Appears on iPhone

**Status:** [ ] PASS [ ] FAIL

---

### Test 2: Message Sending with Effect Parameter
```bash
osascript imessage_send.applescript "+YOUR_NUMBER" "Test effect" "slam"
```

**Expected:**
- ✅ Message sends normally
- ⚠️ Effect won't show on macOS (iOS only)
- ✅ No errors in terminal

**Status:** [ ] PASS [ ] FAIL

**Notes:** Effect parameter accepted but ignored on macOS (expected).

---

### Test 3: Typing Indicator
```bash
osascript show_typing_indicator.applescript "+YOUR_NUMBER"
```

**Expected:**
- ✅ Messages.app activates
- ✅ Brief typing action visible
- ✅ Returns "ok"
- ✅ Your iPhone shows "..." bubble (check phone!)

**Status:** [ ] PASS [ ] FAIL

---

### Test 4: Tapback Reaction
```bash
osascript send_tapback.applescript "+YOUR_NUMBER" "like"
```

**Expected:**
- ✅ Messages.app activates
- ✅ Context menu appears on last message
- ✅ "Like" reaction appears on message
- ✅ Returns "reaction_sent:like"

**Status:** [ ] PASS [ ] FAIL

**If Failed:**
- Check accessibility permissions
- Ensure conversation has at least one message
- Try manually: Right-click message → verify menu appears

---

### Test 5: Different Reaction Types
```bash
osascript send_tapback.applescript "+YOUR_NUMBER" "love"
osascript send_tapback.applescript "+YOUR_NUMBER" "haha"
osascript send_tapback.applescript "+YOUR_NUMBER" "emphasize"
```

**Expected:**
- ✅ Each reaction type works
- ✅ Correct emoji appears

**Status:** [ ] PASS [ ] FAIL

---

### Test 6: Message Splitter Utility
```bash
python3 message_splitter.py
```

**Expected:**
- ✅ Shows test cases
- ✅ Demonstrates message splitting
- ✅ No errors
- ✅ Output looks reasonable

**Status:** [ ] PASS [ ] FAIL

---

## 🔄 Integration Tests (Full Bridge Flow)

### Test 7: Bridge Startup
```bash
# Kill existing bridge if running
pkill -f "python3 bridge.py"
rm -f bridge.lock

# Start fresh
nohup python3 -u bridge.py > bridge.log 2>&1 &

# Check it's running
ps aux | grep bridge.py
```

**Expected:**
- ✅ Bridge starts without errors
- ✅ Process is running
- ✅ Log file created

**Status:** [ ] PASS [ ] FAIL

---

### Test 8: Watch Logs
```bash
tail -f bridge.log
```

**Expected Output:**
```
Starting bridge. Watching for new messages after ROWID X...
Typing indicator: enabled
Reactions: enabled
```

**Status:** [ ] PASS [ ] FAIL

---

### Test 9: Send Message to SF Number (From iPhone)

**Steps:**
1. Open Messages on your iPhone
2. Send "test" to your SF number
3. Watch bridge logs
4. Watch iPhone for response

**Expected Log Output:**
```
[IN] +1234567890: test
[PAUSE] Waiting 0.3s before typing...
[TYPE] Typing 'Response text...' for 2.1s (XX chars)
[OUT] To +1234567890: Response text
[SUCCESS] Processed message ID XXX
```

**Expected on iPhone:**
- ✅ Your message delivers
- ✅ "..." typing bubble appears
- ✅ Response message(s) arrive
- ✅ Timing feels natural

**Status:** [ ] PASS [ ] FAIL

---

### Test 10: Response with Reaction

**Backend Response Required:**
```json
{
  "messages": [{"text": "Got it!"}],
  "reaction": {"type": "like", "delay_before": 0.5}
}
```

**Expected Log Output:**
```
[REACT] Sending like to +1234567890
[REACT] ✓ like reaction succeeded on attempt 1
```

**Expected on iPhone:**
- ✅ Previous message gets "👍" reaction
- ✅ Then response message arrives

**Status:** [ ] PASS [ ] FAIL

---

### Test 11: Multiple Messages in Sequence

**Backend Response Required:**
```json
{
  "messages": [
    {"text": "Great question!"},
    {"text": "Let me explain how that works."},
    {"text": "Does that make sense?"}
  ]
}
```

**Expected:**
- ✅ Three separate typing indicators
- ✅ Three separate message bubbles
- ✅ Natural pauses between them
- ✅ Total timing feels realistic

**Status:** [ ] PASS [ ] FAIL

---

### Test 12: Rapid Messages (Stress Test)

**Steps:**
1. Send 5 messages quickly to SF number
2. Watch logs
3. Verify all get processed

**Expected:**
- ✅ All 5 messages get responses
- ✅ No duplicates
- ✅ No errors in logs
- ✅ Bridge handles queue well

**Status:** [ ] PASS [ ] FAIL

---

## 🎯 Quality Tests (Human Feel)

### Test 13: Timing Feels Natural

Send various messages and evaluate:

- [ ] **Quick responses** - Typing starts within 0.3s
- [ ] **Not too fast** - Doesn't feel robotic
- [ ] **Not too slow** - Doesn't feel laggy
- [ ] **Variation** - Each message feels slightly different
- [ ] **Natural pauses** - Between multiple messages

**Overall Feel:** [ ] Human-like [ ] Robotic [ ] Too slow [ ] Too fast

---

### Test 14: Reactions Feel Appropriate

Test reactions in context:

- [ ] **Timing** - Reaction appears at right moment
- [ ] **Not overused** - Don't react to every message
- [ ] **Context makes sense** - Right reaction for situation
- [ ] **Adds to conversation** - Feels engaging

**Overall Feel:** [ ] Natural [ ] Forced [ ] Too frequent [ ] Good

---

### Test 15: Message Grouping (If Using Splitter)

Check how messages are split:

- [ ] **No mid-sentence breaks** - Critical!
- [ ] **Complete thoughts** - Each bubble makes sense alone
- [ ] **Natural breaks** - Where a human would break
- [ ] **Questions separate** - Questions in own bubbles
- [ ] **Not too short** - Bubbles aren't awkwardly tiny
- [ ] **Not too long** - Bubbles aren't wall-of-text

**Overall Feel:** [ ] Natural [ ] Awkward [ ] Perfect [ ] Needs work

---

## 🐛 Error Handling Tests

### Test 16: Retry Logic (Typing Indicator)

**Steps:**
1. Quit Messages.app completely
2. Send message to SF number
3. Watch logs

**Expected:**
```
[TYPE] ⚠️ Typing indicator failed (attempt 1/2), retrying...
[TYPE] ✓ Typing indicator succeeded on attempt 2
```

**Status:** [ ] PASS [ ] FAIL

---

### Test 17: Reaction Failure (Non-Blocking)

**Steps:**
1. Revoke accessibility permission temporarily
2. Backend sends reaction
3. Verify message still sends

**Expected:**
```
[REACT] ✗ Failed to send like reaction after 2 attempts: error
[REACT] ⚠️ Reaction may not have been delivered, continuing with messages...
[OUT] To +1234567890: Message sent anyway
```

**Status:** [ ] PASS [ ] FAIL

---

### Test 18: Invalid Reaction Type

```bash
osascript send_tapback.applescript "+YOUR_NUMBER" "invalid"
```

**Expected:**
- ❌ Error message: "Unknown reaction type: invalid"

**Status:** [ ] PASS [ ] FAIL

---

## 📊 Performance Tests

### Test 19: Message Latency

**Measure:** Time from receiving message to sending response

**Steps:**
1. Note time when sending message to SF
2. Note time when response arrives
3. Calculate total latency

**Expected:**
- ⏱️ Typing delay: 1.5-5s (based on message length)
- ⏱️ Processing: < 1s
- ⏱️ Total: 2-6s for typical response

**Actual:** _______ seconds

**Status:** [ ] Within target [ ] Too slow

---

### Test 20: Multiple Conversations

**Steps:**
1. Have 2 people text SF number simultaneously
2. Verify both get responses
3. Check for crosstalk

**Expected:**
- ✅ Both get responses
- ✅ No messages swapped between conversations
- ✅ Timing remains good

**Status:** [ ] PASS [ ] FAIL

---

## 🎉 Final Validation

### Overall System Health

- [ ] Bridge has been running for 1+ hour without crashes
- [ ] No memory leaks observed
- [ ] Log file not excessively large
- [ ] Messages.app remains stable
- [ ] No duplicate messages sent
- [ ] All features working as expected

### User Experience

Rate each aspect (1-5, 5 being best):

- **Natural timing:** [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5
- **Typing indicators:** [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5
- **Reaction usage:** [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5
- **Message splitting:** [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5
- **Overall feel:** [ ] 1 [ ] 2 [ ] 3 [ ] 4 [ ] 5

### Would You Be Fooled?

**If you didn't know this was an AI, would you think it was a real person?**

[ ] Yes, completely  
[ ] Yes, mostly  
[ ] Maybe, 50/50  
[ ] No, feels robotic  
[ ] No, obviously AI  

---

## 🔧 Troubleshooting Issues

### If Reactions Fail:
1. Check accessibility permissions
2. Try manual test: `osascript send_tapback.applescript "+NUM" "like"`
3. Check Messages.app UI hasn't changed
4. Look for error in logs

### If Typing Indicators Fail:
1. Check `ENABLE_TYPING_INDICATOR=true` in .env
2. Verify permissions
3. Try manual test: `osascript show_typing_indicator.applescript "+NUM"`
4. Check timing (may need longer delays)

### If Messages Don't Send:
1. Check bridge is running: `ps aux | grep bridge.py`
2. Check logs: `tail -f bridge.log`
3. Try manual: `osascript imessage_send.applescript "+NUM" "test"`
4. Verify Messages.app is logged in

---

## 📋 Test Results Summary

**Date Tested:** _______________  
**Tester:** _______________  
**iPhone Model:** _______________  
**macOS Version:** _______________

**Tests Passed:** _____ / 20  
**Critical Issues:** _______________  
**Minor Issues:** _______________  

**Overall Status:**
[ ] ✅ Production Ready  
[ ] ⚠️ Needs Minor Fixes  
[ ] ❌ Needs Major Fixes  

**Notes:**
```
[Add any observations, issues, or feedback here]




```

---

**Testing complete!** Share results for review and any necessary fixes.

