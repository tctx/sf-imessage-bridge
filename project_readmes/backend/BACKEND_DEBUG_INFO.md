# Backend Debug Information - 401 Unauthorized Error

## Problem Summary

The bridge is receiving **401 Unauthorized** errors from the backend, even though:
- ✅ The API key is correct: `Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8`
- ✅ The endpoint works when tested with `curl` (returns 200 OK)
- ✅ The bridge is sending requests with the correct format

## What the Bridge Sends

**Request Details:**
- **URL:** `https://synthetic-friends-production.up.railway.app/ingest`
- **Method:** `POST`
- **Headers:**
  - `X-API-Key: Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8`
  - `Content-Type: application/json`
- **Payload:**
```jsonA
{
  "from": "+16824439658",
  "text": "test message",
  "channel": "imessage",A
  "metadata": {
    "source": "mac_bridge",
    "message_id": 12345,
    "received_at": "2025-11-13T20:18:38.892380Z"
  }
}
```

## What Works vs What Doesn't

**✅ Works (curl test):**
```bash
curl -X POST "https://synthetic-friends-production.up.railway.app/ingest" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8" \
  -d '{"from": "+16824439658", "text": "test message", "channel": "imessage"}'
```
**Response:** 200 OK with valid JSON response

**❌ Doesn't Work (bridge):**
- Bridge sends the same request format
- Backend returns: `401 Client Error: Unauthorized`
- Error occurs at: `r.raise_for_status()` in bridge.py line 397

## What to Test on Backend

### 1. Check API Key Header Name
- **Test:** Verify the backend is looking for `X-API-Key` (case-sensitive)
- **Possible issues:**
  - Backend might expect `x-api-key` (lowercase)
  - Backend might expect `Authorization: Bearer <key>`
  - Backend might expect a different header name entirely

### 2. Check API Key Value
- **Test:** Log the exact API key value received by the backend
- **Check for:**
  - Leading/trailing whitespace
  - Encoding issues
  - Case sensitivity
  - The exact string: `Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8`

### 3. Check Request Format Differences
- **Test:** Compare what curl sends vs what bridge sends
- **Differences to check:**
  - `metadata` field (bridge includes it, curl test didn't)
  - HTTP/2 vs HTTP/1.1 (curl used HTTP/2, bridge might use HTTP/1.1)
  - User-Agent header
  - Other headers that might affect authentication

### 4. Test with Exact Bridge Payload
**Use this exact curl command to simulate the bridge:**
```bash
curl -X POST "https://synthetic-friends-production.up.railway.app/ingest" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8" \
  -d '{
    "from": "+16824439658",
    "text": "test message",
    "channel": "imessage",
    "metadata": {
      "source": "mac_bridge",
      "message_id": 12345,
      "received_at": "2025-11-13T20:18:38.892380Z"
    }
  }'
```

### 5. Backend Logging
**Add logging to see what the backend receives:**
```python
# Log the incoming request
print(f"Received X-API-Key header: {request.headers.get('X-API-Key')}")
print(f"Expected API key: Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8")
print(f"Keys match: {request.headers.get('X-API-Key') == 'Nl9V_YUORxCW6qGdgGnwoLg1piXbOxhEsoOZFjVeZy8'}")
print(f"All headers: {dict(request.headers)}")
```

## Expected Behavior

When the bridge sends a request:
1. Backend should authenticate using `X-API-Key` header
2. Backend should return 200 OK with response:
```json
{
  "target": "+16824439658",
  "messages": [
    {
      "text": "Response text",
      "typing_delay": 5.0,
      "delay_before": 0.8
    }
  ],
  "reaction": null
}
```

## Current Behavior

- Backend returns: `401 Unauthorized`
- Bridge catches the error and logs it
- Bridge does NOT send any error message to the user
- The "technical snag" message is coming from the backend (not the bridge)

## Questions for Backend Team

1. **What header name does the backend expect for the API key?**
   - Is it `X-API-Key`? (case-sensitive?)
   - Or something else?

2. **Is the API key validation case-sensitive?**
   - Does it need exact match including case?

3. **Does the `metadata` field cause any issues?**
   - Should it be ignored or validated?

4. **Are there any other headers required for authentication?**
   - User-Agent?
   - Origin?
   - Others?

5. **What's the exact error message the backend returns?**
   - The bridge logs show: `401 Client Error: Unauthorized`
   - But what's the response body? (bridge tries to log it but might be empty)

## Debugging Steps

1. **Add request logging on backend** to see exactly what it receives
2. **Compare curl request vs bridge request** side-by-side
3. **Test with the exact bridge payload** (including metadata)
4. **Check if HTTP version matters** (HTTP/1.1 vs HTTP/2)
5. **Verify API key validation logic** handles the exact key format

