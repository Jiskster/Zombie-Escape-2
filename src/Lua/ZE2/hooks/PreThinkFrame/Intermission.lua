local MAX_SELECTION = 3
local MAX_MAP_HEALTH = 40

local function VoteScreenThink(player, cmd, pvote)
	local vote = ZE2.vote
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
		if map.onscreen then
			S_StartSound(nil, sfx_dmpain, player)
			pvote.lasthit = leveltime
			
			map.health = $ - 1 
			if map.health <= 0 and not map.fuse then
				map.fuse = TICRATE
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

			S_StartSound(nil,sfx_s3kb3)
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
						end
					end
				end
			end
		end

		/*
		if ZE2.win_tics == newmapframe and ZE2.NextMapVoted then
			G_SetCustomExitVars(ZE2.NextMapVoted, 2)
			G_ExitLevel()
		end
		*/
	end
end