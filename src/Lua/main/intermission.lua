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

local function V_PlayerVoteCMD(player, cmd)
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

	if (cmd.buttons & BT_JUMP) and not (player.lastbuttons & BT_JUMP) then
		if not player["ze2_info"].voted then
			S_StartSound(nil, sfx_s3kad, player)
			player["ze2_info"].voted = true
			local sel = player["ze2_info"].vote_selection
			local seltomapnum = ZE2.MapsOnVote[sel]

			ZE2.MapsOnVote[player["ze2_info"].vote_selection].votes = $ + 1
		end
	end
	
	if (cmd.buttons & BT_SPIN) and not (player.lastbuttons & BT_SPIN) then
		if player["ze2_info"].voted then
			S_StartSound(nil, sfx_s3kc3s, player)
			player["ze2_info"].voted = false
			
			local sel = player["ze2_info"].vote_selection
			local seltomapnum = ZE2.MapsOnVote[sel]

			ZE2.MapsOnVote[player["ze2_info"].vote_selection].votes = $ - 1
		end
	end	
end

local function V_StartVote()
	ZE2.MapsOnVote = {
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1}
	}
	
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
		ZE2.MapsOnVote[i].mapnum = temp_selected_maplist[i]
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

local function V_EndVote()
	local sorted_votes = ZE2:Copy(ZE2.MapsOnVote)

	table.sort(sorted_votes,function(a,b) return a.votes > b.votes end)
	
	if allequals(sorted_votes[1].votes,sorted_votes[2].votes,sorted_votes[3].votes)
		local chosenmap = P_RandomRange(1,3)
		
		print("\x82"..mapheaderinfo[sorted_votes[chosenmap].mapnum].lvlttl.. " was picked as the next map with a three way tie!")
		ZE2.NextMapVoted = sorted_votes[chosenmap].mapnum
	elseif sorted_votes[1].votes == sorted_votes[2].votes then
		local chosenmap = P_RandomRange(1,2)
		
		print("\x82"..mapheaderinfo[sorted_votes[chosenmap].mapnum].lvlttl.. " was picked as the next map with a two way tie!")
		ZE2.NextMapVoted = sorted_votes[chosenmap].mapnum
	else
		print("\x82"..mapheaderinfo[sorted_votes[1].mapnum].lvlttl.. " was picked as the next map!")
		ZE2.NextMapVoted = sorted_votes[1].mapnum
	end
	
	for i,v in ipairs(sorted_votes) do
		print(i..": "..G_BuildMapTitle(v.mapnum).. "["..v.votes.."]")
	end
	
	S_StartSound(nil,sfx_s3kb3)
end

addHook("ThinkFrame", do
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if ZE2.game_ended and ZE2.win_tics == ZE2.MapVoteStartFrame then
		if not (ZE2.rounds_left > 1) then
			V_StartVote()
		else
			ZE2.queuing_round = true
			S_FadeMusic(0, 2500)
		end
	end
end)

addHook("PreThinkFrame", function()
	if not ZE2.game_ended then return end
	
	for player in players.iterate do
		local cmd = player.cmd
		if player.mo and player.mo.valid and player["ze2_info"] then
			if ZE2.win_tics > ZE2.MapVoteStartFrame then
				if ZE2.win_tics < ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit 
				and not (ZE2.rounds_left > 1) then
					V_PlayerVoteCMD(player, cmd)
					
					cmd.buttons = 0
					cmd.forwardmove = 0
					cmd.sidemove = 0
				end
			end	
		end
	end
	
	if not (ZE2.rounds_left > 1) then
		if ZE2.win_tics == ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit then
			V_EndVote()
		end
		
		if ZE2.win_tics == ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit + 5*TICRATE then
			COM_BufInsertText(server, "map "..ZE2.NextMapVoted)
		end
	else
		if ZE2.win_tics == ZE2.MapVoteStartFrame + 5*TICRATE then -- proceed to next round
			COM_BufInsertText(server, "map "..gamemap)
		end
	end
end)
