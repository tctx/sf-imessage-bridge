on run argv
	if (count of argv) is not 1 then
		error "Usage: osascript show_typing_indicator.applescript \"+1XXXXXXXXXX\""
	end if
	
	set targetNumber to item 1 of argv
	
	try
		-----------------------------------------------
		-- 0. Activate Messages and open that chat
		-----------------------------------------------
		tell application "Messages"
			activate
			-- use imessage: URL scheme to jump into the right convo
			open location ("imessage:" & targetNumber)
		end tell
		
		-- give macOS a moment to open/switch the window
		delay 0.6
		
		-----------------------------------------------
		-- 1. Fake typing in that conversation
		-----------------------------------------------
		tell application "System Events"
			tell process "Messages"
				set frontmost to true
				delay 0.15
				
				-- make sure we're in the chat's text field
				-- clicking window 1 is usually enough once open location has run
				try
					click window 1
					delay 0.1
				end try
				
				-- clear any existing draft
				keystroke "a" using {command down}
				delay 0.05
				key code 51 -- delete
				delay 0.05
				
				-- type some characters to trigger the typing indicator
				keystroke "a"
				delay 0.08
				keystroke "b"
				delay 0.08
				keystroke "c"
				delay 0.08
				
				-- pause here if you want the bubble to "type" longer
				delay 1.0
				
				-- delete the characters
				key code 51
				delay 0.04
				key code 51
				delay 0.04
				key code 51
			end tell
		end tell
		
		return "ok"
		
	on error errMsg
		log "Typing indicator error: " & errMsg
		error errMsg
	end try
end run
