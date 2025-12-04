# Enable Typing Bubbles (... indicator)

## 🎯 The Problem
Your typing indicator script works, but macOS is blocking it:
```
osascript is not allowed to send keystrokes
```

## ✅ Solution: Grant Accessibility Permissions

### Option 1: Grant Permission via Terminal (Quickest)

1. Open **System Preferences** → **Security & Privacy** → **Privacy** tab
2. Click **Accessibility** in the left sidebar
3. Click the **lock icon** at bottom left and enter your password
4. Click the **+** button
5. Navigate to and add these apps:
   - `/usr/bin/osascript`
   - `/Applications/Utilities/Terminal.app` (or whatever terminal you're using)
   - **Cursor** (if you're running commands from Cursor)
6. Make sure the checkboxes next to them are **checked** ✅
7. Click the lock again to save

### Option 2: Let macOS Prompt You

1. Send a test message to trigger the bridge
2. When the typing indicator tries to run, macOS will show a permission dialog
3. Click **Open System Preferences**
4. Grant the requested permissions

---

## 🧪 Test It

After granting permissions, test manually:

```bash
osascript /Users/syntheticfriends/Documents/projects/sf-imessage-bridge/show_typing_indicator.applescript "+18176067157"
```

**Expected behavior:**
- Messages app activates and opens
- You see a brief typing action (space + backspace)
- The recipient sees the "..." typing bubble for ~5 seconds!

---

## 🚀 Restart the Bridge

Once permissions are granted, restart the bridge:

```bash
# Kill current bridge
pkill -9 -f "python3 bridge.py"
rm -f /Users/syntheticfriends/Documents/projects/sf-imessage-bridge/bridge.lock

# Start fresh
cd /Users/syntheticfriends/Documents/projects/sf-imessage-bridge
nohup python3 -u bridge.py > bridge.log 2>&1 &
```

---

## 📝 How It Works

The updated `show_typing_indicator.applescript`:

1. **Activates Messages app** and focuses on the conversation
2. **Simulates typing** a space character (triggers "..." bubble on recipient's phone)
3. **Immediately deletes** the space (backspace)
4. **Result:** Recipient sees "..." typing indicator for 5-10 seconds

This is the **only way** to trigger the typing bubble via AppleScript, as Apple doesn't expose a direct API for it.

---

## ⚠️ Important Notes

- **Messages app will briefly come to foreground** when typing indicator is shown
  - This is unavoidable with this approach
  - The window focus returns immediately after

- **Timing matters:**
  - The backend sends `typing_delay` (e.g., 2.5 seconds)
  - The script shows the bubble, then Python sleeps for that duration
  - After the sleep, the actual message is sent

- **If it still doesn't work:**
  - Make sure Messages app is running
  - Check that the contact exists in your Messages
  - Verify the phone number format: `+18176067157`

---

## 🎉 End Result

When someone texts your SF number:

1. ✅ Bridge receives message
2. ✅ Sends to backend
3. ✅ **Shows "..." typing bubble** (person sees you're typing!)
4. ✅ Waits realistic duration (2-5 seconds)
5. ✅ Sends actual reply

**Now it feels like texting a real human!** 🚀

