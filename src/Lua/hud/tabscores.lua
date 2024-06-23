ZE2.tabscores = function(v)
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

    for i,p in ipairs(ZE2.SurvivorList())
        i = $-1
        local x,y = 20*FU,24*FU+(32*FU/3*i)
        --1 guy gets cut off lololol
        if i > 29
            continue
        elseif i > 14
            x = $+(75*FU)
            y = $-(32*FU/3*15)
        end

        local skin = skins[p.skin].name
        local color = v.getColormap(skin,p.realmo.color)
        local name = string.sub(p.name,1,15)
        v.drawScaled(x,
            y,
            FU/3,     
            v.getSprite2Patch(skin, SPR2_XTRA),
            V_SNAPTOTOP,
            color
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y,
            name,
            "STCFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            (p == consoleplayer) and SKINCOLOR_YELLOW or SKINCOLOR_BLUE
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y+4*FU,
            "+"..p.mo.health.."/"..p.mo.maxhealth,
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            SKINCOLOR_GREEN
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y+8*FU,
            "Rubies: "..p["ze2_info"].rubies,
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            SKINCOLOR_RED
        )

        local rubielength = customhud.CustomFontStringWidth(v,
            "Rubies:  "..p["ze2_info"].rubies,
            "TNYFC",
            FU/2
        )

        customhud.CustomFontString(v,
            x+16*FU+rubielength,
            y+8*FU,
            p == server and "SERVER" or p.ping.."ms",
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            p == server and SKINCOLOR_BLUE or p.ping < 128 and SKINCOLOR_GREEN or (p.ping < 256 and SKINCOLOR_YELLOW or SKINCOLOR_RED)
        )
    end

    for i,p in ipairs(ZE2.ZombieList())
        i = $-1
        local x,y = 180*FU,24*FU+(32*FU/3*i)
        --1 guy gets cut off lololol
        if i > 29
            continue
        elseif i > 14
            x = $+(75*FU)
            y = $-(32*FU/3*15)
        end

        local skin = skins[p.skin].name
        local color = v.getColormap(skin,p.realmo.color)
        local name = string.sub(p.name,1,15)
        v.drawScaled(x,
            y,
            FU/3,     
            v.getSprite2Patch(skin, SPR2_XTRA),
            V_SNAPTOTOP,
            color
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y,
            name,
            "STCFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            (p == consoleplayer) and SKINCOLOR_YELLOW or SKINCOLOR_RED
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y+4*FU,
            "+"..p.mo.health.."/"..p.mo.maxhealth,
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            SKINCOLOR_GREEN
        )

        customhud.CustomFontString(v,
            x+12*FU,
            y+8*FU,
            p["ze2_info"].zombie_type,
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            p.mo.color
        )

        local rubielength = customhud.CustomFontStringWidth(v,
            p["ze2_info"].zombie_type.." ",
            "TNYFC",
            FU/2
        )

        customhud.CustomFontString(v,
            x+16*FU+rubielength,
            y+8*FU,
            p == server and "SERVER" or p.ping.."ms",
            "TNYFC",
            V_SNAPTOTOP,
            nil,
            FU/2,
            p == server and SKINCOLOR_BLUE or p.ping < 128 and SKINCOLOR_GREEN or (p.ping < 256 and SKINCOLOR_YELLOW or SKINCOLOR_RED)
        )
    end

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

end