# 📨 Testing Message Sending - Verification Guide

This guide helps you verify that messages are actually being sent from the bridge to iMessage.

---

## 🎯 Quick Test (1 minute)

**The fastest way to test:**

```bash
./test_send.sh +YOUR_PHONE_NUMBER
```

This will:
1. Send a test message directly
2. Test typing indicators
3. Test full flow with timing
4. Send multiple messages in sequence

**Check your iPhone** - you should receive all test messages!

---

## 🔄 Echo Mode Test (Best for Verification)

**Test without backend** - messages echo back automatically:

```bash
# Echo ALL incoming messages
python3 test_echo_mode.py

# Echo only from specific number
python3 test_echo_mode.py +18176067157
```

**How it works:**
1. You send: "Hello"
2. Bridge echoes back: "Echo: Hello (received at 14:30:25)"

**Why this is useful:**
- ✅ Bypasses backend completely
- ✅ Proves bridge can send messages
- ✅ Shows typing indicators
- ✅ Tests realistic timing
- ✅ Easy to verify on iPhone

**To test:**
1. Start echo mode: `python3 test_echo_mode.py +YOUR_NUMBER`
2. Send a message from your iPhone to your SF number
3. You should see the echo response with typing bubbles!

Press Ctrl+C to stop echo mode.

---

## 📊 What to Look For in Logs

### ✅ Successful Send (New Enhanced Logging)

```
[OUT] To +18176067157: Test message
[SEND] ✅ AppleScript returned: 'sent'
[OUT] ✅ Message #1 delivered
```

**This means:** Message was successfully sent via AppleScript!

### ❌ Failed Send

```
[OUT] To +18176067157: Test message
[SEND] ❌ Message send FAILED to +18176067157
[SEND]    Exit code: 1
[SEND]    Error: execution error: Messages got an error: Can't get buddy...
[SEND] 💡 Tip: Check that Messages.app is running and logged into iCloud
[ERROR] ⚠️ Message #1 FAILED to send!
```

**This means:** Message failed - check error details above.

### ⏱️ Timeout

```
[OUT] To +18176067157: Test message
[SEND] ❌ Message send TIMED OUT to +18176067157 after 10 seconds
[SEND] 💡 Tip: Check if Messages.app is responding
[ERROR] ⚠️ Message #1 FAILED to send!
```

**This means:** Messages.app is not responding.

---

## 🧪 Test Scenarios

### Test 1: Direct AppleScript Call

```bash
osascript imessage_send.applescript "+18176067157" "Direct test message"
```

**Expected:**
- Exit code 0
- Returns "sent"
- Message appears on your iPhone

**If this fails:** AppleScript isn't working - check Messages.app is logged in.

---

### Test 2: Full Test Suite

```bash
./test_send.sh +18176067157
```

**Tests:**
1. ✅ Direct message send
2. ✅ Typing indicator
3. ✅ Typing + message combined
4. ✅ Multiple messages in sequence

**Expected:** 4+ messages on your iPhone with typing bubbles.

---

### Test 3: Echo Mode (No Backend)

```bash
python3 test_echo_mode.py +18176067157
```

**Steps:**
1. Script starts monitoring
2. Send "test" from iPhone to SF number
3. See in terminal:
   ```
   [IN] +18176067157: test
   [TYPE] Showing typing indicator...
   [TYPE] Typing for 2.1s...
   [OUT] Sending: Echo: test (received at 14:30:25)
   [✅] Message sent successfully!
   ```
4. Check iPhone - echo message appears!

**Expected:** Every message you send gets echoed back.

---

### Test 4: Bridge Logs (With Backend)

```bash
# Watch logs in real-time
tail -f bridge.log | grep -E "\[OUT\]|\[SEND\]|\[ERROR\]"
```

**Send message from iPhone, look for:**

```
[OUT] To +18176067157: Response message
[SEND] ✅ Message sent successfully
[OUT] ✅ Message #1 delivered
```

**Good signs:**
- ✅ `[SEND] ✅ Message sent successfully`
- ✅ `[OUT] ✅ Message #X delivered`

**Bad signs:**
- ❌ `[SEND] ❌ Message send FAILED`
- ❌ `[ERROR] ⚠️ Message #X FAILED to send!`

---

## 🔍 Verification Checklist

### ✅ Messages Are Sending If:

- [ ] Test messages arrive on your iPhone
- [ ] Logs show `[SEND] ✅ Message sent successfully`
- [ ] Logs show `[OUT] ✅ Message #X delivered`
- [ ] Echo mode echoes your messages back
- [ ] Messages appear in Messages.app on Mac
- [ ] No error messages in logs

### ❌ Messages Are NOT Sending If:

- [ ] Test messages don't arrive on iPhone
- [ ] Logs show `[SEND] ❌ Message send FAILED`
- [ ] Logs show `[ERROR] ⚠️ Message #X FAILED`
- [ ] Echo mode doesn't respond
- [ ] Timeout errors in logs

---

## 🐛 Common Issues & Solutions

### Issue 1: "Can't get buddy"

**Error:**
```
execution error: Messages got an error: Can't get buddy "+18176067157"
```

**Solutions:**
1. **Check phone number format** - Must include country code: `+18176067157`
2. **Start a conversation first** - Send yourself a message from that number
3. **Check Messages.app** - Make sure it's open and logged into iCloud

---

### Issue 2: Messages Not Arriving

**Possible causes:**

1. **Messages.app not logged in**
   ```bash
   # Check in Messages.app: Preferences → iMessage → Signed in?
   ```

2. **Phone number format wrong**
   ```bash
   # Good: +18176067157
   # Bad: 817-606-7157, 8176067157
   ```

3. **Conversation doesn't exist**
   ```bash
   # Solution: Send yourself a message from that number first
   ```

4. **AppleScript file missing/wrong**
   ```bash
   ls -la imessage_send.applescript
   # Should exist and be readable
   ```

---

### Issue 3: Timeout Errors

**Error:**
```
[SEND] ❌ Message send TIMED OUT
```

**Solutions:**
1. **Restart Messages.app**
   ```bash
   killall Messages
   open -a Messages
   ```

2. **Check Mac resources**
   ```bash
   top -l 1 | grep "CPU usage"
   # If CPU is maxed, close some apps
   ```

3. **Restart bridge** with fresh start
   ```bash
   ./setup_and_restart.sh
   ```

---

## 📈 Success Metrics

### What "Working" Looks Like:

**Test Send:**
```bash
$ ./test_send.sh +18176067157

1️⃣  Testing direct AppleScript send...
✅ AppleScript call succeeded (took 1s)

2️⃣  Testing typing indicator...
✅ Typing indicator succeeded (took 3s)

3️⃣  Testing full flow...
✅ Full flow completed

4️⃣  Testing multiple messages...
✅ Multi-message test complete
```

**Echo Mode:**
```bash
$ python3 test_echo_mode.py +18176067157

[IN] +18176067157: test
[TYPE] Showing typing indicator...
[TYPE] Typing for 1.8s...
[OUT] Sending: Echo: test (received at 14:30:25)
[✅] Message sent successfully!
```

**Bridge Logs:**
```
[IN] +18176067157: Hello
[TYPE] ✅ Typing indicator shown successfully!
[OUT] To +18176067157: Hi there! How can I help?
[SEND] ✅ Message sent successfully
[OUT] ✅ Message #1 delivered
[SUCCESS] Processed message ID 123
```

**iPhone:**
- ✅ All test messages received
- ✅ Typing bubbles appear before messages
- ✅ Timing feels natural
- ✅ Messages appear in correct conversation

---

## 🎯 Quick Diagnostic Commands

```bash
# Check if bridge is running
ps aux | grep bridge.py

# Check recent send attempts
grep "\[SEND\]" bridge.log | tail -10

# Check for send errors
grep "SEND.*❌" bridge.log

# Check send success rate
echo "Success: $(grep -c 'SEND.*✅' bridge.log)"
echo "Failed: $(grep -c 'SEND.*❌' bridge.log)"

# Test direct send
osascript imessage_send.applescript "+18176067157" "Test $(date +%H:%M:%S)"

# Full test suite
./test_send.sh +18176067157

# Echo mode (no backend needed)
python3 test_echo_mode.py +18176067157
```

---

## 💡 Pro Tips

1. **Test with echo mode first** - Proves sending works without backend complexity
2. **Check both Mac and iPhone** - Message should appear in both places
3. **Watch logs in real-time** - `tail -f bridge.log` shows exactly what's happening
4. **Use test_send.sh** - Comprehensive test in one command
5. **Verify phone number format** - Always include country code with +

---

## ✅ Verification Summary

**After running tests, you should see:**

| Test | Expected Result |
|------|----------------|
| Direct AppleScript | ✅ Message on iPhone |
| Test Suite | ✅ 4+ messages on iPhone |
| Echo Mode | ✅ Messages echo back |
| Bridge Logs | ✅ `[SEND] ✅` entries |
| iPhone Messages | ✅ All messages received |
| Typing Indicators | ✅ "..." bubbles visible |

**If ALL tests pass:** 🎉 Message sending is working perfectly!

**If ANY test fails:** Check the error messages and solutions above, or run:
```bash
./diagnose.sh
```

---

## 🆘 Still Not Working?

1. **Run diagnostics:**
   ```bash
   ./diagnose.sh
   ```

2. **Try echo mode:**
   ```bash
   python3 test_echo_mode.py +YOUR_NUMBER
   ```

3. **Check Messages.app:**
   - Is it running?
   - Are you logged into iCloud?
   - Can you manually send messages?

4. **Restart everything:**
   ```bash
   ./setup_and_restart.sh
   ```

5. **Check logs for specifics:**
   ```bash
   grep "ERROR\|FAILED\|❌" bridge.log
   ```

The new enhanced logging will tell you EXACTLY what's failing!

