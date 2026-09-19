function ZE2.DoTeamChat(player, text, team)
	if not text or not team then return end
	if (team < 1) or (team > 2) then return end

	local hexcolor = (team == 1) and "\x84" or "\x85"
	local prefixrole = ""
	if IsPlayerAdmin(player) then
		prefixrole = "\x82" .. "@" .. hexcolor
	end

	if (player == server) then
		prefixrole = "\x82" .. "~" .. hexcolor
	end

	if (isserver or isdedicatedserver) and ZE2.cv_server_showteamchat.value then
		local teamname = (team == 1) and "[TEAMCHAT: SURVIVORS]" or "[TEAMCHAT: ZOMBIES]"
		chatprint(hexcolor .. teamname .. "<" .. prefixrole .. player.name .. "> " .. text, true)
	end

	for tplayer in players.iterate do
		if tplayer.spectator then continue end
		if tplayer == server and ZE2.cv_server_showteamchat.value then continue end
		if not (tplayer.mo and tplayer.mo.valid) then continue end

		if tplayer.mo.team == team then
			chatprintf(tplayer, hexcolor .. "[T]<" .. prefixrole .. player.name .. "> " .. text, true)
		end
	end
end

addHook("PlayerMsg", function(source, msgtype, target, msg)
	if not source.ze2 then return end -- how?

	if (msg:sub(1,3) == "/tc") and (msg:len() == 3) then
		source.ze2.teamchat_enabled = not source.ze2.teamchat_enabled

		local teamchatiswhat = source.ze2.teamchat_enabled and "Enabled" or "Disabled"
		chatprintf(source, "\x89" .. "Team Chat is " .. teamchatiswhat)
		return true
	elseif (msg:sub(1,4) == "/tc ") and (msg:len() > 4) and not source.ze2.teamchat_enabled then
		ZE2.DoTeamChat(source, msg:gsub("/tc ", ""), source.mo.team)
		return true
	end

	if source.ze2.teamchat_enabled then
		ZE2.DoTeamChat(source, msg, source.mo.team)
		return true
	end
end)