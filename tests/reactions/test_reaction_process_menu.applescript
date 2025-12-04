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
			
			-- Navigate to message element
			set win to window 1
			set mainGroup to group 1 of win
			set innerGroup to group 1 of mainGroup
			set allSubElements to UI elements of innerGroup
			
			if (count of allSubElements) > 0 then
				set lastElement to last item of allSubElements
				
				-- Show context menu
				log "Showing context menu..."
				perform action "AXShowMenu" of lastElement
				delay 1.2
				
				-- The menu appears at the process level, not on the element
				log "Looking for menus at process level..."
				set allMenus to every menu of process "Messages"
				log "Found " & (count of allMenus) & " menus at process level"
				
				if (count of allMenus) > 0 then
					repeat with aMenu in allMenus
						try
							set menuItems to every menu item of aMenu
							log "Menu has " & (count of menuItems) & " items"
							
							-- List items
							repeat with menuItem in menuItems
								try
									log "  Item: " & (name of menuItem)
								end try
							end repeat
							
							-- Try to click Like
							try
								click menu item "Like" of aMenu
								delay 0.5
								return "SUCCESS: Clicked Like from process menu!"
							on error clickErr
								log "Click error: " & clickErr
							end try
						on error menuErr
							log "Menu iteration error: " & menuErr
						end try
					end repeat
				end if
				
				-- Alternative: Try menu bar menus
				log "Checking menu bars..."
				set allMenuBars to every menu bar of process "Messages"
				log "Found " & (count of allMenuBars) & " menu bars"
				
				error "Could not click menu item"
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

