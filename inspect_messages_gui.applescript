tell application "Messages"
	activate
	delay 2
end tell

tell application "System Events"
	tell process "Messages"
		set frontmost to true
		delay 1
		
		try
			set win to window 1
			log "Window name: " & (name of win)
			
			-- Try to get all UI elements
			try
				log "Getting entire UI element tree..."
				set allElements to entire contents of win
				log "Number of elements: " & (count of allElements)
			end try
			
			-- Try different paths
			try
				log "Trying: scroll area 1 of splitter group 1"
				set sa to scroll area 1 of splitter group 1 of win
				log "  Found scroll area"
				try
					set tb to table 1 of sa
					log "  Found table 1 in scroll area"
				on error
					log "  No table in scroll area"
				end try
			on error errMsg
				log "  Error: " & errMsg
			end try
			
			-- Try simpler path
			try
				log "Trying: scroll area 1 directly"
				set sa to scroll area 1 of win
				log "  Found scroll area"
				try
					set tb to table 1 of sa
					log "  Found table 1"
				on error
					log "  No table in scroll area"
				end try
			on error errMsg
				log "  Error: " & errMsg
			end try
			
			-- List all scroll areas
			try
				log "Listing all scroll areas..."
				set scrollAreas to every scroll area of win
				log "  Found " & (count of scrollAreas) & " scroll areas"
			end try
			
			-- List all groups
			try
				log "Listing all groups..."
				set groups to every group of win
				log "  Found " & (count of groups) & " groups"
			end try
			
			-- List splitter groups
			try
				log "Listing splitter groups..."
				set splitters to every splitter group of win
				log "  Found " & (count of splitters) & " splitter groups"
			end try
			
		on error errMsg
			log "Overall error: " & errMsg
		end try
	end tell
end tell



