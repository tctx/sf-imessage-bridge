# Synthetic Friends Bridge - Management Commands

## Check Status

```bash
# Check if bridge is running
launchctl list | grep imessage-bridge

# Check if ngrok is running
launchctl list | grep ngrok

# Check both at once
launchctl list | grep -E "(imessage-bridge|ngrok)"
```

## View Logs

```bash
# Bridge logs (main service)
tail -f ~/Documents/projects/sf-imessage-bridge/logs/bridge.stdout.log
tail -f ~/Documents/projects/sf-imessage-bridge/logs/bridge.stderr.log

# ngrok logs
tail -f ~/Documents/projects/sf-imessage-bridge/logs/ngrok.stdout.log
tail -f ~/Documents/projects/sf-imessage-bridge/logs/ngrok.stderr.log

# View all logs at once
tail -f ~/Documents/projects/sf-imessage-bridge/logs/*.log
```

## Stop Services

```bash
# Stop bridge
launchctl stop com.sf.imessage-bridge

# Stop ngrok
launchctl stop com.sf.ngrok

# Stop both
launchctl stop com.sf.imessage-bridge && launchctl stop com.sf.ngrok
```

## Restart Services

```bash
# Restart bridge
launchctl stop com.sf.imessage-bridge && launchctl start com.sf.imessage-bridge

# Restart ngrok
launchctl stop com.sf.ngrok && launchctl start com.sf.ngrok

# Restart both (recommended after power outage)
launchctl stop com.sf.imessage-bridge && launchctl stop com.sf.ngrok && \
launchctl start com.sf.imessage-bridge && launchctl start com.sf.ngrok
```

## Verify Everything is Working

```bash
# Check processes are running
ps aux | grep -E "(bridge.py|ngrok)" | grep -v grep

# Test bridge HTTP server (port 3001)
curl http://localhost:3001/health

# Get ngrok public URL
curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; data = json.load(sys.stdin); tunnels = data.get('tunnels', []); [print(f\"Public URL: {t.get('public_url', 'N/A')}\") for t in tunnels]"
```

## Uninstall Services

```bash
# Unload and remove bridge
launchctl unload ~/Library/LaunchAgents/com.sf.imessage-bridge.plist
rm ~/Library/LaunchAgents/com.sf.imessage-bridge.plist

# Unload and remove ngrok
launchctl unload ~/Library/LaunchAgents/com.sf.ngrok.plist
rm ~/Library/LaunchAgents/com.sf.ngrok.plist

# Remove both
launchctl unload ~/Library/LaunchAgents/com.sf.imessage-bridge.plist && \
launchctl unload ~/Library/LaunchAgents/com.sf.ngrok.plist && \
rm ~/Library/LaunchAgents/com.sf.imessage-bridge.plist && \
rm ~/Library/LaunchAgents/com.sf.ngrok.plist
```

## Quick Status Check

```bash
# One-liner to check everything
echo "Bridge:" && launchctl list | grep imessage-bridge && \
echo "ngrok:" && launchctl list | grep ngrok && \
echo "Port 3001:" && lsof -i :3001 | grep LISTEN && \
echo "HTTP Health:" && curl -s http://localhost:3001/health
```

