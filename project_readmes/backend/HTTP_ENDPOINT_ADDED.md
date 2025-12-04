# 🔌 HTTP Endpoint Added to Bridge

## What Changed?

**MINIMAL changes - only ~70 lines added to bridge.py!**

### New Features:
1. **HTTP Server on port 3001** - Runs in background thread
2. **POST /send** endpoint - Receives proactive messages from Railway
3. **GET /health** endpoint - Health checks

### What's UNCHANGED:
✅ **100% of existing functionality preserved**
- Main polling loop - identical
- Message processing - identical  
- Typing indicators - identical
- Reactions - identical
- Demo flow - works exactly the same!

## Why This Matters

### Before:
- Railway could only respond to incoming messages
- Receipts/demo links had to wait for next user message
- No way to send proactive messages

### After:
- Railway can POST to `http://your-mac:3001/send` to send messages immediately
- Perfect for: receipts, demo completion messages, demo links
- Bridge continues polling AND listening for HTTP requests

## API Usage

### Send Proactive Message

```bash
curl -X POST http://localhost:3001/send \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+15555551234",
    "messages": [
      "Here's your receipt! 🧾",
      "https://demo.syntheticfriends.ai/abc123"
    ]
  }'
```

### Health Check

```bash
curl http://localhost:3001/health
# Returns: {"status":"ok","service":"bridge_send_server"}
```

## Testing

Start the bridge normally:
```bash
python3 bridge.py
```

You'll see:
```
[STARTUP] HTTP send server started in background (port 3001)
[HTTP] Starting send server on http://0.0.0.0:3001
Starting bridge. Watching for new messages after ROWID 12345...
```

Test the endpoint:
```bash
curl -X POST http://localhost:3001/send \
  -H "Content-Type: application/json" \
  -d '{"to": "+15555551234", "messages": ["Test receipt"]}'
```

## Dependencies Added

- `fastapi` - Modern web framework
- `uvicorn` - ASGI server
- `pydantic` - Data validation

Already installed via: `pip install fastapi uvicorn pydantic`

## Expose via ngrok (for Railway)

Since Railway is remote and your Mac is local, expose the endpoint:

```bash
# Install ngrok
brew install ngrok

# Expose port 3001
ngrok http 3001
```

Give Railway the ngrok URL (e.g., `https://abc123.ngrok.io/send`)

## Safety

- HTTP server runs in daemon thread (won't block shutdown)
- If HTTP server fails, bridge continues normally
- All logging maintained
- No impact on existing message flow
