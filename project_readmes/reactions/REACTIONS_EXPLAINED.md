# 💬 Message Reactions (Tapbacks) - How They Work

## Overview

The iMessage bridge supports sending tapback reactions (like ❤️, 👍, 😂, etc.) to messages from users. This makes conversations feel more natural and engaging.

---

## ✅ What Works

### Supported Reaction Types

The bridge supports all standard iMessage tapback reactions:

| Reaction Type | Bridge Parameter | iMessage Display |
|--------------|------------------|------------------|
| ❤️ Love | `love` or `heart` | Red heart |
| 👍 Like | `like` or `thumbsup` | Thumbs up |
| 👎 Dislike | `dislike` or `thumbsdown` | Thumbs down |
| 😂 Haha | `haha` or `laugh` | Laughing face |
| ‼️ Exclamation | `emphasize` or `exclamation` | Double exclamation |
| ❓ Question | `question` | Question mark |

---

## 🔄 How It Works

### 1. Railway Server Response Format

Your Railway server should include a `reaction` object in the response:

```json
{
  "target": "+18176067157",
  "messages": [
    {
      "text": "Got it! I'll have that ready for you.",
      "typing_delay": 2.5,
      "delay_before": 0.8
    }
  ],
  "reaction": {
    "type": "like",
    "delay_before": 0.5
  }
}
```

**Key Points:**
- `reaction.type` - One of: `love`, `like`, `dislike`, `haha`, `emphasize`, `question`
- `reaction.delay_before` - Optional delay (in seconds) before sending the reaction
- If `reaction` is `null` or missing, no reaction is sent

### 2. Bridge Processing Flow

When the bridge receives a response with a reaction:

1. **Bridge receives response** from Railway server
   - Logs: `"has_reaction": true` in backend communication log

2. **Reaction is sent FIRST** (before reply messages)
   - This makes it feel like a quick acknowledgment
   - Code location: `bridge.py` → `handle_structured_response()` → line 660-668

3. **AppleScript automation** (`send_tapback.applescript`)
   - Activates Messages.app
   - Opens the conversation window
   - Finds the most recent message (user's message)
   - Right-clicks to open context menu
   - Clicks the appropriate reaction

4. **Reply messages are sent** after the reaction

### 3. Technical Implementation

**Python Bridge (`bridge.py`):**
```python
# Line 660-668
if response.get('reaction') and ENABLE_REACTIONS:
    reaction = response['reaction']
    delay = reaction.get('delay_before', 0.5)
    if delay > 0:
        time.sleep(delay)
    print(f"[REACT] Sending {reaction['type']} to {target}")
    success = send_tapback(target, reaction['type'])
    if not success:
        print(f"[REACT] ⚠️ Reaction may not have been delivered, continuing with messages...")
```

**AppleScript (`send_tapback.applescript`):**
- Uses GUI automation via System Events
- Requires Messages.app to be running
- Requires Accessibility permissions
- Retries up to 3 times if it fails

---

## 🐛 Troubleshooting

### Issue: Reactions Not Appearing

**Check 1: Is ENABLE_REACTIONS enabled?**
```bash
grep ENABLE_REACTIONS .env
# Should show: ENABLE_REACTIONS=true
```

**Check 2: Are reactions in the Railway response?**
Look in `logs/backend_communication.log` for:
```json
"reaction": {
  "type": "like",
  "delay_before": 0.5
}
```

**Check 3: Are there errors in the logs?**
Look for `[REACT]` messages in `logs/bridge.stdout.log`:
- `[REACT] ✅ like reaction sent successfully!` = Success
- `[REACT] ❌ AppleScript error` = Failure

**Check 4: Messages.app window issues**
The most common error is:
```
Can't get window 1 of process "Messages". Invalid index.
```

**Solution:** The script now:
- Waits longer for Messages to activate (1.5s)
- Waits for conversation window to open (1.2s)
- Checks if windows exist before accessing them
- Clicks the window to focus it
- Retries up to 3 times

**Check 5: Accessibility permissions**
The script needs Accessibility permissions to control Messages.app:
1. System Preferences → Security & Privacy → Privacy → Accessibility
2. Make sure Terminal (or your terminal app) is enabled
3. Make sure osascript has permissions

---

## 📊 Current Status

### ✅ Working
- Railway server can send reactions in response format
- Bridge receives and processes reactions correctly
- AppleScript attempts to send reactions via GUI automation
- Retry logic handles transient failures

### ⚠️ Known Issues
- **Window timing**: If Messages.app window isn't open, reaction may fail
- **Message identification**: Currently reacts to the last message in conversation
  - This should be the user's message (since reaction happens before sending reply)
  - But if user sends multiple messages quickly, might react to wrong one

### 🔧 Recent Fixes (2025-11-19)
- Increased activation delays (1.5s + 1.2s = 2.7s total)
- Added window existence check before accessing
- Added window click to focus conversation
- Added multiple fallback paths for finding message table
- Increased menu appearance delay (0.5s)

---

## 🎯 Best Practices

### When to Use Reactions

**Good moments:**
- Quick acknowledgment: "👍" when user confirms something
- Excitement: "❤️" when user places an order
- Agreement: "👍" when user agrees to something
- Humor: "😂" when user says something funny

**Avoid:**
- Reacting to every message (feels robotic)
- Reacting to questions (send a text reply instead)
- Reacting after long delays (feels disconnected)

### Timing

- **Reaction delay**: 0.3-0.8 seconds feels natural
- **Send reaction FIRST**, then send reply messages
- This makes it feel like a quick acknowledgment before the full response

---

## 📝 Example Railway Response

```json
{
  "target": "+18176067157",
  "messages": [
    {
      "text": "Perfect! I'll have that ready for you in about 5 minutes.",
      "typing_delay": 3.0,
      "delay_before": 1.0
    }
  ],
  "reaction": {
    "type": "like",
    "delay_before": 0.5
  }
}
```

**What happens:**
1. Bridge waits 0.5 seconds
2. Bridge sends 👍 reaction to user's message
3. Bridge waits 1.0 seconds (thinking pause)
4. Bridge shows typing indicator for 3.0 seconds
5. Bridge sends the reply message

---

## 🔍 Debugging

### Check if reactions are being sent

```bash
# Watch the bridge logs in real-time
tail -f logs/bridge.stdout.log | grep REACT

# Check backend communication
tail -f logs/backend_communication.log | grep reaction
```

### Test reaction manually

```bash
# Test sending a like reaction
osascript send_tapback.applescript "+18176067157" "like"
```

### Check recent reaction attempts

```bash
# See last 20 reaction attempts
grep -A 5 "\[REACT\]" logs/bridge.stdout.log | tail -40
```

---

## 📚 Related Files

- `bridge.py` - Main bridge code, handles reaction processing
- `send_tapback.applescript` - AppleScript for GUI automation
- `logs/backend_communication.log` - Logs Railway responses (including reactions)
- `logs/bridge.stdout.log` - Logs bridge processing (including reaction attempts)

---

## ⚠️ Important Notes

1. **Reactions are NOT haptics**: Reactions are visual tapbacks (👍, ❤️, etc.). Haptics (phone vibrations) are iOS-only and cannot be triggered from macOS.

2. **GUI automation limitations**: Reactions require GUI automation, which can be less reliable than direct API calls. The script includes retry logic to handle failures.

3. **Window must be open**: The conversation window must be open in Messages.app for reactions to work. The script tries to open it, but if Messages.app is minimized or closed, it may fail.

4. **Accessibility permissions**: The script needs Accessibility permissions to control Messages.app. Make sure these are enabled in System Preferences.

