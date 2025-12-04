#!/bin/bash
# Quick script to open the bridge monitor dashboard

DASHBOARD_URL="http://localhost:8766/dashboard.html"

# Check if monitor server is running
if ! lsof -i :8766 >/dev/null 2>&1; then
    echo "⚠️  Monitor API server is not running"
    echo "Starting monitor server..."
    python3 "$(dirname "$0")/monitor_api_server.py" &
    sleep 2
fi

# Open dashboard in default browser
echo "🌐 Opening dashboard: $DASHBOARD_URL"
open "$DASHBOARD_URL"

echo ""
echo "✅ Dashboard should be opening in your browser"
echo "📊 Keep this window open for 24/7 monitoring"

