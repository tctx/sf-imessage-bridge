# Bridge Monitor Dashboard

Real-time visual monitoring dashboard for your Synthetic Friends Bridge system.

## Quick Start

### Option 1: Open Dashboard Directly (Simplest)

1. **Start the monitor API server:**
   ```bash
   python3 monitor_api_server.py
   ```

2. **Open in browser:**
   ```
   http://localhost:8766/dashboard.html
   ```

### Option 2: Auto-Start on Boot (Recommended)

1. **Install the Launch Agent:**
   ```bash
   cp com.sf.bridge-monitor.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.sf.bridge-monitor.plist
   launchctl start com.sf.bridge-monitor
   ```

2. **Open in browser:**
   ```
   http://localhost:8766/dashboard.html
   ```

## What It Monitors

- ✅ **Bridge Service** - Main bridge process status
- ✅ **ngrok Tunnel** - Public tunnel status and URL
- ✅ **HTTP Server** - Port 3001 health check

## Features

- **Real-time Updates** - Auto-refreshes every 5 seconds
- **Visual Indicators** - Green = OK, Red = Problem (with pulsing animation)
- **Clear Status** - Shows PID, uptime, and error messages
- **Overall Status** - Big banner at top shows if everything is operational

## Status Colors

- 🟢 **Green** - Service is running normally
- 🔴 **Red** - Service is down or has issues (pulsing animation)
- 🟠 **Orange** - Warning state

## Troubleshooting

### Dashboard shows "Unable to check service"

Make sure the monitor API server is running:
```bash
ps aux | grep monitor_api_server
```

If not running, start it:
```bash
python3 monitor_api_server.py
```

### Services show as down but they're actually running

1. Check if services are actually running:
   ```bash
   launchctl list | grep -E "(imessage-bridge|ngrok)"
   ps aux | grep -E "(bridge.py|ngrok)"
   ```

2. Check monitor server logs:
   ```bash
   tail -f logs/monitor.stderr.log
   ```

## Keep Dashboard Open 24/7

The dashboard is designed to run continuously. Just:
1. Open it in a browser window
2. Keep the browser open
3. The page will auto-refresh every 5 seconds
4. If something goes down, you'll see it immediately with red pulsing indicators

## Manual Refresh

The page auto-refreshes, but you can also:
- Press `F5` or `Cmd+R` to manually refresh
- The page will check services when it becomes visible again (if you switch tabs)

