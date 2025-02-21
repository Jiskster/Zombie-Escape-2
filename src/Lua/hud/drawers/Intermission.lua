local tx = CV_RegisterVar({
	name = "tx",
	defaultvalue = "0",
	PossibleValue = CV_Unsigned,
})
local ty = CV_RegisterVar({
	name = "ty",
	defaultvalue = "0",
	PossibleValue = CV_Unsigned,
})

return "Intermission", function(v, player)
	if not ZE2.game_ended then return end
	
	local animlength = 3*TICRATE
	local x1 = {
		start = -400,
		stop = 50
	}
	local x2 = {
		start = 700,
		stop = 220
	}
	local bg = { -- background
		start = 9,
		stop = 6
	}	
	local bl = { -- bang lower's y
		start = 168+300,
		stop = 168
	}
	local bu = { -- bang upper's y
		start = -300,
		stop = 0
	}
	
	local z_team = v.cachePatch("Z_SURVIVORS")
	local z_w = v.cachePatch("Z_WIN")
	local z_bu = v.cachePatch("Z_BANG_UPPER_BLUE")
	local z_bl = v.cachePatch("Z_BANG_LOWER_BLUE")
	local z_bg = v.cachePatch("Z_BG_BLUE")
	
	if ZE2.team_won == 2 then
		z_bu = v.cachePatch("Z_BANG_UPPER_RED")
		z_bl = v.cachePatch("Z_BANG_LOWER_RED")
		z_bg = v.cachePatch("Z_BG_RED")
		z_team = v.cachePatch("Z_ZOMBIES")
	end
	
	local scroll = (ZE2.win_tics%128)
	
	x1.ese = ease.outquart(FixedDiv(ZE2.win_tics*FU, animlength*FU),x1.start*FU,x1.stop*FU)
	x2.ese = ease.outquart(FixedDiv(ZE2.win_tics*FU, animlength*FU),x2.start*FU,x2.stop*FU)
	bg.ese = bg.start-(FixedDiv(ZE2.win_tics*FU, animlength*FU/2)*9/FU)
	bl.ese = ease.outquart(FixedDiv(ZE2.win_tics*FU, animlength*FU),bl.start*FU,bl.stop*FU)
	bu.ese = ease.outquart(FixedDiv(ZE2.win_tics*FU, animlength*FU),bu.start*FU,bu.stop*FU)
	
	local votepatchsize = FU>>1 -- both the cursor and level icon sizes
	
	if bg.ese > 5 then
		v.drawScaled(-500*FU,-500*FU, FU*1000, z_bg, bg.ese<<V_ALPHASHIFT)
	else
		v.drawScaled(-500*FU,-500*FU, FU*1000, z_bg, 5<<V_ALPHASHIFT)
	end
	
	if not ZE2.NextMapVoted then
		if ZE2.win_tics < ZE2.MapVoteStartFrame then -- animation
			v.drawScaled(min(x1.ese, x1.stop*FU),100*FU, FU, z_team)
			v.drawScaled(max(x2.ese, x2.stop*FU),100*FU, FU, z_w)
		elseif ZE2.rounds_left > 1 then -- between rounds
			local diff = max(0, min(ZE2.win_tics - ZE2.MapVoteStartFrame, 10))
			
			local diff2_delay = 10
			local diff2 = 9 - max(0, min((ZE2.win_tics-diff2_delay) - ZE2.MapVoteStartFrame, 9)) -- delay by 10 frames
			
			local round_color = SKINCOLOR_WHITE 
			
			if ZE2.team_won == 1 then
				round_color = SKINCOLOR_BLUE
			elseif ZE2.team_won == 2 then
				round_color = SKINCOLOR_RED
			end
			
			if diff < 10 then
				v.drawScaled(x1.stop*FU, 100*FU, FU, z_team, diff<<V_ALPHASHIFT)
				v.drawScaled(x2.stop*FU, 100*FU, FU, z_w, diff<<V_ALPHASHIFT)
			else
				local nextround = ZE2.getCurrentRound() + 1
				local text = "ROUND "..nextround
				
				-- when next round is the last round
				if ZE2.getMaxRoundsFromMap() == nextround then
					text = "FINAL ROUND"
				end
				
				customhud.CustomFontString(v, 160*FU, 100*FU, text, "STCFC", 
				diff2<<V_ALPHASHIFT, "center", 2*FRACUNIT, round_color)
			end
		elseif ZE2.MapsOnVote and #ZE2.MapsOnVote >= 3 then -- map vote
			local selection = player["ze2_info"].vote_selection
			local cursor_patch = v.cachePatch("SLCT1LVL")
			local cursor_patch2 = v.cachePatch("SLCT2LVL")
			
			local map_y = 75*FU

			v.drawString(160*FU,42*FU,"\x82VOTE:\x80 JUMP    \x82 CANCEL:\x80 SPIN", V_SNAPTOTOP, "thin-fixed-center")
			
			for i=-1,1 do
				local numonlist = i+2
				local map_patch = v.cachePatch(G_BuildMapName(ZE2.MapsOnVote[numonlist].mapnum).."P")
				local levelname = (mapheaderinfo[ZE2.MapsOnVote[numonlist].mapnum].lvlttl)
				local map_votes = ZE2.MapsOnVote[numonlist].votes
				
				if levelname:len() > 16 then
					levelname = $:sub(1,16)..".."
				end
				local map_x = 120*FU+(i*100*FU)
				--ZE2.MapVotes
				
				v.drawScaled(map_x,map_y,votepatchsize,map_patch)
				v.drawString(map_x,map_y-(8*FU),levelname, nil, "thin-fixed")
				v.drawString(map_x+(38*FU),map_y+(60*FU),map_votes, nil, "thin-fixed")
			end

			-- Selection Flicker Code
			if (player["ze2_info"].voted)
				v.drawScaled(-80*FU+((selection)*100*FU),map_y,votepatchsize,cursor_patch)
			else
				if ((leveltime/2)%2 == 0) then 
					v.drawScaled(-80*FU+((selection)*100*FU),map_y,votepatchsize,cursor_patch) 
				else
					v.drawScaled(-80*FU+((selection)*100*FU),map_y,votepatchsize,cursor_patch2) 
				end
			end
			
			v.drawString(160*FU,50*FU,"\x82"..((ZE2.MapVoteStartFrame + ZE2.VoteTimeLimit) - ZE2.win_tics)/TICRATE, (V_SNAPTOTOP), "fixed-center")
		end
	else
		local map_patch = v.cachePatch(G_BuildMapName(ZE2.NextMapVoted).."P")
		local levelname = (mapheaderinfo[ZE2.NextMapVoted].lvlttl)
		v.drawScaled(120*FU,75*FU,votepatchsize,map_patch)
		v.drawString(160*FU,50*FU,"\x82"..levelname.." Was picked as the next map!", (V_SNAPTOTOP), "fixed-center")
	end
	
	for i=-5,5 do
		v.drawScaled((i*128*FU)+(scroll*FU),max(bl.ese,bl.stop*FU),FU,z_bl,V_SNAPTOBOTTOM)
	end
	
	for i=-5,5 do
		v.drawScaled((i*128*FU)-(scroll*FU),min(bu.ese,bu.stop*FU),FU,z_bu,V_SNAPTOTOP)
	end
end