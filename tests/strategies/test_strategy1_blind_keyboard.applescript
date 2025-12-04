-- Strategy 1: Blind keyboard navigation through context menu
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
			
			-- Get the message element
			set win to window 1
			set mainGroup to group 1 of win
			set innerGroup to group 1 of mainGroup
			set allSubElements to UI elements of innerGroup
			
			if (count of allSubElements) > 0 then
				set lastElement to last item of allSubElements
				
				log "Found last message element"
				
				-- Show context menu using AXShowMenu action
				log "Opening context menu..."
				perform action "AXShowMenu" of lastElement
				delay 1.0 -- CRITICAL: Give the menu time to draw
				
				-- Now navigate blindly with arrow keys
				-- The menu structure is usually:
				-- 1. Copy
				-- 2. [Separator]
				-- 3. Tapback reactions row (or individual reactions)
				-- Let's try different arrow key combinations
				
				log "Attempting blind keyboard navigation..."
				
				-- Try navigating down to reactions
				repeat 2 times
					key code 125 -- Down Arrow
					delay 0.2
				end repeat
				
				delay 0.3
				
				-- Press Return to select
				key code 36 -- Return
				delay 0.5
				
				-- If that opened a submenu or tapback selector, 
				-- we might need to navigate right/left to pick a specific reaction
				-- Try right arrow for "Like" (usually first or second)
				key code 124 -- Right Arrow
				delay 0.3
				key code 36 -- Return
				
				return "SUCCESS: Blind navigation attempted"
				
			else
				error "No message elements found"
			end if
			
		on error errMsg
			return "FAILED: " & errMsg
		end try
	end tell
end tell

