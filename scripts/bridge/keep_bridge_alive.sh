#!/bin/bash
# Keep bridge alive - automatically restarts if it crashes

cd "$(dirname "$0")"

echo "🚀 Starting bridge with auto-restart..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    # Remove stale lock file if no process is using it
    if [ -f bridge.lock ]; then
        if ! lsof bridge.lock >/dev/null 2>&1; then
            rm -f bridge.lock
        fi
    fi
    
    # Start bridge
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting bridge..."
    python3 bridge.py
    
    EXIT_CODE=$?
    echo ""
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bridge exited with code $EXIT_CODE"
    echo "Restarting in 5 seconds... (Press Ctrl+C to stop)"
    sleep 5
done

