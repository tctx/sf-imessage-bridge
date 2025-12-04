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
			-- Click window to focus
			click window 1
			delay 0.5
			
			-- Navigate to message elements
			set win to window 1
			set mainGroup to group 1 of win
			set innerGroup to group 1 of mainGroup
			set allSubElements to UI elements of innerGroup
			
			log "Found " & (count of allSubElements) & " elements"
			
			if (count of allSubElements) > 0 then
				set lastElement to last item of allSubElements
				log "Last element role: " & (role of lastElement)
				
				-- Show context menu on the last message
				log "Showing context menu..."
				perform action "AXShowMenu" of lastElement
				delay 1.0
				
				-- Now the menu should be visible
				-- Try to access the menu and click the Like item
				try
					-- The menu should be a child of the last element
					set theMenu to menu 1 of lastElement
					log "Menu found with " & (count of menu items of theMenu) & " items"
					
					-- List menu items to see what's available
					repeat with menuItem in menu items of theMenu
						try
							set itemName to name of menuItem
							log "Menu item: " & itemName
						end try
					end repeat
					
					-- Click the "Like" menu item
					log "Clicking Like menu item..."
					click menu item "Like" of theMenu
					delay 0.5
					
					return "SUCCESS: Clicked Like menu item!"
					
				on error menuErr
					log "Menu error: " & menuErr
					
					-- Alternative: Try to find menu at application level
					try
						log "Trying alternative menu access..."
						set allMenus to every menu of lastElement
						log "Found " & (count of allMenus) & " menus"
						if (count of allMenus) > 0 then
							set theMenu to item 1 of allMenus
							click menu item "Like" of theMenu
							return "SUCCESS: Alternative method worked!"
						end if
					on error altErr
						log "Alternative error: " & altErr
					end try
					
					error "Could not access menu: " & menuErr
				end try
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

