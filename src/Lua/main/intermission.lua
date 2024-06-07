-- Get ZE2.MapVoteStartFrame from init/gametype.lua

local function allequals(...)
	local args = {...}
	local success = true
	
	for i,v in ipairs(args)
		
		for ii,vv in ipairs(args)
			if v ~= vv then
				success = false
				break 2
			end
		end
	end
	
	return success
end

addHook("ThinkFrame", do
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if ZE2.game_ended and ZE2.win_tics == ZE2.MapVoteStartFrame then
		ZE2.MapsOnVote = {
		{0,1},
		{0,1},
		{0,1}
		} -- votes, mapnumber
		local temp_maplist = {}
		local temp_selected_maplist = {}
		
		for i=1,1035 do
			if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_ZE2) 
			and not mapheaderinfo[i].hidefromvote then
				table.insert(temp_maplist,i)
			end
		end
		
		for i=1,3 do
			local chosen = P_RandomRange(1,#temp_maplist)
			table.insert(temp_selected_maplist,temp_maplist[chosen])
			table.remove(temp_maplist,chosen)
		end
		
		temp_maplist = {} -- clear leftover maps
		
		for i=1,#temp_selected_maplist do
			ZE2.MapsOnVote[i][2] = temp_selected_maplist[i]
			print(mapheaderinfo[temp_selected_maplist[i]].lvlttl)
		end
		
		for player in players.iterate do
			player["ze2_info"].vote_selection = P_RandomRange(1,3)
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
		if ZE2.server_intermissionmusic.value then
			S_ChangeMusic("_VOTE", true)
			mapmusname = "_VOTE"
		end
	end
end)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local cmd = player.cmd
		if player.mo and player.mo.valid and player["ze2_info"] then
			if ZE2.win_tics > ZE2.MapVoteStartFrame then
				if ZE2.win_tics < ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit then
					if cmd.sidemove < -40 then
						if not player["ze2_info"].vote_leftpressed and not player["ze2_info"].voted then
							S_StartSound(nil, sfx_s3kb7, player)
							if player["ze2_info"].vote_selection - 1 <= 0 then
								player["ze2_info"].vote_selection = 3
							else
								player["ze2_info"].vote_selection = $ - 1
							end
							player["ze2_info"].vote_leftpressed  = true
						end
					else
						player["ze2_info"].vote_leftpressed = false
					end
					
					if cmd.sidemove > 40 then
						if not player["ze2_info"].vote_rightpressed and not player["ze2_info"].voted then
							S_StartSound(nil, sfx_s3kb7, player)
							if player["ze2_info"].vote_selection + 1 > 3 then
								player["ze2_info"].vote_selection = 1
							else
								player["ze2_info"].vote_selection = $ + 1
							end
							player["ze2_info"].vote_rightpressed  = true
						end
					else
						player["ze2_info"].vote_rightpressed = false
					end
				
					if (cmd.buttons & BT_JUMP) then
						if not player["ze2_info"].vote_selectpressed and not player["ze2_info"].voted then
						
							S_StartSound(nil, sfx_s3kad, player)
							player["ze2_info"].voted = true
							player["ze2_info"].vote_selectpressed = true
							local sel = player["ze2_info"].vote_selection
							local seltomapnum = ZE2.MapsOnVote[sel]

							ZE2.MapsOnVote[player["ze2_info"].vote_selection][1] = $ + 1
						end
					else
						player["ze2_info"].vote_selectpressed = false
					end
					
					if (cmd.buttons & BT_SPIN) then
						if not player["ze2_info"].vote_deselectpressed and player["ze2_info"].voted then
						
							S_StartSound(nil, sfx_s3kc3s, player)
							player["ze2_info"].voted = false
							player["ze2_info"].vote_deselectpressed = true
							
							local sel = player["ze2_info"].vote_selection
							local seltomapnum = ZE2.MapsOnVote[sel]

							ZE2.MapsOnVote[player["ze2_info"].vote_selection][1] = $ - 1
						end
					else
						player["ze2_info"].vote_deselectpressed = false
					end	
				end
				
				cmd.buttons = 0
				cmd.forwardmove = 0
				cmd.sidemove = 0				
			end	
		end
	end
	
	if ZE2.win_tics == ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit then
		local sorted_votes = ZE2:Copy(ZE2.MapsOnVote)

		table.sort(sorted_votes,function(a,b) return a[1] > b[1] end)
		
		if allequals(sorted_votes[1][1],sorted_votes[2][1],sorted_votes[3][1])
			local chosenmap = P_RandomRange(1,3)
			
			print("\x82"..mapheaderinfo[sorted_votes[chosenmap][2]].lvlttl.. " was picked as the next map with a three way tie!")
			ZE2.NextMapVoted = sorted_votes[chosenmap][2]
		elseif sorted_votes[1][1] == sorted_votes[2][1] then
			local chosenmap = P_RandomRange(1,2)
			
			print("\x82"..mapheaderinfo[sorted_votes[chosenmap][2]].lvlttl.. " was picked as the next map with a two way tie!")
			ZE2.NextMapVoted = sorted_votes[chosenmap][2]
		else
			print("\x82"..mapheaderinfo[sorted_votes[1][2]].lvlttl.. " was picked as the next map!")
			ZE2.NextMapVoted = sorted_votes[1][2]
		end
		
		for i,v in ipairs(sorted_votes) do
			print(i..": "..G_BuildMapTitle(v[2]).. "["..v[1].."]")
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
	end
	
	if ZE2.win_tics == ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit + 5*TICRATE then
		COM_BufInsertText(server, "map "..ZE2.NextMapVoted)
	end
end)
