local hudtype = "scores"

local servername = CV_FindVar("servername")

local function RenderPlayer(v, ypos, player, teamcolor, spectator)
	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = v.getSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 2)
	v.drawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, v.getColormap(playerskin, playercolor, playertranslation))

	local textspos = 6
	v.drawString(4 + 20, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor, "small")
	if not spectator then
		local healthtext = player.mo.health
		if player.mo.shield_health then
			healthtext = " | " + player.mo.shield_health
		end
		v.drawString(BASEVIDWIDTH - (2 + 84), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

		if (player.xSlinger.team == 2) then
			local zombietype = "Normal"
			if (player.ze2.zombie_type == "alpha") then
				zombietype = "Alpha"
			end
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
		else
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
		end
	end

	local latencytext = player.ping .. "ms (" .. player.cmd.latency .. ")"
	if (player == server) then
		latencytext = "Host"
	end
	v.drawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 16
end

local function RenderPlayerSmall(v, ypos, player, teamcolor, spectator)
	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = v.getSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 4)
	v.drawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, v.getColormap(playerskin, playercolor, playertranslation))

	local textspos = 2
	v.drawString(4 + 10, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor, "small")
	if not spectator then
		local healthtext = player.mo.health
		if player.mo.shield_health then
			healthtext = " | " + player.mo.shield_health
		end
		v.drawString(BASEVIDWIDTH - (2 + 84), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

		if (player.xSlinger.team == 2) then
			local zombietype = "Normal"
			if (player.ze2.zombie_type == "alpha") then
				zombietype = "Alpha"
			end
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
		else
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
		end
	end

	local latencytext = player.ping .. "ms (" .. player.cmd.latency .. ")"
	if (player == server) then
		latencytext = "Host"
	end
	v.drawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 8
end

local function RenderPlayerSmaller(v, ypos, player, teamcolor, spectator)
	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	if (playercolor == SKINCOLOR_NONE) then
		playercolor = SKINCOLOR_GREEN
	end

	for index = 4, 7, 1 do
		local playercolorfill = skincolors[playercolor].ramp[index]
		v.drawFill(4, ypos + (index - 4), 4, 1, playercolorfill)
	end

	local textspos = 0
	v.drawString(4 + 5, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor, "small")
	if not spectator then
		local healthtext = player.mo.health
		if player.mo.shield_health then
			healthtext = " | " + player.mo.shield_health
		end
		v.drawString(BASEVIDWIDTH - (2 + 84), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

		if (player.xSlinger.team == 2) then
			local zombietype = "Normal"
			if (player.ze2.zombie_type == "alpha") then
				zombietype = "Alpha"
			end
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
		else
			v.drawString(BASEVIDWIDTH - (2 + 48), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
		end
	end

	local latencytext = player.ping .. "ms (" .. player.cmd.latency .. ")"
	if (player == server) then
		latencytext = "Host"
	end
	v.drawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 4
end

local function RenderTeam(v, ypos, teamname, teamcolor, playerlist, spectator, size)
	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor
	local playersdisplay = (#playerlist == 1) and "player" or "players"
	v.drawString(4, ypos, teamname .. " - " .. #playerlist .. " " .. playersdisplay, V_ALLOWLOWERCASE|textcolor, "small") -- team name

	local height = 0
	v.drawFill(2, ypos + 6, BASEVIDWIDTH - 4, 1, fillcolor) -- divider
	for index, player in ipairs(playerlist) do
		local offset
		if (size == 0) then
			offset = RenderPlayer(v, ypos + 8, player, teamcolor, spectator)
		elseif (size == 1) then
			offset = RenderPlayerSmall(v, ypos + 8, player, teamcolor, spectator)
		elseif (size == 2) then
			offset = RenderPlayerSmaller(v, ypos + 8, player, teamcolor, spectator)
		end
		ypos = ypos + offset
		height = height + offset
	end
	return 10 + height
end

local function GetListSize(teams)
	local totalplayers = 0
	for index, team in ipairs(teams) do
		totalplayers = totalplayers + #team.playerlist
	end

	if (totalplayers > 17) then
		return 2
	elseif (totalplayers > 9) then
		return 1
	end
	return 0
end

local function GetTeams()
	local survivors = {
		name = "Survivors",
		color = SKINCOLOR_BLUE,
		playerlist = ZE2.SurvivorList(),
		spectator = false
	}
	local zombies = {
		name = "Zombies",
		color = SKINCOLOR_RED,
		playerlist = ZE2.ZombieList(),
		spectator = false
	}

	local SpectatorList = {}
	for player in players.iterate do
        if not player.spectator then continue end
		table.insert(SpectatorList, player)
	end

	local spectators = {
		name = "Spectators",
		color = SKINCOLOR_CARBON,
		playerlist = SpectatorList,
		spectator = true
	}
	return {survivors, zombies, spectators}
end

return "Tabscores", function(v)
 	local timeemb = v.cachePatch("NGRTIMER")
	local the_time

	if ZE2.round_active then
		if ZE2.time_limit then
			the_time = G_TicsToMTIME(ZE2.time_limit - ZE2.game_time)
		else
			the_time = G_TicsToMTIME(ZE2.game_time)
		end
	else
		the_time = G_TicsToMTIME(ZE2.pregame_timeleft)
	end

    -- background
	v.drawFill(1, 1, BASEVIDWIDTH - 1, BASEVIDHEIGHT - 1, 31|V_TRANSLUCENT)

	-- outlines
	v.drawFill(0, 0, BASEVIDWIDTH, 1, 64) -- top
	v.drawFill(0, BASEVIDHEIGHT - 1, BASEVIDWIDTH, 1, 64) -- bottom
	v.drawFill(0, 1, 1, BASEVIDHEIGHT - 1, 64) -- left
	v.drawFill(BASEVIDWIDTH - 1, 1, 1, BASEVIDHEIGHT - 1, 64) -- right

	-- server name
	v.drawString(4, 4, servername.string, V_ALLOWLOWERCASE, "small-thin")

	-- rounds and timer
	if (the_time ~= nil) then
		v.drawString(BASEVIDWIDTH / 2, 4, the_time, V_ALLOWLOWERCASE, "small-center")
	end
	v.drawString((BASEVIDWIDTH / 2) - 20, 4, "Round " ..  ZE2.getCurrentRound() .. " of " .. ZE2.getMaxRoundsFromMap(), V_ALLOWLOWERCASE, "small-right")

	-- values
	v.drawString(BASEVIDWIDTH - (2 + 84), 4, "HP", V_ALLOWLOWERCASE, "small-right")
	v.drawString(BASEVIDWIDTH - (2 + 48), 4, "Money", V_ALLOWLOWERCASE, "small-right")
	v.drawString(BASEVIDWIDTH - (2 + 8), 4, "Latency", V_ALLOWLOWERCASE, "small-right")

	-- divider
	v.drawFill(2, 10, BASEVIDWIDTH - 4, 1, 64)

	local teams = GetTeams()
	local size = GetListSize(teams)
	local height = 0
	for index, team in ipairs(teams) do
		if (#team.playerlist <= 0) then continue end
		height = height + RenderTeam(v, 14 + height, team.name, team.color, team.playerlist, team.spectator, size)
	end
end, (hudtype)