# Synthetic Friends Bridge - Management Guide

**⚠️ CRITICAL: This server must ALWAYS be running. Never stop it unless absolutely necessary. The LaunchAgent will auto-restart if it crashes.**

---

## ✅ Check if Bridge is Running

```bash
# Quick check - should show the service
launchctl list | grep imessage-bridge

# Detailed status (shows PID and exit status)
launchctl list com.sf.imessage-bridge

# Check if bridge process is actually running
pgrep -f "python3.*bridge.py"

# Verify only ONE instance is running (should return 1)
pgrep -f "bridge.py" | wc -l
```

**Expected output:**
- `launchctl list` should show `com.sf.imessage-bridge`
- `pgrep` should return exactly ONE PID
- Exit status should be `0` (or no exit status if running)

---

## 📊 View Live Logs

```bash
# Standard output (normal operation logs)
tail -f ~/Documents/projects/sf-imessage-bridge/bridge.stdout.log

# Error logs (crashes, errors, warnings)
tail -f ~/Documents/projects/sf-imessage-bridge/bridge.stderr.log

# Combined log file (if using manual start)
tail -f ~/Documents/projects/sf-imessage-bridge/bridge.log

# View last 20 lines of each
tail -20 ~/Documents/projects/sf-imessage-bridge/bridge.stdout.log
tail -20 ~/Documents/projects/sf-imessage-bridge/bridge.stderr.log
```

---

## 🔄 Restart the Service

**⚠️ WARNING: Only restart if necessary. The service will auto-restart on crashes.**

```bash
# Restart (stops and starts immediately)
launchctl stop com.sf.imessage-bridge && launchctl start com.sf.imessage-bridge

# Reload configuration and restart (if you changed the plist)
launchctl unload ~/Library/LaunchAgents/com.sf.imessage-bridge.plist
launchctl load ~/Library/LaunchAgents/com.sf.imessage-bridge.plist
launchctl start com.sf.imessage-bridge

# Verify it restarted successfully
sleep 3 && pgrep -f "python3.*bridge.py" && echo "✅ Running" || echo "❌ Not running"
```

---

## 🚨 Emergency Stop (ONLY IF ABSOLUTELY NECESSARY)

**⚠️ CRITICAL WARNING: Do NOT stop unless you have a critical reason. The bridge must stay running.**

```bash
# Stop the LaunchAgent (it will try to restart due to KeepAlive)
launchctl stop com.sf.imessage-bridge

# Force stop and prevent auto-restart (emergency only)
launchctl unload ~/Library/LaunchAgents/com.sf.imessage-bridge.plist

# Kill any running bridge processes (if LaunchAgent doesn't stop them)
pkill -f "python.*bridge.py"

# Remove stale lock file (if needed)
rm ~/Documents/projects/sf-imessage-bridge/bridge.lock
```

**To restart after emergency stop:**
```bash
launchctl load ~/Library/LaunchAgents/com.sf.imessage-bridge.plist
launchctl start com.sf.imessage-bridge
```

---

## 🔍 Verify Bridge Status

```bash
# Complete status check
cd ~/Documents/projects/sf-imessage-bridge

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BRIDGE STATUS CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check LaunchAgent
echo "LaunchAgent status:"
launchctl list com.sf.imessage-bridge | grep -E "LastExitStatus|PID"

# Check running processes
INSTANCE_COUNT=$(pgrep -f "bridge.py" | wc -l | tr -d ' ')
echo ""
echo "Number of bridge instances: $INSTANCE_COUNT"

if [ "$INSTANCE_COUNT" -eq 1 ]; then
    echo "✅ Only ONE instance running (CORRECT)"
    pgrep -f "bridge.py" | xargs ps -p
elif [ "$INSTANCE_COUNT" -eq 0 ]; then
    echo "❌ No instances running - BRIDGE IS DOWN!"
    echo "Restart with: launchctl start com.sf.imessage-bridge"
else
    echo "⚠️  Multiple instances running ($INSTANCE_COUNT) - PROBLEM!"
    echo "Kill duplicates with: pkill -f 'bridge.py' && launchctl start com.sf.imessage-bridge"
fi

echo ""
echo "Recent errors:"
tail -3 bridge.stderr.log 2>/dev/null || echo "No errors"
```

---

## 🛠️ Troubleshooting

### Bridge Not Running

```bash
# 1. Check LaunchAgent status
launchctl list com.sf.imessage-bridge

# 2. Check for errors
tail -20 ~/Documents/projects/sf-imessage-bridge/bridge.stderr.log

# 3. Check if lock file is blocking
ls -l ~/Documents/projects/sf-imessage-bridge/bridge.lock
lsof ~/Documents/projects/sf-imessage-bridge/bridge.lock

# 4. Remove stale lock and restart
rm ~/Documents/projects/sf-imessage-bridge/bridge.lock
launchctl stop com.sf.imessage-bridge && launchctl start com.sf.imessage-bridge
```

### Multiple Instances Running

```bash
# Find all instances
ps aux | grep "bridge.py" | grep -v grep

# Kill all and let LaunchAgent restart (will create only one)
pkill -f "bridge.py"
sleep 2
launchctl start com.sf.imessage-bridge

# Verify only one is running
pgrep -f "bridge.py" | wc -l
```

### Permission Errors

```bash
# Check if /usr/bin/python3 has Full Disk Access
# System Preferences → Security & Privacy → Privacy → Full Disk Access
# Make sure /usr/bin/python3 is checked

# Also ensure Terminal has Full Disk Access
```

### Backend Connection Issues

```bash
# Check .env configuration
cat ~/Documents/projects/sf-imessage-bridge/.env | grep SF_API_URL

# Test backend connection
curl -X POST https://synthetic-friends-production.up.railway.app/ingest \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_KEY" \
  -d '{"test":"connection"}'
```

---

## 📋 Quick Reference

| Action | Command |
|--------|---------|
| **Check status** | `launchctl list \| grep imessage-bridge` |
| **View logs** | `tail -f ~/Documents/projects/sf-imessage-bridge/bridge.stdout.log` |
| **Restart** | `launchctl stop com.sf.imessage-bridge && launchctl start com.sf.imessage-bridge` |
| **Check instances** | `pgrep -f "bridge.py" \| wc -l` |
| **Emergency stop** | `launchctl unload ~/Library/LaunchAgents/com.sf.imessage-bridge.plist` |
| **Start after stop** | `launchctl load ~/Library/LaunchAgents/com.sf.imessage-bridge.plist && launchctl start com.sf.imessage-bridge` |

---

## ⚙️ Auto-Restart Configuration

The LaunchAgent is configured with:
- **KeepAlive: true** - Automatically restarts if the bridge crashes
- **RunAtLoad: true** - Starts automatically on login/boot
- **ThrottleInterval: 10** - Waits 10 seconds between restart attempts

**The bridge will automatically restart if it crashes. You should rarely need to manually restart it.**

---

## 🚫 What NOT to Do

- ❌ **Don't stop the service** unless absolutely necessary
- ❌ **Don't run multiple instances** manually
- ❌ **Don't delete the plist file** unless uninstalling
- ❌ **Don't modify the plist** without understanding the changes
- ❌ **Don't kill processes** unless troubleshooting multiple instances

---

## ✅ What TO Do

- ✅ **Check status regularly** to ensure it's running
- ✅ **Monitor logs** for errors or issues
- ✅ **Restart only when necessary** (after config changes, etc.)
- ✅ **Verify only one instance** is running
- ✅ **Let auto-restart handle crashes** - the LaunchAgent will restart it automatically

---

**Remember: The bridge must ALWAYS be running. The LaunchAgent will keep it alive automatically.**

