on run argv
	if (count of argv) is not 1 then
		error "Usage: osascript show_typing_indicator.applescript \"+1XXXXXXXXXX\""
	end if
	
	set targetNumber to item 1 of argv
	
	try
		-- Activate Messages
		tell application "Messages"
			activate
			delay 0.45
			
			-- Get the target buddy to ensure conversation exists
			set targetService to 1st service whose service type = iMessage
			set targetBuddy to buddy targetNumber of targetService
		end tell
		
		-- Give Messages time to fully activate and open conversation window
		-- Critical for first messages in new threads
		delay 0.36
		
		-- Simulate typing to trigger the typing indicator
		tell application "System Events"
			tell process "Messages"
				-- Make sure Messages is frontmost
				set frontmost to true
				delay 0.12
				
				-- Click the window to focus text input field
				-- This is critical for making typing work reliably
				try
					click (first window)
					delay 0.09
				end try
				
				-- Type characters (triggers typing indicator on recipient's device)
				keystroke "a"
				delay 0.045
				keystroke "b"
				delay 0.045
				keystroke "c"
				delay 0.045
				
				-- Delete the characters
				key code 51
				delay 0.03
				key code 51
				delay 0.03
				key code 51
			end tell
		end tell
		
		return "ok"
		
	on error errMsg
		log "Typing indicator error: " & errMsg
		error errMsg
	end try
end run
