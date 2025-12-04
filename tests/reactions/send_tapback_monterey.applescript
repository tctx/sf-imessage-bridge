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
			delay 1.5
			
			set targetService to 1st service whose service type = iMessage
			set targetBuddy to buddy targetNumber of targetService
		end tell
		
		delay 1.2
		
		-- Use System Events with keyboard-based approach (works on Monterey)
		tell application "System Events"
			tell process "Messages"
				set frontmost to true
				delay 0.5
				
				-- Click the window to ensure focus
				try
					click window 1
					delay 0.5
				end try
				
				-- Navigate to the inner group that contains messages
				try
					set win to window 1
					set mainGroup to group 1 of win
					set innerGroup to group 1 of mainGroup
					set allSubElements to UI elements of innerGroup
					
					if (count of allSubElements) > 0 then
						set lastElement to last item of allSubElements
						
						-- Show context menu on the last message
						perform action "AXShowMenu" of lastElement
						delay 0.8
						
						-- Map reaction type to keyboard shortcut
						-- The menu items respond to first letter presses
						if reactionType is "love" or reactionType is "heart" then
							keystroke "l" -- Love
							delay 0.2
							-- Press 'o' to distinguish from 'Like'
							keystroke "o"
						else if reactionType is "like" or reactionType is "thumbsup" then
							keystroke "l" -- Like
						else if reactionType is "dislike" or reactionType is "thumbsdown" then
							keystroke "d" -- Dislike
						else if reactionType is "haha" or reactionType is "laugh" then
							keystroke "h" -- Haha
						else if reactionType is "emphasize" or reactionType is "exclamation" then
							keystroke "!" -- Emphasize (!! menu item)
						else if reactionType is "question" then
							keystroke "?" -- Question
						else
							error "Unknown reaction type: " & reactionType
						end if
						
						delay 0.3
						keystroke return
						delay 0.3
						
						return "reaction_sent:" & reactionType
					else
						error "No message elements found in conversation"
					end if
					
				on error errMsg
					log "Keyboard method error: " & errMsg
					error "Could not send tapback via keyboard: " & errMsg
				end try
			end tell
		end tell
		
	on error errMsg
		log "Tapback error: " & errMsg
		error errMsg
	end try
end run

