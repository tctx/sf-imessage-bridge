-- Test different arrow key patterns to find the Like reaction
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
				
				log "TEST 1: Just pressing Return (select first menu item)"
				perform action "AXShowMenu" of lastElement
				delay 1.0
				key code 36 -- Return immediately
				delay 1.5
				
				-- Wait and try again with different pattern
				log "TEST 2: Down once, then Return"
				perform action "AXShowMenu" of lastElement
				delay 1.0
				key code 125 -- Down
				delay 0.3
				key code 36 -- Return
				delay 1.5
				
				-- Try accessing reactions directly
				log "TEST 3: Try accessing tapback row (might be a right-arrow submenu)"
				perform action "AXShowMenu" of lastElement
				delay 1.0
				key code 125 -- Down
				delay 0.2
				key code 125 -- Down again
				delay 0.2
				key code 124 -- Right (might open tapback submenu)
				delay 0.5
				key code 36 -- Return (select first reaction)
				delay 1.5
				
				return "SUCCESS: All test patterns executed"
				
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

