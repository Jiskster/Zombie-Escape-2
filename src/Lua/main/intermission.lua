-- Get SRBZ.MapVoteStartFrame from init/gametype.lua

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
	if gametype ~= GT_SRBZ or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if SRBZ.game_ended and SRBZ.win_tics == SRBZ.MapVoteStartFrame then
		SRBZ.MapsOnVote = {
		{0,1},
		{0,1},
		{0,1}
		} -- votes, mapnumber
		local temp_maplist = {}
		local temp_selected_maplist = {}
		
		for i=1,1035 do
			if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_SRBZ) 
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
			SRBZ.MapsOnVote[i][2] = temp_selected_maplist[i]
			print(mapheaderinfo[temp_selected_maplist[i]].lvlttl)
		end
		
		for player in players.iterate do
			player["srbz_info"].vote_selection = P_RandomRange(1,3)
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
		if SRBZ.server_intermissionmusic.value then
			S_ChangeMusic("_VOTE", true)
			mapmusname = "_VOTE"
		end
	end
end)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local cmd = player.cmd
		if player.mo and player.mo.valid and player["srbz_info"] then
			if SRBZ.win_tics > SRBZ.MapVoteStartFrame then
				if SRBZ.win_tics < SRBZ.MapVoteStartFrame + SRBZ.VoteTimeLimit then
					if cmd.sidemove < -40 then
						if not player["srbz_info"].vote_leftpressed and not player["srbz_info"].voted then
							S_StartSound(nil, sfx_s3kb7, player)
							if player["srbz_info"].vote_selection - 1 <= 0 then
								player["srbz_info"].vote_selection = 3
							else
								player["srbz_info"].vote_selection = $ - 1
							end
							player["srbz_info"].vote_leftpressed  = true
						end
					else
						player["srbz_info"].vote_leftpressed = false
					end
					
					if cmd.sidemove > 40 then
						if not player["srbz_info"].vote_rightpressed and not player["srbz_info"].voted then
							S_StartSound(nil, sfx_s3kb7, player)
							if player["srbz_info"].vote_selection + 1 > 3 then
								player["srbz_info"].vote_selection = 1
							else
								player["srbz_info"].vote_selection = $ + 1
							end
							player["srbz_info"].vote_rightpressed  = true
						end
					else
						player["srbz_info"].vote_rightpressed = false
					end
				
					if (cmd.buttons & BT_JUMP) then
						if not player["srbz_info"].vote_selectpressed and not player["srbz_info"].voted then
						
							S_StartSound(nil, sfx_s3kad, player)
							player["srbz_info"].voted = true
							player["srbz_info"].vote_selectpressed = true
							local sel = player["srbz_info"].vote_selection
							local seltomapnum = SRBZ.MapsOnVote[sel]

							SRBZ.MapsOnVote[player["srbz_info"].vote_selection][1] = $ + 1
						end
					else
						player["srbz_info"].vote_selectpressed = false
					end
					
					if (cmd.buttons & BT_SPIN) then
						if not player["srbz_info"].vote_deselectpressed and player["srbz_info"].voted then
						
							S_StartSound(nil, sfx_s3kc3s, player)
							player["srbz_info"].voted = false
							player["srbz_info"].vote_deselectpressed = true
							
							local sel = player["srbz_info"].vote_selection
							local seltomapnum = SRBZ.MapsOnVote[sel]

							SRBZ.MapsOnVote[player["srbz_info"].vote_selection][1] = $ - 1
						end
					else
						player["srbz_info"].vote_deselectpressed = false
					end	
				end
				
				cmd.buttons = 0
				cmd.forwardmove = 0
				cmd.sidemove = 0				
			end	
		end
	end
	
	if SRBZ.win_tics == SRBZ.MapVoteStartFrame + SRBZ.VoteTimeLimit then
		local sorted_votes = SRBZ:Copy(SRBZ.MapsOnVote)

		table.sort(sorted_votes,function(a,b) return a[1] > b[1] end)
		
		if allequals(sorted_votes[1][1],sorted_votes[2][1],sorted_votes[3][1])
			local chosenmap = P_RandomRange(1,3)
			
			print("\x82"..mapheaderinfo[sorted_votes[chosenmap][2]].lvlttl.. " was picked as the next map with a three way tie!")
			SRBZ.NextMapVoted = sorted_votes[chosenmap][2]
		elseif sorted_votes[1][1] == sorted_votes[2][1] then
			local chosenmap = P_RandomRange(1,2)
			
			print("\x82"..mapheaderinfo[sorted_votes[chosenmap][2]].lvlttl.. " was picked as the next map with a two way tie!")
			SRBZ.NextMapVoted = sorted_votes[chosenmap][2]
		else
			print("\x82"..mapheaderinfo[sorted_votes[1][2]].lvlttl.. " was picked as the next map!")
			SRBZ.NextMapVoted = sorted_votes[1][2]
		end
		
		for i,v in ipairs(sorted_votes) do
			print(i..": "..G_BuildMapTitle(v[2]).. "["..v[1].."]")
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
	end
	
	if SRBZ.win_tics == SRBZ.MapVoteStartFrame + SRBZ.VoteTimeLimit + 5*TICRATE then
		COM_BufInsertText(server, "map "..SRBZ.NextMapVoted)
	end
end)
