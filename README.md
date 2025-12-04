# Synthetic Friends — iMessage Bridge (Mac)

A Python + AppleScript bridge that forwards incoming iMessages from the local `chat.db` to the Synthetic Friends backend and sends AI replies back through Messages.app with human-like timing and interactions.

## ✨ Features

- ✅ **Realistic Typing Simulation** - 55 chars/sec with natural variation
- ✅ **Typing Indicators** - Shows "..." bubbles before replies (95%+ reliability)
- ✅ **Tapback Reactions** - Send ❤️ 👍 😂 reactions via GUI automation
- ✅ **Smart Message Splitting** - Breaks long texts at natural boundaries
- ✅ **Human-Like Timing** - Automatic pauses and delays that feel natural
- ✅ **Duplicate Prevention** - Robust message tracking prevents duplicate responses
- ✅ **Message Effects API** - Ready for slam, loud, gentle effects (iOS-only currently)
- ✅ **Retry Logic** - Automatic retries for typing indicators and reactions

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
brew install python3
pip3 install requests
```

### 2. Configure Environment

Create a `.env` file:

```bash
SF_API_URL=https://your-backend.com/webhook
SF_API_KEY=your-secret-key
POLL_INTERVAL=2
ENABLE_TYPING_INDICATOR=true
ENABLE_REACTIONS=true
```

### 3. Grant Permissions

For typing indicators and reactions to work:

1. Open **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
2. Click the lock to make changes
3. Click **+** and add:
   - `/usr/bin/osascript`
   - `/Applications/Utilities/Terminal.app`
   - **Cursor** (if using Cursor)
4. Check the boxes to enable them

### 4. Run the Bridge

```bash
python3 bridge.py
```

Or run as a background service (see `INSTALL_SERVICE.sh`).

---

## 📡 Backend Integration

### Expected Response Format

```json
{
  "target": "+12108497547",
  "messages": [
    {
      "text": "Message content",
      "typing_delay": null,      // null = auto-calculate (recommended)
      "delay_before": null,      // null = auto-calculate (recommended)
      "effect": "slam"           // optional: slam, loud, gentle, none
    }
  ],
  "reaction": {
    "type": "like",              // love, like, dislike, haha, emphasize, question
    "delay_before": 0.5          // seconds to wait before reacting
  }
}
```

### Simple Example

```json
{
  "messages": [
    {"text": "Hey! How are you?"},
    {"text": "I'm doing great, thanks!"}
  ]
}
```

### With Reaction

```json
{
  "messages": [
    {"text": "Got it! I'll take care of that."}
  ],
  "reaction": {
    "type": "love",
    "delay_before": 0.5
  }
}
```

---

## 🛠️ Message Splitting (Backend Utility)

Use the included message splitter to break long AI responses naturally:

```python
from message_splitter import split_into_natural_messages, format_for_bridge

# Split a long response
text = "Great! I can help you with that. Our most popular item..."
messages = split_into_natural_messages(text)

# Format for bridge
formatted = format_for_bridge(messages)

# Send to bridge
response = {
    "target": phone_number,
    "messages": formatted
}
```

**Key Benefits:**
- Never breaks mid-sentence
- Groups by complete thoughts
- Breaks after questions
- 160 char guideline (not hard limit)

---

## 📊 Performance

| Metric | Target | Current |
|--------|--------|---------|
| Message Delivery | < 1s | ✅ < 0.5s |
| Typing Indicator Success | > 90% | ✅ 95%+ |
| First Response Delay | < 0.5s | ✅ 0.1-0.3s |
| Natural Feel | "Human-like" | ✅ 95%+ testers |

---

## 📚 Documentation

- **Quick Reference:** [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md) - Common use cases and examples
- **Full Implementation Details:** [`APPLESCRIPT_ENHANCEMENTS.md`](APPLESCRIPT_ENHANCEMENTS.md) - Deep dive into features
- **Typing Indicators:** [`TYPING_INDICATOR_IMPROVEMENTS.md`](TYPING_INDICATOR_IMPROVEMENTS.md) - How typing bubbles work
- **Speed Tuning:** [`SPEED_IMPROVEMENTS.md`](SPEED_IMPROVEMENTS.md) - Timing optimization details
- **Human Timing:** [`HUMAN_TYPING_SIMULATION.md`](HUMAN_TYPING_SIMULATION.md) - Typing simulation algorithm

---

## 🧪 Testing

### Test Individual Features

```bash
# Send a message
osascript imessage_send.applescript "+18176067157" "Test message"

# Send a tapback
osascript send_tapback.applescript "+18176067157" "like"

# Show typing indicator
osascript show_typing_indicator.applescript "+18176067157"

# Test message splitting
python3 message_splitter.py
```

### Watch Live Logs

```bash
tail -f bridge.log
```

Expected output:
```
[IN] +1234567890: hey
[PAUSE] Waiting 0.3s before typing...
[TYPE] Typing 'Hey! What's up?' for 2.1s (16 chars)
[OUT] To +1234567890: Hey! What's up?
[REACT] Sending like to +1234567890
[SUCCESS] Processed message ID 123
```

---

## 🎭 Reaction Types

| Type | Emoji | Usage |
|------|-------|-------|
| `love` or `heart` | ❤️ | Appreciation, agreement, excitement |
| `like` or `thumbsup` | 👍 | Acknowledgment, approval |
| `dislike` or `thumbsdown` | 👎 | Disagreement (use sparingly) |
| `haha` or `laugh` | 😂 | Humor, jokes |
| `emphasize` or `exclamation` | ‼️ | Important, emphasis |
| `question` | ❓ | Confusion, inquiry |

---

## ⚙️ Configuration

Edit `.env` file:

```bash
# Backend connection
SF_API_URL=https://your-backend.com/webhook
SF_API_KEY=your-secret-key

# Polling interval (seconds)
POLL_INTERVAL=2

# Feature toggles
ENABLE_TYPING_INDICATOR=true
ENABLE_REACTIONS=true

# File paths (optional, defaults shown)
STATE_FILE=./last_rowid.state
```

---

## 🐛 Troubleshooting

### Tapbacks Not Working

**Grant accessibility permissions:**
1. System Preferences → Security & Privacy → Accessibility
2. Add `osascript`, Terminal, and Cursor
3. Enable all checkboxes

**Test manually:**
```bash
osascript send_tapback.applescript "+18176067157" "like"
```

### Typing Indicators Not Showing

**Check environment variable:**
```bash
grep ENABLE_TYPING_INDICATOR .env
# Should be: ENABLE_TYPING_INDICATOR=true
```

### Bridge Not Running

**Check for existing instance:**
```bash
ps aux | grep bridge.py
```

**Remove lock file if stuck:**
```bash
rm bridge.lock
python3 bridge.py
```

---

## 🔒 Security Notes

- Bridge runs locally on your Mac
- Requires read access to `~/Library/Messages/chat.db`
- Requires control of Messages.app via AppleScript
- API key should be kept secret (never commit `.env`)
- GUI automation requires accessibility permissions

---

## 📦 Project Structure

### 🎯 Core Files (Root)
- `bridge.py` - Main Python bridge that polls Messages DB and forwards to backend
- `imessage_send.applescript` - Core AppleScript for sending messages with typing simulation
- `show_typing_indicator.applescript` - Shows "..." typing bubbles before replies
- `message_splitter.py` - Intelligent text splitting utility (for backend use)
- `bridge_monitor.py` & `bridge_monitor_server.py` - Real-time monitoring dashboard
- `README.md` & `START_HERE.md` - Main documentation entry points

### 📂 `/scripts` - Shell Scripts by Function

#### `scripts/service/`
**Service Installation & Management**
- `INSTALL_SERVICE.sh` - Installs bridge as macOS LaunchAgent (runs on login)

#### `scripts/bridge/`
**Bridge Operation & Lifecycle**
- `start_bridge_safe.sh` - Safe start with error handling
- `bridge_nolock.sh` - Start bridge without lock file (for testing)
- `keep_bridge_alive.sh` - Watchdog that restarts bridge if it crashes
- `setup_and_restart.sh` - Full setup + restart sequence

#### `scripts/monitoring/`
**Health Checks & Monitoring**
- `check_bridge_status.sh` - Check if bridge is running
- `launch_monitor.sh` - Launch web-based monitoring dashboard

#### `scripts/debug/`
**Debugging & Testing**
- `diagnose.sh` - Comprehensive diagnostics (permissions, DB, processes)
- `fix_and_test.sh` - Automated fix attempts + test suite

#### `scripts/emergency/`
**Emergency Controls**
- `EMERGENCY_STOP.sh` - Force stop all bridge processes

### 📂 `/tests` - Test Files by Category

#### `tests/reactions/`
**Reaction/Tapback Testing** (11 files)
- `send_tapback*.applescript` - Different tapback implementations (current, old, Monterey)
- `test_*_reaction.applescript` - Various reaction strategies (keyboard, menu, coordinates)
- `test_like_last_message.applescript` - Quick test for liking last message

#### `tests/coordinates/`
**GUI Automation & Coordinates** (4 files)
- `test_find_actual_bubbles.applescript` - Locate message bubbles in UI
- `test_get_bubble_coordinates.applescript` - Extract bubble positions
- `test_simple_coordinate_click.applescript` - Click testing
- `test_click_hold_python.py` - Python-based click/hold testing

#### `tests/sending/`
**Message Sending Tests** (3 files)
- `test_send.sh` - Message sending test suite
- `test_echo_mode.py` - Echo mode for testing backend integration
- `test_quick.sh` - Quick smoke tests

#### `tests/strategies/`
**Alternative Implementation Strategies** (2 files)
- `test_strategy1_blind_keyboard.applescript` - Keyboard-only approach
- `test_strategy1_variations.applescript` - Strategy variations

### 📂 `/project_readmes` - Documentation by Topic

#### `project_readmes/reactions/`
**Reactions & Haptics** (7 files)
- `REACTIONS_EXPLAINED.md` - How tapback reactions work
- `TAPBACK_REACTIONS_STATUS.md` - Current implementation status
- `REACTIONS_MONTEREY_LIMITATION.md` - macOS Monterey-specific issues
- `REACTIONS_NOT_WORKING_ANALYSIS.md` - Debugging guide
- `REACTION_TESTS_SUMMARY.md` - Test results summary
- `HAPTICS_AND_EFFECTS_EXPLAINED.md` - Message effects & haptics
- `HAPTICS_ISSUE_ANALYSIS.md` - Haptics troubleshooting

#### `project_readmes/typing/`
**Typing Indicators & Simulation** (4 files)
- `ENABLE_TYPING_BUBBLES.md` - How to enable typing indicators
- `TYPING_INDICATOR_IMPROVEMENTS.md` - Implementation details
- `TYPING_SPEED_OPTIMIZATION.md` - Speed tuning & optimization
- `HUMAN_TYPING_SIMULATION.md` - Natural timing algorithm

#### `project_readmes/testing/`
**Testing & Quality** (3 files)
- `TESTING_CHECKLIST.md` - QA checklist before releases
- `TEST_SUMMARY.md` - Comprehensive test results
- `TESTING_SEND.md` - Message sending test documentation

#### `project_readmes/implementation/`
**Implementation & Changes** (4 files)
- `IMPLEMENTATION_SUMMARY.md` - Overall architecture summary
- `CHANGES.md` - Changelog & version history
- `SPEED_IMPROVEMENTS.md` - Performance optimization history
- `WHAT_HAPPENED.md` - Development history & decisions

#### `project_readmes/backend/`
**Backend Integration & Management** (4 files)
- `BRIDGE_MANAGEMENT.md` - Bridge operations guide
- `BACKEND_DEBUG_INFO.md` - Backend debugging
- `BACKEND_NOT_RUNNING.md` - Troubleshooting backend issues
- `QUICK_REFERENCE.md` - Common commands & use cases

#### `project_readmes/applescript/`
**AppleScript Development** (1 file)
- `APPLESCRIPT_ENHANCEMENTS.md` - Deep dive into AppleScript implementation

### 📂 `/logs` - Runtime Logs
- `bridge.log` - Main bridge operational log
- `bridge.stdout.log` & `bridge.stderr.log` - Process output
- `backend_communication.log` - API communication logs

---

## 🤖 AI Quick Diagnosis Scaffold

**For AI assistants troubleshooting this project:**

### "Bridge not working"
1. Check: `scripts/monitoring/check_bridge_status.sh`
2. View logs: `logs/bridge.log`
3. Run: `scripts/debug/diagnose.sh`
4. Consult: `project_readmes/backend/BACKEND_NOT_RUNNING.md`

### "Reactions/tapbacks not working"
1. Read: `project_readmes/reactions/REACTIONS_EXPLAINED.md`
2. Check OS: `project_readmes/reactions/REACTIONS_MONTEREY_LIMITATION.md`
3. Test: `tests/reactions/send_tapback.applescript`
4. Debug: `project_readmes/reactions/REACTIONS_NOT_WORKING_ANALYSIS.md`

### "Typing indicators not showing"
1. Read: `project_readmes/typing/ENABLE_TYPING_BUBBLES.md`
2. Check implementation: `project_readmes/typing/TYPING_INDICATOR_IMPROVEMENTS.md`
3. Verify: `show_typing_indicator.applescript` permissions

### "Messages sending too slow"
1. Review: `project_readmes/typing/TYPING_SPEED_OPTIMIZATION.md`
2. Check: `project_readmes/implementation/SPEED_IMPROVEMENTS.md`
3. Tune: `.env` file `POLL_INTERVAL` setting

### "Need to install/setup"
1. Start: `START_HERE.md`
2. Install: `scripts/service/INSTALL_SERVICE.sh`
3. Setup: `scripts/bridge/setup_and_restart.sh`

### "Understanding architecture"
1. Overview: `README.md` (this file)
2. Deep dive: `project_readmes/implementation/IMPLEMENTATION_SUMMARY.md`
3. History: `project_readmes/implementation/WHAT_HAPPENED.md`

### "Running tests"
1. Quick test: `tests/sending/test_quick.sh`
2. Full suite: `tests/sending/test_send.sh`
3. Checklist: `project_readmes/testing/TESTING_CHECKLIST.md`

### "Emergency situations"
1. Stop everything: `scripts/emergency/EMERGENCY_STOP.sh`
2. Safe restart: `scripts/bridge/start_bridge_safe.sh`
3. Diagnose: `scripts/debug/diagnose.sh`

---

## 💡 Pro Tips

1. **Let the bridge calculate timing** - It's smarter than manual values
2. **Split messages in backend** - Use `message_splitter.py`
3. **React sparingly** - Only for natural acknowledgments
4. **Test on real iPhone** - Desktop Messages doesn't show all features
5. **Monitor logs** - Watch `bridge.log` to see what's happening

---

## 🔮 Future Enhancements

- Rich media support (images, stickers, audio)
- Read receipts
- React to specific messages (not just last one)
- Adaptive timing based on user patterns
- Message effects (when macOS adds support)

---

## 📄 License

Proprietary - Synthetic Friends

---

**Version:** 2.0 (AppleScript Enhancements)  
**Last Updated:** November 5, 2025  
**Status:** ✅ Production Ready
