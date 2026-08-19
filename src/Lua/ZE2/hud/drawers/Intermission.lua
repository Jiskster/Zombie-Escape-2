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

local explosions = {}
local function addExplosion(pos_x, pos_y)
	explosions[#explosions + 1] = {
		x = pos_x;
		y = pos_y;
		frame = 0;
	}
end

local wtics2 = 0 -- for triangle animation

return "Intermission", function(v, player)
	local vote = ZE2.vote
	if not ZE2.game_ended then
		wtics2 = 0
		explosions = {}
		return
	end

	local wtics = ZE2.win_tics
	local team_won = ZE2.team_won

	local team_patch = v.cachePatch("Z_SURVIVORS")
	local win_patch = v.cachePatch("Z_WIN")
	local lower_patch = v.cachePatch("Z_BANG_LOWER_BLUE")
	local upper_patch = v.cachePatch("Z_BANG_UPPER_BLUE")
	local bg_patch = v.cachePatch("Z_BG_BLUE")

	if team_won == 2 then
		team_patch = v.cachePatch("Z_ZOMBIES")
		lower_patch = v.cachePatch("Z_BANG_LOWER_RED")
		upper_patch = v.cachePatch("Z_BANG_UPPER_RED")
		bg_patch = v.cachePatch("Z_BG_RED")
	end

	local end_goals = { -- fixed x values
		team = 20*FU; -- come from the left
		win = 240*FU; -- come from the right
	}

	local anim_time = TICRATE + TICRATE/2
	local diff = anim_time - max(0, anim_time - wtics)
	local div = FixedDiv(diff*FU, anim_time*FU)

	local team_x = ease.outquint(div, end_goals.team - 200*FU, end_goals.team)
	local win_x = ease.outquint(div, end_goals.win + 200*FU, end_goals.win)

	-- Animations for when the triangles appear
	local anim_time2 = 3*TICRATE/2
	local div2 = FixedDiv(min(wtics2*FU,anim_time2*FU), anim_time2*FU)
	local triangle_y = ease.inoutsine(div2, upper_patch.height*FU, 0)
	local bg_ease = ease.inoutsine(div2, 9*FU, 4*FU)

	local newroundframe = ZE2.IntermissionVars.newroundframe
	local newmapframe = ZE2.IntermissionVars.newmapframe
	local slideout_anim = ZE2.IntermissionVars.slideout_anim

	if ZE2.getCurrentRound() == ZE2.getMaxRoundsFromMap() then
		local diff_a = min(max(0, ZE2.win_tics - newroundframe), slideout_anim)
		local div_a = FixedDiv(diff_a*FU, slideout_anim*FU)

		if ZE2.win_tics >= newroundframe then
			team_x = ease.inquint(div_a, end_goals.team, end_goals.team - 300*FU)
			win_x = ease.inquint(div_a, end_goals.win, end_goals.win + 300*FU)
		end
	end

	-- Colored Background
	if wtics >= 100 then
		wtics2 = $ + 1
		v.drawScaled(-500*FU,-500*FU, FU*1000, bg_patch, (bg_ease/FU)<<V_ALPHASHIFT)
	end

	-- Triangle Thingies
	for i=-2,2 do
		local x_movement = ((leveltime*FU)%(lower_patch.width*FU))
		local bottom_x = i*(lower_patch.width*FU) + x_movement
		local bottom_y = ((200*FU)-lower_patch.height*FU) + triangle_y
		local top_x = i*(upper_patch.width*FU) - x_movement
		local top_y = 0 - triangle_y -- could do -triangle_y but this is visually better

		v.drawScaled(top_x, top_y, FU, upper_patch, V_SNAPTOTOP)
		v.drawScaled(bottom_x, bottom_y, FU, lower_patch, V_SNAPTOBOTTOM)
	end

	if ZE2.win_tics >= newroundframe + slideout_anim 
	and not ZE2.NextMapVoted then
		local slideintics = ZE2.win_tics - (newroundframe + slideout_anim)
		
		local elected_maps = vote.maps
		
		local top_text = ("\x82".."VOTE\x80".." to \x85\ELIMINATE\x80".." a map!")
		v.drawString(160, 45, top_text, V_ALLOWLOWERCASE, "thin-center")
		
		if vote.time_left > 0 then
			local timer_text = G_TicsToSeconds(vote.time_left).."."..G_TicsToCentiseconds(vote.time_left).."s"
			v.drawString(160, 20, timer_text, V_SNAPTORIGHT|V_ALLOWLOWERCASE|V_50TRANS, "thin-center")
		end
			
		local pvote = player.ze2.vote
		
		for i=1,#elected_maps do
			local map = elected_maps[i]
			local maptitle = map.num > 0 and G_BuildMapTitle(map.num) or "..."
			local patch = v.cachePatch(G_BuildMapName(map.num).."P")
			local spread = (i-2)*100*FU
			local scale = FU/2
			local x = 160*FU + spread
			local y = 100*FU
			
			x = $ - FixedMul(patch.width*FU, scale)/2
			y = $ - FixedMul(patch.height*FU, scale)/2
			
			-- monitor shit
			local monitor = v.cachePatch("MONITOR_MAP")
			local x2 = x
			local y2 = y
			
			-- trying to fit in monitor
			x2 = $ + FixedMul(FU, scale)
			y2 = $ + FixedMul(5*FU, scale)
			
			-- slide in animation
			local mintics = 40
			local ticoffset = 24
			local div = FixedDiv(slideintics*FU, mintics*FU + (i-1)*FU*ticoffset)
			div = min($, FU)
			local ese = ease.outquint(div, 300*FU, 0)
			
			local spatch = v.cachePatch("VOTE_SELECTION")
			local x3 = x2
			local y3 = y2
			
			local maptitlecolor = "\x88"
			if map.onscreen then
				if map.fuse > 0 then
					maptitlecolor = "\x85"
					
					if (map.fuse % 2) == 0 then
						maptitle = ""
						maptitlecolor = ""
					end
				end
				
				v.drawString(x, y+(58*FU)+ese, maptitlecolor..maptitle, nil, "thin-fixed")
			end
			
			if (pvote.selection == i) then
				-- did this by eye
				x3 = $ + 22*FU
				y3 = $ - 16*FU
				
				y3 = $ + cos(FixedAngle(leveltime*FU*13))*2
				
				local HIT_ANIM_TIME = 12
				if pvote.lasthit ~= nil then
					local timesince = (leveltime - pvote.lasthit)
					
					if (timesince <= HIT_ANIM_TIME) then
						local div_h = FixedDiv(timesince*FU, HIT_ANIM_TIME*FU)
						local ese_h = ease.outquint(div_h, 14*FU, 0)
						local timeleft = (HIT_ANIM_TIME - timesince)
						
						y3 = $ + ese_h
						
						x = $ + (timeleft/2) * (((leveltime % 2) == 0) and -1 or 1) * FU
						x2 = $ + (timeleft/2) * (((leveltime % 2) == 0) and -1 or 1) * FU
					end
				end
			end
			
			if map.health <= 0 and map.num ~= -1 and map.onscreen then
				if (leveltime % 2) == 0 then
					addExplosion(x2 + v.RandomRange(-10,85)*FU, 
								 y2 + v.RandomRange(0,70)*FU)
								 
					S_StartSound(nil, sfx_pop, player)
				end
				
				x = $ + (1) * (((leveltime % 2) == 0) and -1 or 1) * FU
				x2 = $ + (1) * (((leveltime % 2) == 0) and -1 or 1) * FU
			end

			if map.onscreen then
				v.drawScaled(x, y + ese, scale, monitor) -- monitor
				v.drawScaled(x2, y2 + ese, scale, patch) -- level icon
			end
			
			-- check again
			if (pvote.selection == i) then
				v.drawScaled(x3, y3 - ese, FU, spatch) -- evil arrow
			end
		end
	elseif ZE2.NextMapVoted then
		local x = 160*FU
		local y = 100*FU
		local newmap = ZE2.NextMapVoted
		local patch = v.cachePatch(G_BuildMapName(newmap).."P")
		local maptitle = G_BuildMapTitle(newmap)
		local scale = FU/2
		
		-- TODO: This is a copy and paste
		local top_text = ("\x83"..maptitle.."\x80".." has been chosen!")
		v.drawString(160, 45, top_text, V_ALLOWLOWERCASE, "thin-center")
		
		x = $ - FixedMul(patch.width*FU, scale)/2
		y = $ - FixedMul(patch.height*FU, scale)/2
		
		local monitor = v.cachePatch("MONITOR_MAP")
		local x2 = x
		local y2 = y
		
		-- trying to fit in monitor
		x2 = $ + FixedMul(FU, scale)
		y2 = $ + FixedMul(5*FU, scale)
		
		v.drawScaled(x, y, scale, monitor)
		v.drawScaled(x2, y2, scale, patch)
	end
	
	-- Explosion drawing
	if #explosions then
		for i=1,#explosions do
			local explosion = explosions[i]
			
			if explosion then
				local frame = explosion.frame -- 6 frames, starting from 0
				
				if frame < 6 then
					local expl = v.getSpritePatch("BOM1", frame)
					v.drawScaled(explosion.x, explosion.y, FU/2, expl)
				end
				
				if (leveltime % 2) == 0 then
					explosion.frame = $ + 1
				end
				
				if explosion.frame >= 6 then
					table.remove(explosions, i)
				end
			end
		end
	end
	
	-- "Survivors Win" | "Zombies Win"
	v.drawScaled(team_x, 100*FU, FU, team_patch)
	v.drawScaled(win_x, 100*FU, FU, win_patch)
end