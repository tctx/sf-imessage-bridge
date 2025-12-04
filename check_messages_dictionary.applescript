-- Check what Messages app can do
tell application "Messages"
	-- Get recent messages
	try
		set recentChats to chats
		if (count of recentChats) > 0 then
			set firstChat to item 1 of recentChats
			log "Chat found: " & (id of firstChat)
			
			-- Get messages from this chat
			set chatMessages to every message of firstChat
			log "Messages in chat: " & (count of chatMessages)
			
			if (count of chatMessages) > 0 then
				set lastMsg to last item of chatMessages
				log "Last message ID: " & (id of lastMsg)
				log "Last message text: " & (text of lastMsg)
				
				-- Try to see what properties/actions are available
				try
					log "Message properties: " & (properties of lastMsg)
				end try
			end if
		end if
	on error errMsg
		log "Error: " & errMsg
	end try
end tell

