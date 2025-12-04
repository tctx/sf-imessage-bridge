-- Test tapback using cliclick (click and hold method)
on run argv
	if (count of argv) is less than 1 then
		set targetNumber to "+18176067157"
		set reactionType to "like"
	else
		set targetNumber to item 1 of argv
		if (count of argv) > 1 then
			set reactionType to item 2 of argv
		else
			set reactionType to "like"
		end if
	end if
	
	-- Open Messages and conversation
	tell application "Messages"
		activate
		delay 1.5
		set targetService to 1st service whose service type = iMessage
		set targetBuddy to buddy targetNumber of targetService
	end tell
	
	delay 1.5
	
	tell application "System Events"
		tell process "Messages"
			set frontmost to true
			delay 0.8
			
			try
				click window 1
				delay 0.5
				
				-- Find actual message bubbles (not window groups)
				set win to window 1
				set allElements to entire contents of win
				set foundBubbles to {}
				
				repeat with elem in allElements
					try
						if role of elem is "AXGroup" then
							set elemSize to size of elem
							set elemWidth to item 1 of elemSize
							set elemHeight to item 2 of elemSize
							
							-- Message bubble size range
							if elemWidth > 50 and elemWidth < 600 and elemHeight > 20 and elemHeight < 300 then
								set end of foundBubbles to elem
							end if
						end if
					end try
				end repeat
				
				log "Found " & (count of foundBubbles) & " message bubbles"
				
				if (count of foundBubbles) > 0 then
					-- Get the last bubble
					set lastBubble to last item of foundBubbles
					set bubblePos to position of lastBubble
					set bubbleSize to size of lastBubble
					
					set bubbleX to item 1 of bubblePos
					set bubbleY to item 2 of bubblePos
					set bubbleW to item 1 of bubbleSize
					set bubbleH to item 2 of bubbleSize
					
					-- Calculate center
					set centerX to bubbleX + (bubbleW / 2)
					set centerY to bubbleY + (bubbleH / 2)
					
					log "Last bubble center: " & centerX & ", " & centerY
					
					-- Use cliclick to perform long press
					-- Syntax: md:x,y (mouse down) w:duration (wait) mu:. (mouse up at current position)
					log "Performing long press with cliclick..."
					do shell script "/usr/local/bin/cliclick m:" & centerX & "," & centerY & " w:100 md:. w:800 mu:."
					
					delay 1.0
					
					-- The tapback bar should now be visible above the bubble
					-- Reaction icons typically appear in a row above the message
					-- Approximate offsets (may need adjustment):
					-- Like (👍): -80px left, -40px up from center
					-- Love (❤️): -50px left, -40px up
					-- Haha (😂): -20px left, -40px up
					-- Emphasize (‼️): +10px right, -40px up
					-- Question (❓): +40px right, -40px up
					-- Dislike (👎): +70px right, -40px up
					
					set reactionX to centerX
					set reactionY to centerY - 40
					
					if reactionType is "like" or reactionType is "thumbsup" then
						set reactionX to centerX - 80
					else if reactionType is "love" or reactionType is "heart" then
						set reactionX to centerX - 50
					else if reactionType is "haha" or reactionType is "laugh" then
						set reactionX to centerX - 20
					else if reactionType is "emphasize" or reactionType is "exclamation" then
						set reactionX to centerX + 10
					else if reactionType is "question" then
						set reactionX to centerX + 40
					else if reactionType is "dislike" or reactionType is "thumbsdown" then
						set reactionX to centerX + 70
					end if
					
					log "Clicking reaction at: " & reactionX & ", " & reactionY
					do shell script "/usr/local/bin/cliclick c:" & reactionX & "," & reactionY
					
					delay 0.5
					
					return "reaction_sent:" & reactionType
					
				else
					error "No message bubbles found"
				end if
				
			on error errMsg
				log "Error: " & errMsg
				error errMsg
			end try
		end tell
	end tell
end run


