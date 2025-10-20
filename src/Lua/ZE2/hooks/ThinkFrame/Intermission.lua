return function()
	if gamestate ~= GS_LEVEL then return end --stop the trolling
	
	local newroundframe = ZE2.IntermissionVars.newroundframe
	local newmapframe = ZE2.IntermissionVars.newmapframe
	local slideout_anim = ZE2.IntermissionVars.slideout_anim
	
	-- Post-WinScreen Handling
	if ZE2.getCurrentRound() < ZE2.getMaxRoundsFromMap() then -- new round
		if ZE2.win_tics >= newroundframe and not ZE2.queuing_round then
			ZE2.queuing_round = true
			COM_BufInsertText(server, "map "..gamemap)
		end
	else -- new map
		if ZE2.win_tics == newroundframe + slideout_anim then -- after slideout anim is done, generate a map
			local temp_maplist = {}
			local temp_selected_maplist = {}
			-- local rejected_maps = {}
			
			for i=1,1035 do
				if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_ZE2) 
				and not mapheaderinfo[i].ze2_hidden and i ~= gamemap and not ZE2.PreviousMaps[i] then
					table.insert(temp_maplist,i)
				end
			end
			
			local chosen = P_RandomRange(1,#temp_maplist)
			ZE2.NextMapVoted = temp_maplist[chosen]

			print(mapheaderinfo[ZE2.NextMapVoted].lvlttl .. " has been chosen as the next map!")
			
			S_StartSound(nil,sfx_s3kb3)
		end
		
		if ZE2.win_tics == newmapframe and ZE2.NextMapVoted then
			COM_BufInsertText(server, "map "..ZE2.NextMapVoted)
		end
	end
end