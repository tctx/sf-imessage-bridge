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
				delay 1.5
				
				-- The menu should now be visible - try to access it
				log "Looking for menus..."
				set allMenus to every menu
				log "Found " & (count of allMenus) & " menus"
				
				if (count of allMenus) > 0 then
					set contextMenu to item 1 of allMenus
					set menuItems to every menu item of contextMenu
					log "Context menu has " & (count of menuItems) & " items"
					
					-- List menu items
					repeat with menuItem in menuItems
						try
							set itemName to name of menuItem
							log "  Menu item: " & itemName
							
							if itemName is "Like" then
								log "Found Like! Clicking it..."
								click menuItem
								delay 0.5
								return "SUCCESS: Liked the message!"
							end if
						end try
					end repeat
					
					-- If we didn't find "Like" by name, try index
					try
						log "Trying to click first reaction item..."
						click menu item 1 of contextMenu
						return "SUCCESS: Clicked first menu item!"
					end try
				end if
				
				error "Could not find or click menu"
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

