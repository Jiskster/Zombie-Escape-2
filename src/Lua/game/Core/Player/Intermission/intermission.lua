local MAX_SELECTION = 3
local MAX_MAP_HEALTH = 40
local MAX_WARP_TIME = 4 * TICRATE
local MAX_VOTE_TIME = 30 * TICRATE

local function getMapsLeft(vote)
	local mapsleft = 0
	local maps = vote.maps
	for i = 1, #maps, 1 do
		local map = maps[i]
		if not map then continue end
		if (map.health <= 0) or not map.onscreen then continue end
		mapsleft = mapsleft + 1
	end
	return mapsleft
end

local function voteEnding(vote)
	if (getMapsLeft(vote) == 1) then
		return true
	end
	return false
end

local function getLastMap(vote)
	if not voteEnding(vote) then
		return false
	end

	local maps = vote.maps
	for i = 1, #maps, 1 do
		local map = maps[i]
		if not map or not map.onscreen or not map.health then continue end
		return map
	end
	return false
end

local function chooseRandomMap(vote)
	local maps = vote.maps
	local elected_maps = {}
	for i = 1, #maps, 1 do
		local map = maps[i]
		map.fuse = -1
		if not map or not map.onscreen or not map.health then continue end

		table.insert(elected_maps, map)
	end

	if not #elected_maps then
		print("\x85" .. "Uh oh! This isn't supposed to happen!! - Jisk")
		return false
	end

	local elected_index = P_RandomRange(1, #elected_maps)
	vote.nextmapvoted = elected_maps[elected_index].num
	vote.nextgtvoted = elected_maps[elected_index].gametype_number
	vote.warp_time = MAX_WARP_TIME
	print("Map Selected: "..G_BuildMapTitle(vote.nextmapvoted).." (Selected By Random)")
	S_StartSound(nil, sfx_s3kb3)

	return true
end

local function VoteScreenThink(player, cmd, pvote)
	local vote = ZE2.Vote
	if voteEnding(vote) or vote.nextmapvoted then
		return
	end

	local attacked = not (pvote.lastbuttons & BT_JUMP) and (cmd.buttons & BT_JUMP)
	local left = ((pvote.lastside >= -40) and (cmd.sidemove < -40))
	local right = ((pvote.lastside < 40) and (cmd.sidemove >= 40))
	local moved = (left or right)
	if left then
		pvote.selection = pvote.selection - 1
	elseif right then
		pvote.selection = pvote.selection + 1
	end

	local map = vote.maps[pvote.selection]

	if map and attacked then
		if map.onscreen and vote.active then
			pvote.lasthit = leveltime
			map.health = map.health - 1
			if map.health <= 0 and not map.fuse then
				local mapsleft = getMapsLeft(vote)
				map.fuse = TICRATE
				if (mapsleft == 1) then -- last one standing...
					vote.active = false
				end
			end
			S_StartSound(nil, sfx_dmpain, player)
		else
			S_StartSound(nil, sfx_lose, player)
		end
	end

	if moved then
		S_StartSound(nil, sfx_menu1, player)
	end

	if (pvote.selection > MAX_SELECTION) then
		pvote.selection = 1
	elseif (pvote.selection <= 0) then
		pvote.selection = MAX_SELECTION
	end
end

addHook("PreThinkFrame", function()
	if (gamestate ~= GS_LEVEL) then return end --stop the trolling

	local vote = ZE2.Vote
	local game = ZE2.Game

	local newroundframe = ZE2.IntermissionVars.newroundframe
	local newmapframe = ZE2.IntermissionVars.newmapframe
	local slideout_anim = ZE2.IntermissionVars.slideout_anim

	-- Post-WinScreen Handling
	if (game.round < game.maxrounds) then -- new round
		if (game.win_tics >= newroundframe) and not game.queueround then
			game.queueround = true
			G_SetCustomExitVars(gamemap, 2)
			G_ExitLevel()
		end
		return
	end

	-- new map
	if (game.win_tics == (newroundframe + slideout_anim)) then -- after slideout anim is done, generate a map
		local temp_maplist = {}
		local temp_selected_maplist = {}
		-- local rejected_maps = {}

		for i = 1, 1035, 1 do
			if not mapheaderinfo[i] then continue end
			if (i == gamemap) then continue end
			if mapheaderinfo[i].ze2_hidden then continue end
			if not ((mapheaderinfo[i].typeoflevel & TOL_ESCAPE) or (mapheaderinfo[i].typeoflevel & TOL_PLAGUE)) then continue end
			table.insert(temp_maplist, i)
		end

		for i = 1, 3, 1 do
			local chosen = P_RandomRange(1, #temp_maplist)
			vote.maps[i].health = MAX_MAP_HEALTH
			vote.maps[i].num = temp_maplist[chosen]

			local mapnum = vote.maps[i].num
			local settings = ZE2.TOLtoGametypeName(mapheaderinfo[mapnum].typeoflevel)
			vote.maps[i].gametype_name = settings.gametype_name 
			vote.maps[i].gametype_number = settings.gametype_number 
			table.remove(temp_maplist, chosen)

			if not #temp_maplist then -- Just in case there isn't enough maps.
				vote.maps[i].health = 1
				vote.maps[i].num = 1
			end
		end
		vote.time_left = MAX_VOTE_TIME
		S_StartSound(nil, sfx_s3kb3)
	end

	if (game.win_tics >= (newroundframe + slideout_anim)) then
		for player in players.iterate do
			local cmd = player.cmd
			local pvote = player.ze2.vote

			VoteScreenThink(player, cmd, pvote)

			pvote.lastbuttons = cmd.buttons
			pvote.lastforward = cmd.forwardmove
			pvote.lastside = cmd.sidemove

			cmd.buttons = 0
			cmd.forwardmove = 0
			cmd.sidemove = 0
		end

		local maps = vote.maps
		for i = 1, #maps, 1 do
			local map = maps[i]
			if not map or (map.fuse <= 0) then continue end

			map.fuse = map.fuse - 1
			if (map.fuse > 0) then continue end

			map.onscreen = false
			if not voteEnding(vote) or (vote.nextmapvoted ~= nil) then continue end

			local lastmap = getLastMap(vote)
			if (lastmap == false) then
				print("\x85" .. "Uh oh! This isn't supposed to happen! - Jisk")
				continue
			end

			vote.nextmapvoted = lastmap.num
			vote.nextgtvoted = lastmap.gametype_number
			vote.warp_time = MAX_WARP_TIME
			print("Map Selected: "..G_BuildMapTitle(vote.nextmapvoted))
			S_StartSound(nil, sfx_s3kb3)
		end
	end

	if vote.warp_time > 0 then
		vote.warp_time = vote.warp_time - 1
		if (vote.warp_time <= 0) then
			G_SetCustomExitVars(vote.nextmapvoted, 2, vote.nextgtvoted)
			G_ExitLevel()
			vote.warp_time = -1
		end
	end

	if (vote.time_left > 0) and not vote.nextmapvoted then
		vote.time_left = vote.time_left - 1
		if (vote.time_left <= 0) then
			chooseRandomMap(vote)
			vote.time_left = -1
		end
	end
end)