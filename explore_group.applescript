tell application "Messages"
	activate
	delay 2
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
			
			-- Get the first group (the only one we found)
			set mainGroup to group 1 of win
			log "Main group found"
			
			-- Get its contents
			set groupElements to UI elements of mainGroup
			log "Group has " & (count of groupElements) & " elements"
			
			-- Explore each element in the group
			repeat with i from 1 to count of groupElements
				try
					set elem to item i of groupElements
					set elemRole to role of elem
					set elemDesc to description of elem
					log "Element " & i & ": role=" & elemRole & ", desc=" & elemDesc
					
					-- If it's a group, go deeper
					if elemRole is "AXGroup" then
						try
							set subElements to UI elements of elem
							log "  Sub-group has " & (count of subElements) & " elements"
							
							repeat with j from 1 to count of subElements
								try
									set subElem to item j of subElements
									set subRole to role of subElem
									set subDesc to description of subElem
									log "    Sub-element " & j & ": role=" & subRole & ", desc=" & subDesc
									
									-- Go even deeper if needed
									if subRole is "AXGroup" or subRole is "AXScrollArea" then
										try
											set deepElements to UI elements of subElem
											log "      Deep level has " & (count of deepElements) & " elements"
											
											repeat with k from 1 to (count of deepElements)
												try
													set deepElem to item k of deepElements
													set deepRole to role of deepElem
													log "        Deep element " & k & ": role=" & deepRole
												end try
											end repeat
										end try
									end if
								end try
							end repeat
						end try
					end if
				end try
			end repeat
			
		on error errMsg
			log "Error: " & errMsg
		end try
	end tell
end tell



