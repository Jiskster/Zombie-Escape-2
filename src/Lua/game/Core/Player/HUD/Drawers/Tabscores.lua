local hudtype = "scores"

local servername = CV_FindVar("servername")

local GetColormap
local GetSprite2Patch
local DrawString
local DrawScaled
local DrawFill

local function RenderPlayerStats(v, ypos, player, team, spectator)
	local textcolor = 0

	local karmadisplay = player.ze2.karma
	local karmacolor = "\x87"
	if (player.ze2.karma <= (ZE2.MaxKarma / 2)) then
		karmacolor = "\x82"
	elseif (player.ze2.karma <= (ZE2.MaxKarma / 4)) then
		karmacolor = "\x83"
	end

	if player.ze2.zombiepls then
		karmacolor = ""
		karmadisplay = ""
	end

	DrawString(BASEVIDWIDTH - (2 + 120), ypos, karmacolor .. karmadisplay, V_ALLOWLOWERCASE|textcolor, "small-right")
	if not spectator then
		local healthcolor = "\x83"
		if (player.mo.health < (player.mo.maxhealth / 2)) then
			healthcolor = "\x87"
		end

		local healthtext = healthcolor .. player.mo.health
		if player.mo.shield_health then
			healthtext = healthtext .. "\x80" .. "+" .. "\x88" .. player.mo.shield_health
		end
		DrawString(BASEVIDWIDTH - (2 + 90), ypos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

		if (player.realmo.team == 2) then
			local zombiecolor = "\x85"
			local zombietype = "???"
			if ZE2.ZombieConfig[player.ze2.zombie_type] and ZE2.ZombieConfig[player.ze2.zombie_type].name then
				zombiecolor = L_ChatColorToTextColor(skincolors[ZE2.ZombieConfig[player.ze2.zombie_type].skincolor].chatcolor)
				zombietype = ZE2.ZombieConfig[player.ze2.zombie_type].name
			end
			DrawString(BASEVIDWIDTH - (2 + 52), ypos, zombiecolor .. zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
		else
			DrawString(BASEVIDWIDTH - (2 + 52), ypos, "\x83" .. "$" .. "\x80" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
		end
	elseif spectator then
		if player.ze2.injoinqueue or player.ze2.outofgame then
			local statustext = player.ze2.outofgame and ("\x85" .. "Out") or ("\x82" .. "Queued")
			DrawString(BASEVIDWIDTH - (2 + 52), ypos, statustext, V_ALLOWLOWERCASE|textcolor, "small-right")
		end
	end

	local latencycolor = "\x88"
	if (player.ping > 256) then
		latencycolor = "\x87"
	elseif (player.ping > 128) then
		latencycolor = "\x82"
	elseif (player.ping > 64) then
		latencycolor = "\x83"
	end

	local latencytext = player.ping .. "\x80" .. "ms"
	if (player == server) then
		latencycolor = "\x8C"
		latencytext = "Host"
	elseif (player.quittime > 0) then
		latencycolor = "\x86"
		latencytext = "D/C"
	end
	DrawString(BASEVIDWIDTH - (2 + 8), ypos, latencycolor .. latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
end


local function RenderPlayer(v, ypos, player, team) -- standard
	if (player == consoleplayer) then
		DrawFill(4, ypos, BASEVIDWIDTH - 8, 16, 73|V_TRANSLUCENT)
	end

	local spectator = team.spectator
	local textcolor = 0

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = GetSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 2)
	DrawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, GetColormap(playerskin, playercolor, playertranslation))

	local textspos = 6
	local highlight = skincolors[player.skincolor or SKINCOLOR_WHITE].chatcolor
	DrawString(4 + 20, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	RenderPlayerStats(v, ypos + textspos, player, team, spectator)
	return 16
end

local function RenderPlayerSmall(v, ypos, player, team) -- compact
	if (player == consoleplayer) then
		DrawFill(4, ypos, BASEVIDWIDTH - 8, 8, 73|V_TRANSLUCENT)
	end

	local spectator = team.spectator
	local textcolor = 0

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = GetSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 4)
	DrawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, GetColormap(playerskin, playercolor, playertranslation))

	local textspos = 2
	local highlight = skincolors[player.skincolor or SKINCOLOR_WHITE].chatcolor
	DrawString(4 + 10, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	RenderPlayerStats(v, ypos + textspos, player, team, spectator)
	return 8
end

local function RenderPlayerSmaller(v, ypos, player, team) -- super compact
	if (player == consoleplayer) then
		DrawFill(4, ypos, BASEVIDWIDTH - 8, 4, 73|V_TRANSLUCENT)
	end

	local spectator = team.spectator
	local textcolor = 0

	local playercolor = player.realmo and player.realmo.color or player.skincolor
	if (playercolor == SKINCOLOR_NONE) then
		playercolor = SKINCOLOR_GREEN
	end

	for index = 4, 7, 1 do
		local playercolorfill = skincolors[playercolor].ramp[index]
		DrawFill(4, ypos + (index - 4), 4, 1, playercolorfill)
	end

	local textspos = 0
	local highlight = skincolors[player.skincolor or SKINCOLOR_WHITE].chatcolor
	DrawString(4 + 5, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	RenderPlayerStats(v, ypos + textspos, player, team, spectator)
	return 4
end

local function RenderTeam(v, ypos, team, size)
	local teamname = team.name
	local teamcolor = team.color
	local playerlist = team.playerlist

	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor
	local playersdisplay = (#playerlist == 1) and "player" or "players"
	DrawString(4, ypos, L_ChatColorToTextColor(textcolor) .. teamname .. "\x80" .. " - " .. "\x82" .. #playerlist .. " " .. playersdisplay, V_ALLOWLOWERCASE, "small") -- team name

	DrawString(BASEVIDWIDTH - (2 + 120), ypos, "Karma", V_ALLOWLOWERCASE, "small-right")
	if not team.spectator then
		DrawString(BASEVIDWIDTH - (2 + 90), ypos, "HP", V_ALLOWLOWERCASE, "small-right")
		if (teamname == "Zombies") then
			DrawString(BASEVIDWIDTH - (2 + 52), ypos, "Type", V_ALLOWLOWERCASE, "small-right")
		else
			DrawString(BASEVIDWIDTH - (2 + 52), ypos, "Money", V_ALLOWLOWERCASE, "small-right")
		end
	end
	DrawString(BASEVIDWIDTH - (2 + 8), ypos, "Ping", V_ALLOWLOWERCASE, "small-right")

	local height = 0
	DrawFill(2, ypos + 6, BASEVIDWIDTH - 4, 1, fillcolor) -- divider
	for _, player in ipairs(playerlist) do
		local offset
		if (size == 0) then
			offset = RenderPlayer(v, ypos + 8, player, team)
		elseif (size == 1) then
			offset = RenderPlayerSmall(v, ypos + 8, player, team)
		elseif (size == 2) then
			offset = RenderPlayerSmaller(v, ypos + 8, player, team)
		end
		ypos = ypos + offset
		height = height + offset
	end
	return 10 + height
end

local function GetListSize(teams)
	local totalplayers = 0
	for _, team in ipairs(teams) do
		if (#team.playerlist <= 0) then continue end
		totalplayers = totalplayers + #team.playerlist + 1
	end

	if (totalplayers >= 18) then
		return 2
	elseif (totalplayers >= 10) then
		return 1
	end
	return 0
end

local function GetTeams()
	local survivors = {
		id = 1,
		name = "Survivors",
		color = SKINCOLOR_BLUE,
		playerlist = ZE2.ListPlayers("survivors"),
		spectator = false
	}
	local zombies = {
		id = 2,
		name = "Zombies",
		color = SKINCOLOR_RED,
		playerlist = ZE2.ListPlayers("zombies"),
		spectator = false
	}

	local SpectatorList = {}
	for player in players.iterate do
        if not player.spectator then continue end
		table.insert(SpectatorList, player)
	end

	local spectators = {
		id = -1,
		name = "Spectators",
		color = SKINCOLOR_CARBON,
		playerlist = SpectatorList,
		spectator = true
	}
	return {survivors, zombies, spectators}
end

---@param v videolib
return "Tabscores", function(v)
	local game = ZE2.Game
	local time = G_TicsToMTIME(game.state_tics)

	if (GetColormap == nil) then GetColormap = v.getColormap end
	if (GetSprite2Patch == nil) then GetSprite2Patch = v.getSprite2Patch end
	if (DrawFill == nil) then DrawFill = v.drawFill end
	if (DrawScaled == nil) then DrawScaled = v.drawScaled end
	if (DrawString == nil) then DrawString = v.drawString end

    -- background
	DrawFill(1, 1, BASEVIDWIDTH - 1, BASEVIDHEIGHT - 1, 31|V_TRANSLUCENT)

	-- outlines
	DrawFill(0, 0, BASEVIDWIDTH, 1, 64) -- top
	DrawFill(0, BASEVIDHEIGHT - 1, BASEVIDWIDTH, 1, 64) -- bottom
	DrawFill(0, 1, 1, BASEVIDHEIGHT - 1, 64) -- left
	DrawFill(BASEVIDWIDTH - 1, 1, 1, BASEVIDHEIGHT - 1, 64) -- right

	-- server name
	DrawString(4, 5, servername.string, V_ALLOWLOWERCASE, "thin")

	-- rounds and timer
	if (time ~= nil) then
		DrawString(BASEVIDWIDTH - 4, 4, time, V_ALLOWLOWERCASE, "right")
	end
	DrawString(BASEVIDWIDTH - 4, 14, "Round " ..  game.round .. " of " .. game.maxrounds, V_ALLOWLOWERCASE, "right")

	-- divider
	DrawFill(2, 26, BASEVIDWIDTH - 4, 1, 64)

	local teams = GetTeams()
	local size = GetListSize(teams)
	local height = 0
	for _, team in ipairs(teams) do
		if (#team.playerlist <= 0) then continue end
		height = height + RenderTeam(v, 34 + height, team, size)
	end
end, (hudtype)