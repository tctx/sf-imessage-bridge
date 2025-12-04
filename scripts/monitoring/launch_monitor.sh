#!/bin/bash
# Launcher for Bridge Monitor (Web-based)
# Uses a simple HTTP server that works on macOS 12.6

cd "$(dirname "$0")"

# Use system Python which works on macOS 12.6
# This server doesn't use tkinter, so it should work fine
exec /usr/bin/python3 bridge_monitor_server.py
