on run argv
	if (count of argv) is not 2 then
		error "Usage: osascript send_tapback.applescript \"+1XXXXXXXXXX\" \"like|love|dislike|haha|emphasize|question\""
	end if
	
	set targetNumber to item 1 of argv
	set reactionType to item 2 of argv
	
	try
		-- Activate Messages and ensure conversation exists
		tell application "Messages"
			activate
			delay 1.5  -- Give Messages time to fully activate
			
			-- Ensure conversation exists (this may open the conversation window)
			set targetService to 1st service whose service type = iMessage
			set targetBuddy to buddy targetNumber of targetService
		end tell
		
		-- Give Messages time to open the conversation window if needed
		delay 1.2
		
		-- Use System Events for GUI automation
		tell application "System Events"
			tell process "Messages"
				set frontmost to true
				delay 0.5
				
				-- Wait for windows to appear and retry if needed
				set windowCount to 0
				repeat 5 times
					try
						set windowCount to count of windows
						if windowCount > 0 then exit repeat
					end try
					delay 0.5
				end repeat
				
				if windowCount is 0 then
					error "No Messages windows found after waiting. Make sure Messages.app has a conversation window open."
				end if
				
				-- Try to find the most recent message bubble to react to
				try
					-- Click the window to ensure it's focused and open conversation
					try
						click (first window)
						delay 0.5
					end try
					
					-- Access the message table - use first window with error handling
					set targetWindow to missing value
					try
						set targetWindow to window 1
					on error
						-- If window 1 fails, try to find any window
						if windowCount > 0 then
							set targetWindow to first window
						else
							error "Could not access Messages window"
						end if
					end try
					
					-- Try to find the message table structure
					-- The structure may vary, so we'll try a few different paths
					set messageRows to {}
					
					try
						-- Try the standard path first
						set messageRows to rows of table 1 of scroll area 1 of splitter group 1 of targetWindow
					on error
						-- If that fails, try alternative paths
						try
							set messageRows to rows of table 1 of scroll area 1 of targetWindow
						on error
							-- Last resort: try to find any table in the window
							set messageRows to rows of table 1 of targetWindow
						end try
					end try
					
					if (count of messageRows) is 0 then
						error "No messages found in conversation. Make sure there are messages in the conversation."
					end if
					
					-- Get the last message (most recent) - this should be from the other person
					set lastMessage to last item of messageRows
					
					-- Control-click to open context menu
					perform action "AXShowMenu" of lastMessage
					delay 0.5  -- Give menu time to appear
					
					-- Map reaction type to menu item
					set reactionMenuItem to ""
					if reactionType is "love" or reactionType is "heart" then
						set reactionMenuItem to "Love"
					else if reactionType is "like" or reactionType is "thumbsup" then
						set reactionMenuItem to "Like"
					else if reactionType is "dislike" or reactionType is "thumbsdown" then
						set reactionMenuItem to "Dislike"
					else if reactionType is "haha" or reactionType is "laugh" then
						set reactionMenuItem to "Haha"
					else if reactionType is "emphasize" or reactionType is "exclamation" then
						set reactionMenuItem to "!!"
					else if reactionType is "question" then
						set reactionMenuItem to "?"
					else
						error "Unknown reaction type: " & reactionType
					end if
					
					-- Click the reaction in the context menu
					click menu item reactionMenuItem of menu 1 of lastMessage
					delay 0.3
					
					return "reaction_sent:" & reactionType
					
				on error errMsg
					-- If GUI automation fails, log and return error
					log "Tapback GUI automation failed: " & errMsg
					error "Could not send tapback via GUI: " & errMsg
				end try
			end tell
		end tell
		
	on error errMsg
		log "Tapback error: " & errMsg
		error errMsg
	end try
end run
