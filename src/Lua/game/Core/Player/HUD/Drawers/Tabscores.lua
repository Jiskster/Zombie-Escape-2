local hudtype = "scores"

local servername = CV_FindVar("servername")

local TableInsert = table.insert

local GetColormap
local GetSprite2Patch
local DrawString
local DrawScaled
local DrawFill

local function ChatColorToTextColor(cflag)
	return cflag and string.char(((cflag - V_MAGENTAMAP) >> 12) + 129) or "\x80"
end

local function RenderPlayer(v, ypos, player, team) -- standard
	local spectator = team.spectator
	local textcolor = 0 --skincolors[teamcolor].chatcolor

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = GetSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 2)
	DrawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, GetColormap(playerskin, playercolor, playertranslation))

	local textspos = 6
	local highlight = (player == consoleplayer) and V_YELLOWMAP or 0
	DrawString(4 + 20, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	local visible_stats = true
	/*if consoleplayer.spectator or (consoleplayer.realmo.team == team.id) then
		visible_stats = true
	end*/

	if visible_stats then
		DrawString(BASEVIDWIDTH - (2 + 120), ypos + textspos, player.ze2.karma, V_ALLOWLOWERCASE|textcolor, "small-right")
		if not spectator then
			local healthtext = player.mo.health
			if player.mo.shield_health then
				healthtext = healthtext .. "+" .. player.mo.shield_health
			end
			DrawString(BASEVIDWIDTH - (2 + 90), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

			if (player.realmo.team == 2) then
				local zombietype = "???"
				if ZE2.ZombieConfig[player.ze2.zombie_type] and ZE2.ZombieConfig[player.ze2.zombie_type].name then
					zombietype = ZE2.ZombieConfig[player.ze2.zombie_type].name
				end
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
			else
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		elseif spectator then
			if player.ze2.injoinqueue or player.ze2.outofgame then
				local statustext = player.ze2.outofgame and "Out" or "Queued"
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, statustext, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		end
	end

	local latencytext = player.ping .. "ms"
	if (player == server) then
		latencytext = "Host"
	elseif (player.quittime > 0) then
		latencytext = "D/C"
	end
	DrawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 16
end

local function RenderPlayerSmall(v, ypos, player, team) -- compact
	local spectator = team.spectator
	local textcolor = 0 --skincolors[teamcolor].chatcolor

	local playerskin = player.realmo and player.realmo.skin or player.skin
	local playercolor = player.realmo and player.realmo.color or player.skincolor
	local playertranslation = player.realmo and player.realmo.translation or nil
	local playericon = GetSprite2Patch(playerskin, SPR2_XTRA, false, A, 0, 0)
	local playericonscale = (FU / 4)
	DrawScaled(4 * FU, ypos * FU, playericonscale, playericon, 0, GetColormap(playerskin, playercolor, playertranslation))

	local textspos = 2
	local highlight = (player == consoleplayer) and V_YELLOWMAP or 0
	DrawString(4 + 10, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	local visible_stats = true
	/*if consoleplayer.spectator or (consoleplayer.realmo.team == team.id) then
		visible_stats = true
	end*/

	if visible_stats then
		DrawString(BASEVIDWIDTH - (2 + 120), ypos + textspos, player.ze2.karma, V_ALLOWLOWERCASE|textcolor, "small-right")
		if not spectator then
			local healthtext = player.mo.health
			if player.mo.shield_health then
				healthtext = healthtext .. "+" .. player.mo.shield_health
			end
			DrawString(BASEVIDWIDTH - (2 + 90), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

			if (player.realmo.team == 2) then
				local zombietype = "???"
				if ZE2.ZombieConfig[player.ze2.zombie_type] and ZE2.ZombieConfig[player.ze2.zombie_type].name then
					zombietype = ZE2.ZombieConfig[player.ze2.zombie_type].name
				end
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
			else
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		elseif spectator then
			if player.ze2.injoinqueue or player.ze2.outofgame then
				local statustext = player.ze2.outofgame and "Out" or "Queued"
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, statustext, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		end
	end

	local latencytext = player.ping .. "ms"
	if (player == server) then
		latencytext = "Host"
	elseif (player.quittime > 0) then
		latencytext = "D/C"
	end
	DrawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 8
end

local function RenderPlayerSmaller(v, ypos, player, team) -- super compact
	local spectator = team.spectator
	local textcolor = 0 --skincolors[teamcolor].chatcolor

	local playercolor = player.realmo and player.realmo.color or player.skincolor
	if (playercolor == SKINCOLOR_NONE) then
		playercolor = SKINCOLOR_GREEN
	end

	for index = 4, 7, 1 do
		local playercolorfill = skincolors[playercolor].ramp[index]
		DrawFill(4, ypos + (index - 4), 4, 1, playercolorfill)
	end

	local textspos = 0
	local highlight = (player == consoleplayer) and V_YELLOWMAP or 0
	DrawString(4 + 5, ypos + textspos, player.name, V_ALLOWLOWERCASE|textcolor|highlight, "small")

	local visible_stats = true
	/*if consoleplayer.spectator or (consoleplayer.mo.team == team.id) then
		visible_stats = true
	end*/

	if visible_stats then
		DrawString(BASEVIDWIDTH - (2 + 120), ypos + textspos, player.ze2.karma, V_ALLOWLOWERCASE|textcolor, "small-right")
		if not spectator then
			local healthtext = player.mo.health
			if player.mo.shield_health then
				healthtext = healthtext .. "+" .. player.mo.shield_health
			end
			DrawString(BASEVIDWIDTH - (2 + 90), ypos + textspos, healthtext, V_ALLOWLOWERCASE|textcolor, "small-right")

			if (player.realmo.team == 2) then
				local zombietype = "???"
				if ZE2.ZombieConfig[player.ze2.zombie_type] and ZE2.ZombieConfig[player.ze2.zombie_type].name then
					zombietype = ZE2.ZombieConfig[player.ze2.zombie_type].name
				end
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, zombietype, V_ALLOWLOWERCASE|textcolor, "small-right")
			else
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, "$" .. player.ze2.cash, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		else
			if player.ze2.injoinqueue or player.ze2.outofgame then
				local statustext = player.ze2.outofgame and "Out" or "Queued"
				DrawString(BASEVIDWIDTH - (2 + 52), ypos + textspos, statustext, V_ALLOWLOWERCASE|textcolor, "small-right")
			end
		end
	end

	local latencytext = player.ping .. "ms"
	if (player == server) then
		latencytext = "Host"
	elseif (player.quittime > 0) then
		latencytext = "D/C"
	end
	DrawString(BASEVIDWIDTH - (2 + 8), ypos + textspos, latencytext, V_ALLOWLOWERCASE|textcolor, "small-right")
	return 4
end

local function RenderTeam(v, ypos, team, size)
	local teamname = team.name
	local teamcolor = team.color
	local playerlist = team.playerlist

	local fillcolor = skincolors[teamcolor].ramp[1]
	local textcolor = skincolors[teamcolor].chatcolor
	local playersdisplay = (#playerlist == 1) and "player" or "players"
	DrawString(4, ypos, ChatColorToTextColor(textcolor) .. teamname .. "\x80" .. " - " .. ChatColorToTextColor(textcolor) .. #playerlist .. " " .. playersdisplay, V_ALLOWLOWERCASE, "small") -- team name

	local visible_stats = true
	/*
	if consoleplayer.spectator or (consoleplayer.mo.team == team.id) then
		visible_stats = true
	end
	*/

	if visible_stats then
		DrawString(BASEVIDWIDTH - (2 + 120), ypos, "Karma", V_ALLOWLOWERCASE, "small-right")
		if not team.spectator then
			DrawString(BASEVIDWIDTH - (2 + 90), ypos, "HP", V_ALLOWLOWERCASE, "small-right")
			if (teamname == "Zombies") then
				DrawString(BASEVIDWIDTH - (2 + 52), ypos, "Type", V_ALLOWLOWERCASE, "small-right")
			else
				DrawString(BASEVIDWIDTH - (2 + 52), ypos, "Money", V_ALLOWLOWERCASE, "small-right")
			end
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
		TableInsert(SpectatorList, player)
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
		DrawString(BASEVIDWIDTH / 2, 5, time, V_ALLOWLOWERCASE, "thin-center")
	end
	DrawString(BASEVIDWIDTH - 4, 5, "Round " ..  game.round .. " of " .. game.maxrounds, V_ALLOWLOWERCASE, "thin-right")

	-- divider
	DrawFill(2, 16, BASEVIDWIDTH - 4, 1, 64)

	local teams = GetTeams()
	local size = GetListSize(teams)
	local height = 0
	for _, team in ipairs(teams) do
		if (#team.playerlist <= 0) then continue end
		height = height + RenderTeam(v, 20 + height, team, size)
	end
end, (hudtype)