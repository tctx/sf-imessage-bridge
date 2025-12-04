-- Get coordinates of the last message bubble
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
			click window 1
			delay 0.5
			
			set win to window 1
			set mainGroup to group 1 of win
			set innerGroup to group 1 of mainGroup
			set allSubElements to UI elements of innerGroup
			
			if (count of allSubElements) > 0 then
				set lastElement to last item of allSubElements
				
				-- Get position and size
				try
					set bubblePosition to position of lastElement
					set bubbleSize to size of lastElement
					
					set posX to item 1 of bubblePosition
					set posY to item 2 of bubblePosition
					set sizeW to item 1 of bubbleSize
					set sizeH to item 2 of bubbleSize
					
					-- Calculate center
					set centerX to posX + (sizeW / 2)
					set centerY to posY + (sizeH / 2)
					
					log "Bubble position: " & posX & ", " & posY
					log "Bubble size: " & sizeW & " x " & sizeH
					log "Center point: " & centerX & ", " & centerY
					
					return "Position: (" & centerX & ", " & centerY & ")"
					
				on error posErr
					log "Error getting position: " & posErr
					error posErr
				end try
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

