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
				-- Get the window
				set win to window 1
				log "Window name: " & (name of win)
				
				-- Try to get all static text elements (message text)
				set allText to every static text of win
				log "Found " & (count of allText) & " static text elements"
				
				if (count of allText) > 0 then
					-- Try the last static text (should be the last message)
					set lastText to last item of allText
					set textValue to value of lastText
					log "Last text: " & textValue
					
					-- Try to right-click it
					log "Attempting to right-click last message..."
					perform action "AXShowMenu" of lastText
					delay 1
					
					-- Try to click "Like" in the menu
					try
						log "Looking for menu..."
						set theMenu to menu 1 of lastText
						set menuItems to every menu item of theMenu
						log "Found " & (count of menuItems) & " menu items"
						
						-- Try to find and click "Like"
						repeat with menuItem in menuItems
							try
								set itemName to name of menuItem
								log "Menu item: " & itemName
								if itemName contains "Like" then
									log "Clicking Like!"
									click menuItem
									delay 0.5
									return "SUCCESS: Liked the message!"
								end if
							end try
						end repeat
					on error menuErr
						log "Menu error: " & menuErr
					end try
					
					-- If that didn't work, try clicking menu item directly
					try
						click menu item "Like" of menu 1 of lastText
						return "SUCCESS: Liked via direct click!"
					on error clickErr
						log "Direct click error: " & clickErr
					end try
				else
					log "No static text elements found"
				end if
				
				-- Try alternative: Look for groups that might be message bubbles
				log "Trying to find groups (message bubbles)..."
				set allGroups to every group of win
				log "Found " & (count of allGroups) & " groups"
				
				if (count of allGroups) > 0 then
					-- Try recursively searching for message groups
					repeat with grp in allGroups
						try
							set subGroups to every group of grp
							if (count of subGroups) > 0 then
								log "Found " & (count of subGroups) & " sub-groups"
								set lastGroup to last item of subGroups
								log "Trying to react to last group..."
								perform action "AXShowMenu" of lastGroup
								delay 1
								click menu item "Like" of menu 1 of lastGroup
								return "SUCCESS: Liked via sub-group!"
							end if
						end try
					end repeat
				end if
				
				error "Could not find a way to react to messages"
				
			on error errMsg
				log "Error: " & errMsg
				return "FAILED: " & errMsg
			end try
		end tell
	end tell
end run

