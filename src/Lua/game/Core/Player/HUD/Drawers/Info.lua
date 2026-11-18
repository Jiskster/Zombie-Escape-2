local function GetTimeString()
	local game = ZE2.Game
	if not multiplayer then
		return "DEMO!"
	end
	return G_TicsToMTIME(game.state_tics)
end

---@param v videolib
---@param player player_t
---@param mobj mobj_t
---@param ze2 ze2_t
local function RoundInformation(v, player, mobj, ze2)
	local game = ZE2.Game
	local top = v.cachePatch("Z_TOP")
	local topwidth = top.width
	local topzomb = v.cachePatch("Z_TOP_ZOMB")
	local timestring = GetTimeString()
	local zombie_count = ZE2.CountPlayers("zombies")
	local survivor_count = ZE2.CountPlayers("survivors")
	local hud_y = 12
	local spread = 40

	v.drawString(160, hud_y + 1, timestring, V_SNAPTOTOP, "thin-center") -- Time String

	if game.zombie_release_time then
		v.draw(160 - (topwidth / 2), hud_y + 10, topzomb, V_SNAPTOTOP) -- Zombie Release BG
		v.drawString(160, hud_y + 13, game.zombie_release_time / TICRATE, V_ORANGEMAP|V_SNAPTOTOP, "thin-center") -- Zombie Release String
	end

	if not multiplayer then	return end

	v.drawString(160 - spread, hud_y, survivor_count, V_BLUEMAP|V_SNAPTOTOP, "center") -- Survivors Alive (Team 1)
	v.drawString(160 + spread, hud_y, zombie_count, V_REDMAP|V_SNAPTOTOP, "center") -- Zombies Alive (Team 2)
end

---@param v videolib
---@param player player_t
---@param mobj mobj_t
---@param ze2 ze2_t
local function MoneyInformation(v, player, mobj, ze2)
	if (ze2.cash == nil) then return end

	local offset = 2
	v.drawString(320 - offset, 2, "$" .. ze2.cash, V_GREENMAP|V_SNAPTOTOP|V_SNAPTORIGHT, "thin-right")
end

---@param v videolib
---@param player player_t
---@param mobj mobj_t
---@param ze2 ze2_t
local function EventTimers(v, player, mobj, ze2)
	local x = 5
	local y = 12
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP
	for index, timer in ipairs(ZE2:GetActiveTimers()) do
		local name = "* " .. (timer.text or ("Event " .. index))
		local time = "  " .. G_TicsToMTIME(timer.time + TICRATE) .. ""
		local color = timer.textcolor or SKINCOLOR_TEAL
		customhud.CustomFontString(v, x, y + 1, name, "VTNFN", flags, "left", nil, color)
		customhud.CustomFontString(v, x, y + 9, time, "VTNFN", flags, "left", nil, SKINCOLOR_WHITE)
		y = y + 16
	end
end

---@param v videolib
---@param player player_t
return "GameInfo", function(v, player)
	local game = ZE2.Game
	if game.ended then return end
	if not player.realmo then return end

	local mobj = player.realmo
	local ze2 = player.ze2
	RoundInformation(v, player, mobj, ze2)
	MoneyInformation(v,player, mobj, ze2)
	EventTimers(v, player, mobj, ze2)
end