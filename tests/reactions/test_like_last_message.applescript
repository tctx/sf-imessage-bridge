tell application "Messages"
	activate
	delay 2
	
	-- Open conversation with target
	set targetService to 1st service whose service type = iMessage
	set targetBuddy to buddy "+18176067157" of targetService
end tell

delay 1

tell application "System Events"
	tell process "Messages"
		set frontmost to true
		delay 1
		
		try
			set win to window 1
			log "Window: " & (name of win)
			
			-- Get all UI elements and find what we can work with
			log "Exploring window structure..."
			
			-- Try to find groups
			set allGroups to every group of win
			log "Found " & (count of allGroups) & " groups"
			
			-- Look for elements we can interact with
			set allUIElements to UI elements of win
			log "Found " & (count of allUIElements) & " UI elements"
			
			-- Try to find any element containing messages
			-- Usually messages are in a group or scroll area
			repeat with uiElem in allUIElements
				try
					set elemClass to class of uiElem
					set elemRole to role of uiElem
					log "Element: class=" & elemClass & ", role=" & elemRole
					
					-- If it's a group, explore it
					if elemRole is "AXGroup" then
						try
							set subElements to UI elements of uiElem
							log "  Group has " & (count of subElements) & " sub-elements"
							
							-- Look for scroll areas or more groups
							repeat with subElem in subElements
								try
									set subRole to role of subElem
									log "    Sub-element role: " & subRole
									
									-- If we find a scroll area, that might contain messages
									if subRole is "AXScrollArea" then
										log "    Found scroll area!"
										try
											-- Try to find messages in the scroll area
											set scrollContents to UI elements of subElem
											log "      Scroll area has " & (count of scrollContents) & " elements"
											
											-- Look for a table or list
											repeat with scrollElem in scrollContents
												set scrollElemRole to role of scrollElem
												log "        Scroll element role: " & scrollElemRole
												
												if scrollElemRole is "AXTable" or scrollElemRole is "AXList" then
													log "        Found message container!"
													
													-- Get rows/items
													try
														set messageItems to rows of scrollElem
														log "          Found " & (count of messageItems) & " message rows"
														
														if (count of messageItems) > 0 then
															set lastMessage to last item of messageItems
															log "          Attempting to react to last message..."
															
															-- Show context menu
															perform action "AXShowMenu" of lastMessage
															delay 1
															
															-- Try to click "Like"
															try
																click menu item "Like" of menu 1 of lastMessage
																delay 0.5
																log "SUCCESS: Clicked Like!"
																return "success"
															on error likeErr
																log "Error clicking Like: " & likeErr
															end try
														end if
													on error rowErr
														log "          Error getting rows: " & rowErr
													end try
												end if
											end repeat
										end try
									end if
								end try
							end repeat
						end try
					end if
				end try
			end repeat
			
			error "Could not find message structure"
			
		on error errMsg
			log "Error: " & errMsg
			error errMsg
		end try
	end tell
end tell


