local hudtype = "scores"

local function DrawTeammate(v,p, x,y, props)
	local teamcolor = props.teamcolor
	local scale = props.scale or FU
	local drawcash = props.drawcash
	local longnames = props.longnames
	
	local flags = V_SNAPTOTOP
	if (p.quittime and (leveltime/TICRATE % 2)) then flags = $|V_50TRANS end
	
	local skin = p.skin
	local color = v.getColormap(skin,p.realmo.color)
	local name = string.sub(p.name,1, (longnames and 24 or 15))
	local skinpatch = v.getSprite2Patch(skin, SPR2_XTRA)
	if skinpatch == v.getSprite2Patch(skin, SPR2_STND) then
		-- wait, that's not a real icon
		skinpatch = v.cachePatch("CHARICO")
	end
	
	local icon_adjust = FixedMul(32*FU, FixedMul(FU/3, scale))
	local maxhealth = p.mo.maxhealth or "???"
	
	v.drawScaled(x, y,
		FixedMul(FU/3, scale),     
		skinpatch,
		flags,
		color
	)
	
	----name
	customhud.CustomFontString(v,
		x + icon_adjust, y,
		name,
		"STCFC",
		flags,
		nil,
		FixedMul(FU/2, scale),
		(p == consoleplayer) and SKINCOLOR_YELLOW or teamcolor
	)
	----
	
	----health
	customhud.CustomFontString(v,
		x + icon_adjust,
		y + 4*scale,
		"+"..p.mo.health.."/"..maxhealth,
		"TNYFC",
		flags,
		nil,
		FixedMul(FU/2, scale),
		SKINCOLOR_GREEN
	)
	if p.mo.shield_health and p.mo.shield_def then
		local healthstring_width = customhud.CustomFontStringWidth(v,  " +"..p.mo.health.."/"..maxhealth, "TNYFC", FixedMul(FU/2, scale))
		local shield_color = p.mo.shield_def.color or SKINCOLOR_WHITE
		
		local shield_health = tostring(p.mo.shield_health)
		customhud.CustomFontString(v,
			x + icon_adjust + healthstring_width,
			y + 4*scale,
			"@ "..shield_health,
			"TNYFC",
			flags,
			nil,
			FixedMul(FU/2, scale),
			shield_color
		)
	end
	----
	
	----cash
	--yes i know its "ruby" not "rubie"
	local rubiestring = ''
	local rubiecolor
	if drawcash
		rubiestring = "$ "..p.ze2.cash
		rubiecolor = SKINCOLOR_FOREST
	else
		rubiestring = p.ze2.zombie_type
		rubiecolor = p.mo.color
	end
	customhud.CustomFontString(v,
		x + icon_adjust,
		y + 8*scale - FU,
		rubiestring,
		"TNYFC",
		flags,
		nil,
		FixedMul(FU/2, scale),
		rubiecolor
	)
	
	local rubielength = customhud.CustomFontStringWidth(v,
		rubiestring.." ",
		"TNYFC",
		FixedMul(FU/2, scale)
	)
	----
	
	--haha
	local pingas = (p.quittime) and "QUIT" or (p.ping.."ms")
	--triple tenary
	local pingcolor = (p.quittime) and SKINCOLOR_RED or (p.ping < 128 and SKINCOLOR_GREEN or (p.ping < 256 and SKINCOLOR_YELLOW or SKINCOLOR_RED))
	customhud.CustomFontString(v,
		x + icon_adjust + rubielength + 4*scale,
		y + 8*scale - FU,
		p == server and "SERVER" or pingas,
		"TNYFC",
		flags,
		nil,
		FixedMul(FU/2, scale),
		p == server and SKINCOLOR_BLUE or pingcolor
	)
end

return "Tabscores", function(v)
 	local timeemb = v.cachePatch("NGRTIMER")
	local the_time 
	
	if ZE2.round_active then
		if ZE2.time_limit then
			the_time = G_TicsToMTIME(ZE2.time_limit - ZE2.game_time)
		else
			the_time = G_TicsToMTIME(ZE2.game_time)
		end
	else
		the_time = G_TicsToMTIME(ZE2.pregame_timeleft)
	end

    if the_time ~= nil then
        -- Time
        customhud.CustomFontString(v, 150, 1, the_time, "STCFC", 
        (V_SNAPTOTOP), nil , nil, SKINCOLOR_BEIGE)
        
        -- Clock Icon
        v.drawScaled(138*FRACUNIT, 0, FRACUNIT,
        timeemb, (V_SNAPTOTOP))
    end
    
    v.drawFill(160,25,1,158,0|V_SNAPTOTOP)

    customhud.CustomFontString(v,
        80*FU,
        5*FU,
        "Survivors",
        "STCFC",
        V_SNAPTOTOP,
        "center",
        FU,
        SKINCOLOR_BLUE
    )
    v.drawStretched(
        (80-8)*FU,
        15*FU,
		
        16*FU,
        6*FU,
		
        v.cachePatch("Z_BG_BLUE"), 
        V_SNAPTOTOP
    )
    customhud.CustomFontString(v,
        79,
        14,
        tostring(ZE2.SurvivorCount()),
        "STCFC", 
        (V_SNAPTOTOP),
        "center",
        nil,
        SKINCOLOR_BLUE
    )

	
    customhud.CustomFontString(v,
        240*FU,
        5*FU,
        "Zombies",
        "STCFC",
        V_SNAPTOTOP,
        "center",
        FU,
        SKINCOLOR_RED
    )
    v.drawStretched(
        (240-8)*FU,
        15*FU,
		
        16*FU,
        6*FU,
		
        v.cachePatch("Z_BG_RED"), 
        V_SNAPTOTOP
    )
    customhud.CustomFontString(v,
        239,
        14,
        tostring(ZE2.ZombieCount()),
        "STCFC", 
        (V_SNAPTOTOP),
        "center",
        nil,
        SKINCOLOR_RED
    )
	
	local team_maxrows = 15
	local team_hugerows = 10
	local team_hugesize = FU*3/2
	
	local SurvivorList = ZE2.SurvivorList()
	local team_scale = #SurvivorList <= team_hugerows and team_hugesize or FU 
    for i,p in ipairs(SurvivorList)
        i = $-1
        local x,y = 20*FU, 24*FU + ((32*team_scale/3) * i)
        --1 guy gets cut off lololol
        if i > 29
            continue
        elseif i >= team_maxrows
            x = $+(75*FU)
            y = $-(32*team_scale/3 * team_maxrows)
        end
		
		DrawTeammate(v,p, x,y, {
			teamcolor = SKINCOLOR_BLUE,
			drawcash = true,
			scale = team_scale,
			longnames = (team_scale ~= FU),
		})
    end

	local ZombieList = ZE2.ZombieList()
	team_scale = #ZombieList <= team_hugerows and team_hugesize or FU 
    for i,p in ipairs(ZombieList)
        i = $-1
        local x,y = 180*FU, 24*FU + ((32*team_scale/3) * i)
        --1 guy gets cut off lololol
        if i > 29
            continue
        elseif i >= team_maxrows
            x = $+(75*FU)
            y = $-(32*team_scale/3 * team_maxrows)
        end
		
		DrawTeammate(v,p, x,y, {
			teamcolor = SKINCOLOR_RED,
			scale = team_scale,
			longnames = (team_scale ~= FU),
		})
	end

	-- draw rounds
	local current_round = ZE2.getCurrentRound()
	local max_rounds = ZE2.getMaxRoundsFromMap()
	local roundcount_text = current_round .. " / " .. max_rounds
	local rc_yoffset = 0
	
	if CV_FindVar("showfps").value then
		rc_yoffset = $ - 8
	end	
	
	v.drawString(320, 200 - 16 + rc_yoffset, "\x82".."ROUNDS", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right")
	v.drawString(320, 200 - 8  + rc_yoffset, roundcount_text , V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right")

    --draw spectators
    local i
    local length,height = 0, 174
    local totallength,totalheight = 0,0
    local offset = 0

    for p in players.iterate
        if not (p.spectator) then continue end
        totallength = $+(customhud.CustomFontStringWidth(v,
            p.name,
            "STCFC",
            FU
        )/FU) + 16
    end
    if totallength == 0 then return end

    length = $-(leveltime % (totallength+320))
    length = $+320

    for p in players.iterate
        if not (p.spectator) then continue end
		
        customhud.CustomFontString(v,
            length+offset,
            185,
            p.name,
            "STCFC", 
            (V_TRANSLUCENT|V_SNAPTOTOP),
            "left",
            nil,
            SKINCOLOR_SILVER
        )
		
        offset = $+(
        customhud.CustomFontStringWidth(v,
            p.name,
            "STCFC",
            FU
        )/FU) + 16
    end
end, (hudtype)