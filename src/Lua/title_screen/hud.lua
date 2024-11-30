local function HUD_RandomSkin(num)
	if num == 0
		return "sonic"
	elseif num == 1
		return "tails"
	elseif num == 2
		return "knuckles"
	elseif num == 3
		return "amy"
	elseif num == 4
		return "fang"
	elseif num == 5
		return "metalsonic"
	end
end

hud.add(function(v)
	-- This code sucks man. but I tried lol
	if not v.titletics
		v.titletics = 0
	end
	
	if v
		v.titletics = $+1
	end

	local ze2logo1 = v.cachePatch("ZE2_TTL00")
	local title_xoffset = 25*FU
	local title_yoffset = 15*FU
	local title_timetoappear = 1*TICRATE
	
	local drawtics_frame1 = 2
	local drawtics_frame2 = 4
	local drawtics_frame3 = 6
	local drawtics_frame4 = 8
	
	if v.titletics >= title_timetoappear and v.titletics <= (title_timetoappear+drawtics_frame1)
		local ze2logo1 = v.cachePatch("ZE2_TTL00")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo1)
	elseif v.titletics >= (title_timetoappear+drawtics_frame1) and v.titletics <= (title_timetoappear+drawtics_frame2)
		local ze2logo2 = v.cachePatch("ZE2_TTL01")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo2)
	elseif v.titletics >= (title_timetoappear+drawtics_frame2) and v.titletics <= (title_timetoappear+drawtics_frame3)
		local ze2logo3 = v.cachePatch("ZE2_TTL02")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo3)
	elseif v.titletics >= (title_timetoappear+drawtics_frame3) and v.titletics <= (title_timetoappear+drawtics_frame4)
		local ze2logo4 = v.cachePatch("ZE2_TTL03")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo4)
	elseif v.titletics >= (title_timetoappear+drawtics_frame4)
		local ze2logo5 = v.cachePatch("ZE2_TTL04")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo5)
	end
	
	/* [UNUSED]
	if not v.playerrunspeed
		v.playerrunspeed = 0
	end
	
	-- Players running even in the hud lol
	local runanim = (leveltime/(2*(3/2))) % (skins["sonic"].sprites[SPR2_WALK_].numframes)
	local playerscale = FU*(3/2)
	
	if not v.playersset
		v.survivor_skin = HUD_RandomSkin(v.RandomRange(0,5))
		v.survivor_color = v.getColormap(nil,v.RandomRange(1,158))
		local hud_alphachance = v.RandomChance(FU/8)
		if hud_alphachance == true
			v.zombie_color = v.getColormap(nil,SKINCOLOR_ALPHAZOMBIE)
			v.zombie_scale = FU*(3/2)
		else
			v.zombie_color = v.getColormap(nil,SKINCOLOR_MOSS)
			v.zombie_scale = playerscale
		end

		v.playersset = 1
	end
	local hud_survivor = v.getSprite2Patch(v.survivor_skin, SPR2_WALK, false, runanim, 3)
	local hud_zombie = v.getSprite2Patch("zzombie", SPR2_WALK, false, runanim, 3)
	
	if v.titletics >= 2*TICRATE
		v.h_surv = v.drawScaled(-80*FU+v.playerrunspeed, 197*FU, playerscale, hud_survivor, V_SNAPTOBOTTOM|V_FLIP, v.survivor_color)
		v.h_zomb = v.drawScaled(-190*FU+v.playerrunspeed, 197*FU, v.zombie_scale, hud_zombie, V_SNAPTOBOTTOM|V_FLIP, v.zombie_color)
		v.player_startmoving = 1		
		if v.player_startmoving == 1
			v.playerrunspeed = $+(5*FU)
		end
	end
	if v.titletics == 5*TICRATE
		S_StartSound(nil, sfx_wtsig2, nil)
	end
	*/
end,"title")

hud.add(function(v, stplyr, cam)
	if v
		v.titletics = 0 --reset timer when not on title screen
		v.playersset = 0
		v.playerrunspeed = 0
	end
end, "game")