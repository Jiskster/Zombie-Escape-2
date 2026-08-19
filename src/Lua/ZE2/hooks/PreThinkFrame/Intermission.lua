local MAX_SELECTION = 3
local MAX_MAP_HEALTH = 40
local MAX_WARP_TIME = 4*TICRATE
local MAX_VOTE_TIME = 30*TICRATE

local function getMapsLeft(vote)
	local mapsleft = 0
	local maps = vote.maps
	
	for i=1,#maps do
		local map = maps[i]
		
		if map then
			if map.health > 0 and map.onscreen then
				mapsleft = $ + 1
			end
		end
	end
	
	return mapsleft
end

local function voteEnding(vote)
	if getMapsLeft(vote) == 1 then
		return true
	end
	
	return false
end

local function getLastMap(vote)
	if not voteEnding(vote) then
		return false
	end
	
	local maps = vote.maps
	
	for i=1,#maps do
		local map = maps[i]
		
		if map and map.onscreen and map.health then
			return map
		end
	end
	
	return false
end

local function chooseRandomMap(vote)
	local maps = vote.maps
	local elected_maps = {}
	
	for i=1,#maps do
		local map = maps[i]
		map.fuse = -1
		
		if map and map.onscreen and map.health then
			table.insert(elected_maps, map.num)
		end
	end
	
	if not #elected_maps then
		print("\x85\Uh oh! This isn't supposed to happen!! - Jisk")
		return false
	end
	
	ZE2.NextMapVoted = elected_maps[P_RandomRange(1, #elected_maps)]
	S_StartSound(nil, sfx_s3kb3)
	
	vote.warp_time = MAX_WARP_TIME
	
	print("Map Selected: "..G_BuildMapTitle(ZE2.NextMapVoted).." (Selected By Random)")
	
	return true
end

local function VoteScreenThink(player, cmd, pvote)
	local vote = ZE2.vote
	
	if voteEnding(vote) or ZE2.NextMapVoted then
		return
	end
	
	local attacked = not (pvote.lastbuttons & BT_JUMP) and (cmd.buttons & BT_JUMP)
	local left = (pvote.lastside >= -40 and cmd.sidemove < -40)
	local right = (pvote.lastside < 40 and cmd.sidemove >= 40)
	
	local moved = (left or right)
	
	if left then
		pvote.selection = $ - 1
	elseif right then
		pvote.selection = $ + 1
	end
	
	local map = vote.maps[pvote.selection]
	
	if attacked then
		if map.onscreen and vote.active then
			S_StartSound(nil, sfx_dmpain, player)
			pvote.lasthit = leveltime
			
			map.health = $ - 1
			
			if map.health <= 0 and not map.fuse then
				local mapsleft = getMapsLeft(vote)
				map.fuse = TICRATE
				
				-- last one standing...
				if (mapsleft == 1) then
					vote.active = false
				end
			end
		else
			S_StartSound(nil, sfx_lose, player)
		end
	end
	
	if moved then
		S_StartSound(nil, sfx_menu1, player)
	end
	
	if pvote.selection > MAX_SELECTION then
		pvote.selection = 1
	elseif pvote.selection <= 0 then
		pvote.selection = MAX_SELECTION
	end
end

return function()
	if gamestate ~= GS_LEVEL then return end --stop the trolling
	
	local vote = ZE2.vote

	local newroundframe = ZE2.IntermissionVars.newroundframe
	local newmapframe = ZE2.IntermissionVars.newmapframe
	local slideout_anim = ZE2.IntermissionVars.slideout_anim

	-- Post-WinScreen Handling
	if ZE2.getCurrentRound() < ZE2.getMaxRoundsFromMap() then -- new round
		if ZE2.win_tics >= newroundframe and not ZE2.queuing_round then
			ZE2.queuing_round = true
			G_SetCustomExitVars(gamemap, 2)
			G_ExitLevel()
		end
	else -- new map
		if ZE2.win_tics == newroundframe + slideout_anim then -- after slideout anim is done, generate a map
			local temp_maplist = {}
			local temp_selected_maplist = {}
			-- local rejected_maps = {}

			for i=1,1035 do
				if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_ESCAPE)
				and not mapheaderinfo[i].ze2_hidden and i ~= gamemap then
					table.insert(temp_maplist,i)
				end
			end

			for i=1,3 do
				local chosen = P_RandomRange(1, #temp_maplist)
				vote.maps[i].health = MAX_MAP_HEALTH
				vote.maps[i].num = temp_maplist[chosen]
				
				table.remove(temp_maplist, chosen)
				
				-- Just in case there isn't enough maps.
				if not #temp_maplist then
					vote.maps[i].health = 1
					vote.maps[i].num = 1
				end
			end

			S_StartSound(nil, sfx_s3kb3)
			
			vote.time_left = MAX_VOTE_TIME
		end

		if ZE2.win_tics >= newroundframe + slideout_anim then
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
			
			for i=1, #maps do
				local map = maps[i]
				if map then
					if map.fuse then
						map.fuse = $ - 1
						if not map.fuse then
							map.onscreen = false
							
							if voteEnding(vote) then
								local lastmap = getLastMap(vote)
								
								if lastmap ~= false then
									ZE2.NextMapVoted = lastmap.num
									
									S_StartSound(nil, sfx_s3kb3)
									
									print("Map Selected: "..G_BuildMapTitle(ZE2.NextMapVoted))
									
									vote.warp_time = MAX_WARP_TIME
								else
									print("\x85\Uh oh! This isn't supposed to happen! - Jisk")
								end
							end
						end
					end
				end
			end
		end

		if vote.warp_time > 0 then
			vote.warp_time = $ - 1
			
			if vote.warp_time <= 0 then
				G_SetCustomExitVars(ZE2.NextMapVoted, 2)
				G_ExitLevel()
				vote.warp_time = -1 
			end
		end
		
		if vote.time_left > 0 and not ZE2.NextMapVoted then
			vote.time_left = $ - 1 
			
			if vote.time_left <= 0 then
				chooseRandomMap(vote)
				vote.time_left = -1
			end
		end
	end
end