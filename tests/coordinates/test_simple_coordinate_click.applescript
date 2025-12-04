-- Simple test: Get last bubble coordinates and try double-clicking it
tell application "Messages"
	activate
	delay 1.5
	set targetService to 1st service whose service type = iMessage
	set targetBuddy to buddy "+18176067157" of targetService
end tell

delay 1.5

tell application "System Events"
	tell process "Messages"
		set frontmost to true
		delay 0.8
		
		try
			set win to window 1
			
			-- Get all elements and find message bubbles
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
			
			log "Found " & (count of foundBubbles) & " potential bubbles"
			
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
				
				log "Last bubble at: " & centerX & ", " & centerY
				
				-- Try control-clicking it (right-click)
				log "Control-clicking the bubble..."
				
				-- Control-click the bubble to open context menu
				-- Use keystroke instead since click with modifiers has syntax issues
				click lastBubble
				delay 0.2
				
				-- Use the AXShowMenu action instead
				perform action "AXShowMenu" of lastBubble
				delay 1.0
				
				-- The menu should be visible now - try pressing down arrows and return
				log "Navigating menu with keyboard..."
				key code 125 -- Down
				delay 0.2
				key code 36 -- Return
				delay 0.5
				
				return "SUCCESS: Clicked bubble and navigated menu"
			else
				error "No bubbles found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

