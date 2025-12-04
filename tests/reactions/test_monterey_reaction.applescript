tell application "Messages"
	activate
	delay 2
	set targetService to 1st service whose service type = iMessage
	set targetBuddy to buddy "+18176067157" of targetService
end tell

delay 2

tell application "System Events"
	tell process "Messages"
		set frontmost to true
		delay 1
		
		try
			-- In Monterey, the structure might be different
			-- Let's try to find transcript area (common in Monterey)
			set win to window 1
			log "Window: " & (name of win)
			
			-- Try to find scrollable area with different terminology
			try
				-- Look for any UI element with role description containing "transcript" or "chat"
				set allElements to entire contents of win
				log "Total UI elements: " & (count of allElements)
				
				repeat with elem in allElements
					try
						set elemRole to role of elem
						if elemRole is "AXStaticText" then
							log "Found static text: " & (value of elem)
						else if elemRole is "AXGroup" then
							try
								-- Check if this group has actionable elements
								set actions to actions of elem
								if (count of actions) > 0 then
									log "Found actionable group with " & (count of actions) & " actions"
									repeat with act in actions
										log "  Action: " & (description of act)
									end repeat
									
									-- Try to show menu on this element
									if description of (item 1 of actions) contains "menu" or description of (item 1 of actions) contains "Menu" then
										log "Trying to show menu on this element..."
										perform action "AXShowMenu" of elem
										delay 1
										
										-- Try to click Like
										try
											keystroke "l"
											delay 0.5
											keystroke return
											return "SUCCESS: Reaction sent!"
										end try
									end if
								end if
							end try
						end if
					end try
				end repeat
			on error errMsg
				log "Detailed search error: " & errMsg
			end try
			
			-- Monterey-specific: Try to use UI element at specific index
			try
				log "Trying indexed access to groups..."
				set mainGroup to group 1 of win
				set innerGroup to group 1 of mainGroup
				
				-- Try to get the last message by searching backwards
				set allSubElements to UI elements of innerGroup
				log "Inner group has " & (count of allSubElements) & " elements"
				
				if (count of allSubElements) > 0 then
					set lastElement to last item of allSubElements
					log "Last element role: " & (role of lastElement)
					
					-- Try to perform action on it
					perform action "AXShowMenu" of lastElement
					delay 1
					keystroke "l"
					delay 0.3
					keystroke return
					return "SUCCESS: Used keyboard method!"
				end if
			on error indexErr
				log "Index error: " & indexErr
			end try
			
			error "Could not find messages to react to"
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

