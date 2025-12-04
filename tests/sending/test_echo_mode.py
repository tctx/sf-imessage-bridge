#!/usr/bin/env python3
"""
Echo Mode Test - Bypass backend and echo messages back

This script monitors incoming messages and immediately echoes them back
without calling the backend. Useful for testing message sending.

Usage:
    python3 test_echo_mode.py [phone_number]
    
If phone_number is provided, only echoes messages from that number.
"""

import os, time, sqlite3, subprocess, sys
from pathlib import Path
from datetime import datetime

# Setup
HOME = str(Path.home())
CHAT_DB = f"{HOME}/Library/Messages/chat.db"
BRIDGE_DIR = Path(__file__).parent
ASCRIPT = str(BRIDGE_DIR / "imessage_send.applescript")
ASCRIPT_TYPING = str(BRIDGE_DIR / "show_typing_indicator.applescript")
STATE_FILE = "test_echo.state"

# Optional: filter by specific phone number
FILTER_NUMBER = sys.argv[1] if len(sys.argv) > 1 else None

def read_last():
    try:
        return int(open(STATE_FILE).read().strip())
    except:
        return 0

def write_last(v):
    with open(STATE_FILE, "w") as f:
        f.write(str(v))

def open_ro(path):
    return sqlite3.connect(f"file:{path}?mode=ro", uri=True)

def send_imessage(target: str, text: str):
    """Send message using AppleScript."""
    result = subprocess.run(
        ["osascript", ASCRIPT, target, text],
        capture_output=True,
        text=True,
        timeout=10
    )
    return result.returncode == 0

def show_typing_indicator(target: str):
    """Show typing indicator."""
    try:
        subprocess.run(
            ["osascript", ASCRIPT_TYPING, target],
            capture_output=True,
            timeout=10,
            check=False  # Don't fail if this doesn't work
        )
    except:
        pass

SQL = (
    "SELECT message.ROWID, message.text, "
    "coalesce(handle.uncanonicalized_id, handle.id) AS sender "
    "FROM message "
    "LEFT JOIN handle ON handle.ROWID = message.handle_id "
    "WHERE message.is_from_me = 0 "
    "AND message.text IS NOT NULL "
    "AND message.service = 'iMessage' "
    "AND message.ROWID > ? "
    "ORDER BY message.ROWID ASC LIMIT 10;"
)

print("🔄 Echo Mode Test - Message Send Verification")
print("=" * 60)
print(f"Monitoring: {CHAT_DB}")
if FILTER_NUMBER:
    print(f"Filter: Only echoing messages from {FILTER_NUMBER}")
else:
    print("Filter: Echoing ALL incoming iMessages")
print("")
print("This will echo back any message you send, like:")
print("  You: 'Hello'")
print("  Echo: 'Echo: Hello (received at 14:30:25)'")
print("")
print("Press Ctrl+C to stop")
print("=" * 60)
print("")

last = read_last()
processed = set()

try:
    while True:
        try:
            with open_ro(CHAT_DB) as conn:
                c = conn.cursor()
                c.execute(SQL, (last,))
                rows = c.fetchall()
        except Exception as e:
            print(f"[DB ERROR] {e}")
            time.sleep(2)
            continue

        for row in rows:
            rid, text, sender = row
            last = rid
            
            if not text or not sender:
                continue
            
            # Skip if already processed
            if rid in processed:
                continue
            
            processed.add(rid)
            
            # Filter by number if specified
            if FILTER_NUMBER and sender != FILTER_NUMBER:
                print(f"[SKIP] {sender}: {text[:40]}... (not {FILTER_NUMBER})")
                write_last(last)
                continue
            
            # Log incoming
            timestamp = datetime.now().strftime("%H:%M:%S")
            print(f"[IN] {sender}: {text}")
            print(f"     Received at {timestamp}")
            
            # Prepare echo response
            echo_text = f"Echo: {text} (received at {timestamp})"
            
            try:
                # Show typing indicator
                print(f"[TYPE] Showing typing indicator...")
                show_typing_indicator(sender)
                
                # Simulate realistic typing time
                char_count = len(echo_text)
                typing_delay = max(1.5, min(4.0, char_count / 55))
                print(f"[TYPE] Typing for {typing_delay:.1f}s...")
                time.sleep(typing_delay)
                
                # Send echo
                print(f"[OUT] Sending: {echo_text}")
                success = send_imessage(sender, echo_text)
                
                if success:
                    print(f"[✅] Message sent successfully!")
                else:
                    print(f"[❌] Message send FAILED!")
                    print(f"[❌] Check that Messages.app is running and logged in")
                
            except Exception as e:
                print(f"[ERROR] Failed to send: {e}")
            
            print("")
            write_last(last)

        time.sleep(2)  # Poll every 2 seconds

except KeyboardInterrupt:
    print("")
    print("=" * 60)
    print("Echo mode stopped")
    print(f"Processed {len(processed)} messages")
    print("=" * 60)
    
    # Clean up state file
    if os.path.exists(STATE_FILE):
        os.remove(STATE_FILE)
        print("Cleaned up state file")

