-- Find actual message bubbles (not the window group)
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
			
			-- Search recursively for elements that look like message bubbles
			-- Message bubbles typically have:
			-- - Smaller size (not full window)
			-- - Role of AXGroup
			-- - Might contain static text
			
			log "Searching for message bubble elements..."
			
			set allElements to entire contents of win
			log "Total elements in window: " & (count of allElements)
			
			-- Look for groups that are reasonably sized (likely message bubbles)
			repeat with elem in allElements
				try
					if role of elem is "AXGroup" then
						try
							set elemPos to position of elem
							set elemSize to size of elem
							set elemWidth to item 1 of elemSize
							set elemHeight to item 2 of elemSize
							
							-- Message bubbles are typically:
							-- Width: 50-600 pixels
							-- Height: 30-200 pixels
							if elemWidth > 50 and elemWidth < 600 and elemHeight > 20 and elemHeight < 300 then
								log "Found potential bubble: " & elemWidth & "x" & elemHeight & " at " & item 1 of elemPos & "," & item 2 of elemPos
								
								-- Check if it has text content (indicates it's a message)
								try
									set subElements to UI elements of elem
									if (count of subElements) > 0 then
										log "  Has " & (count of subElements) & " sub-elements"
									end if
								end try
							end if
						end try
					end if
				end try
			end repeat
			
			return "Search complete - check logs"
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

