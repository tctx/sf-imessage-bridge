#!/usr/bin/env python3
"""
Test clicking and holding on a message bubble to trigger tapback menu
"""
import subprocess
import time

# Coordinates of the last message bubble (from our discovery)
# Using the last one we found: (671, 886)
bubble_x = 671 + (591 / 2)  # Center X
bubble_y = 886 + (27 / 2)   # Center Y

print(f"Target coordinates: ({bubble_x}, {bubble_y})")

# First, activate Messages and open the conversation
print("Opening Messages...")
subprocess.run([
    "osascript", "-e",
    '''
    tell application "Messages"
        activate
        delay 1.5
        set targetService to 1st service whose service type = iMessage
        set targetBuddy to buddy "+18176067157" of targetService
    end tell
    delay 1
    '''
])

# Now simulate a long press using AppleScript and CGEvent
# We'll use a shell script that uses CGEventCreateMouseEvent
print("Simulating long press...")

applescript = f'''
tell application "System Events"
    -- Move to position
    do shell script "osascript -e 'tell application \\"System Events\\" to set the position of mouse to {{{int(bubble_x)}, {int(bubble_y)}}}'"
    delay 0.3
    
    -- Mouse down (start of long press)
    do shell script "osascript -e 'tell application \\"System Events\\" to key down 256'" -- This is a hack, let's try click down
end tell

-- Alternative: Use Python's Quartz to do proper mouse events
do shell script "python3 -c 'import Quartz; import time; event = Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseDown, ({int(bubble_x)}, {int(bubble_y)}), Quartz.kCGMouseButtonLeft); Quartz.CGEventPost(Quartz.kCGHIDEventTap, event); time.sleep(1.0); event = Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseUp, ({int(bubble_x)}, {int(bubble_y)}), Quartz.kCGMouseButtonLeft); Quartz.CGEventPost(Quartz.kCGHIDEventTap, event)'"
'''

try:
    result = subprocess.run(["osascript", "-e", applescript], capture_output=True, text=True, timeout=10)
    print(f"Result: {result.stdout}")
    if result.stderr:
        print(f"Errors: {result.stderr}")
    
    # Wait a moment for the tapback menu to appear
    time.sleep(1.5)
    
    # If tapback menu appeared, click the Like icon
    # Usually appears above the bubble, let's try 50 pixels up
    like_x = bubble_x - 100  # Offset left
    like_y = bubble_y - 50   # Offset up
    
    print(f"Clicking Like at ({like_x}, {like_y})...")
    subprocess.run([
        "osascript", "-e",
        f'''do shell script "python3 -c 'import Quartz; event = Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseDown, ({int(like_x)}, {int(like_y)}), Quartz.kCGMouseButtonLeft); Quartz.CGEventPost(Quartz.kCGHIDEventTap, event); event = Quartz.CGEventCreateMouseEvent(None, Quartz.kCGEventLeftMouseUp, ({int(like_x)}, {int(like_y)}), Quartz.kCGMouseButtonLeft); Quartz.CGEventPost(Quartz.kCGHIDEventTap, event)'"'''
    ])
    
    print("Test complete!")
    
except Exception as e:
    print(f"Error: {e}")

