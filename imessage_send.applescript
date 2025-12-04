on run argv
	if (count of argv) is less than 2 then
		error "Usage: osascript imessage_send.applescript \"+1XXXXXXXXXX\" \"Message text\" [effect]"
	end if
	
	set targetNumber to item 1 of argv
	set msgText to item 2 of argv
	
	-- Optional effect parameter (for future extensibility)
	-- Note: macOS Messages.app doesn't support screen effects via AppleScript
	-- This parameter is here for API compatibility if Apple adds support in the future
	set messageEffect to "none"
	if (count of argv) is greater than 2 then
		set messageEffect to item 3 of argv
	end if
	
	tell application "Messages"
		try
			set targetService to 1st service whose service type = iMessage
			set targetBuddy to buddy targetNumber of targetService
			send msgText to targetBuddy
			return "sent"
		on error errMsg
			error "Failed to send message: " & errMsg
		end try
	end tell
end run
