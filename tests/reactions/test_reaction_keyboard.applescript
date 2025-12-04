on run
	tell application "Messages"
		activate
		delay 2
		
		-- Open conversation
		set targetService to 1st service whose service type = iMessage
		set targetBuddy to buddy "+18176067157" of targetService
	end tell
	
	delay 2
	
	tell application "System Events"
		tell process "Messages"
			set frontmost to true
			delay 1
			
			try
				-- Click on the window to ensure it's focused
				set win to window 1
				click win
				delay 0.5
				
				-- Use keyboard shortcut to scroll to bottom (make sure we see the latest message)
				key code 125 using command down -- Cmd+Down arrow
				delay 0.5
				
				-- Click near the bottom of the window where the last message should be
				-- Get window position and size
				set winPosition to position of win
				set winSize to size of win
				
				set winX to item 1 of winPosition
				set winY to item 2 of winPosition
				set winWidth to item 1 of winSize
				set winHeight to item 2 of winSize
				
				-- Click in the middle-bottom area of the conversation
				-- This should be where the last message is
				set clickX to winX + (winWidth / 2)
				set clickY to winY + winHeight - 150 -- 150 pixels from bottom
				
				log "Window position: " & winX & "," & winY
				log "Window size: " & winWidth & "x" & winHeight
				log "Clicking at: " & clickX & "," & clickY
				
				-- Control-click (right click) to open context menu
				do shell script "cliclick c:" & clickX & "," & clickY
				delay 0.3
				
				-- Control-click
				do shell script "cliclick kd:ctrl c:" & clickX & "," & clickY & " ku:ctrl"
				delay 1
				
				-- Now try to click "Like" in the menu
				-- The menu should be visible now
				keystroke "l" -- Type 'l' for Like
				delay 0.5
				
				return "SUCCESS: Attempted to like message via keyboard"
				
			on error errMsg
				log "Error: " & errMsg
				-- Try without cliclick - just use AppleScript clicking
				try
					set win to window 1
					-- Try to use AppleScript's click at position
					tell win
						-- Get the bounds
						set winBounds to get bounds
						set clickX to (item 1 of winBounds) + ((item 3 of winBounds) / 2)
						set clickY to (item 2 of winBounds) + (item 4 of winBounds) - 100
						
						log "Trying alternative click at " & clickX & "," & clickY
					end tell
					
					-- Use System Events to control-click
					tell me to do shell script "/usr/bin/osascript -e 'tell application \"System Events\" to keystroke \"a\" using control down'"
					delay 1
					
					return "Attempted alternative method"
				on error altErr
					return "FAILED: " & altErr
				end try
			end try
		end tell
	end tell
end run

