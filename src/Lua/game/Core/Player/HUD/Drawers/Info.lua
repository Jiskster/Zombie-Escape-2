local function getTimeString()
	local game = ZE2.Game
	
	if not multiplayer then
		return "DEMO!"
	end
	
	return G_TicsToMTIME(game.state_tics)
end

local function roundinfo(v,p,me,ze)
	local game = ZE2.Game
	local top = v.cachePatch("Z_TOP")
	local topwidth = top.width
	local topred = v.cachePatch("Z_TOP_RED")
	local topredwidth = topred.width
	local topblue = v.cachePatch("Z_TOP_BLUE")
	local topbluewidth = topblue.width
	local topzomb = v.cachePatch("Z_TOP_ZOMB")
	local timestring = getTimeString()
	local zombie_count = ZE2.CountPlayers("zombies")
	local survivor_count = ZE2.CountPlayers("survivors")

	local spread = 40

	v.draw(160-(topwidth/2), 0, top, V_SNAPTOTOP|V_20TRANS)
	v.drawString(160, 2, timestring, V_SNAPTOTOP, "center")
	
	if game.releasetime then
		v.draw(160-(topwidth/2), 12, topzomb, V_SNAPTOTOP)
		v.drawString(160, 15, game.releasetime/TICRATE, V_ORANGEMAP|V_SNAPTOTOP, "thin-center")
	end

	if multiplayer then
		v.draw(160-(topredwidth/2) -spread, 0, topred , V_SNAPTOTOP|V_20TRANS) -- Zombie BG
		v.draw(160-(topbluewidth/2) +spread, 0, topblue, V_SNAPTOTOP|V_20TRANS) -- Survivor BG
		
		v.drawString(160-spread, 2, zombie_count, V_REDMAP|V_SNAPTOTOP, "center") -- Zombies Alive
		v.drawString(160+spread, 2, survivor_count, V_BLUEMAP|V_SNAPTOTOP, "center") -- Survivors Alive
	end
end

local function cashinfo(v,p,me,ze)
	local green = v.cachePatch("Z_TOP_GREEN")
	local greenwidth = green.width
	if ze.cash ~= nil then
		local left_offset = 2

		v.draw(320-greenwidth, 0, green, V_SNAPTOTOP|V_SNAPTORIGHT|V_20TRANS)
		v.drawString(320-left_offset, 2, "$"..ze.cash, V_GREENMAP|V_SNAPTOTOP|V_SNAPTORIGHT, "thin-right")
	end
end

local function eventtimers(v,p,me,ze)
	local x = 5
	local y = 12
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP

	if ze.checkpoint_catchuptics then
		local catchup_tics = ze.checkpoint_catchuptics

		customhud.CustomFontString(v, 160, 142, "Catching up in:", "TNYFC",
		(V_SNAPTOBOTTOM|V_50TRANS), "center", nil, SKINCOLOR_CHERRY)

		customhud.CustomFontString(v, 160, 150, tostring(catchup_tics/TICRATE), "TNYFC",
		(V_SNAPTOBOTTOM|V_50TRANS), "center" , nil, SKINCOLOR_CHERRY)
	end

	for i,timer in ipairs(ZE2:GetActiveTimers()) do
		local name = "* " .. (timer.text or ("Event " .. i))
		local time = "  " .. G_TicsToMTIME(timer.time) .. ""
		local color = timer.textcolor or SKINCOLOR_TEAL

		customhud.CustomFontString(v, x, y, name, "TNYFC",
			flags, "left" , nil, color
		)
		customhud.CustomFontString(v, x, y + 8, time, "TNYFC",
			flags, "left" , nil, SKINCOLOR_WHITE
		)

		y = $ + 16
	end
end

local function wrapper(v,p)
	local game = ZE2.Game
	
	if game.ended then return end
	if not p.realmo then return end

	local me = p.realmo
	local ze = p.ze2

	roundinfo(v,p,me,ze)
	cashinfo(v,p,me,ze)
	eventtimers(v,p,me,ze)
end

return "GameInfo", wrapper
