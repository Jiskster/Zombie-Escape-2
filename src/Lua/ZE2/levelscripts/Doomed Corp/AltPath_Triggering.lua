local DoomedCorp = {
    pathunlock_timer = 0
}
addHook("NetVars", function(net)
    if gamemap != 14 then return end
    DoomedCorp = net($)
end)
local function ResetValues()
    DoomedCorp.pathunlock_timer = 0
end
addHook("MapLoad", ResetValues)
addHook("MapChange", ResetValues)

local drawScaled
local drawString

local function OpenAltPath(v, p)
    if gamemap != 14 then return end
    if not (p.mo and p.mo.skin) then return end

    if drawScaled == nil then drawScaled = v.drawScaled end
    if drawString == nil then drawString = v.drawString end

    if DoomedCorp.pathunlock_timer and p.xSlinger.team == 2 then
        local anim
        if DoomedCorp.pathunlock_timer >= TICRATE*2 then anim = 1
        else anim = 2 end

        local openingpath = v.cachePatch("OPENPATH0"..anim)
        local zomb = v.getSprite2Patch(p.mo.skin, SPR2_WALK, false, C, 3)
        local zomb_color = v.getColormap(p.skin, p.mo.color or SKINCOLOR_GREEN, p.mo.translation)
        local flags = V_SNAPTOTOP|V_PERPLAYER
        
        local posx = 140
        local posy = 57
        drawString(posx+22, (posy-40), "Path unlocked!", flags|V_YELLOWMAP, "center")
        drawScaled(posx*FU, posy*FU, FU/2, zomb, flags|V_FLIP, zomb_color)
        drawScaled((posx+15)*FU, (posy-30)*FU, FU/2, openingpath, flags, zomb_color)
    end
	
	if DoomedCorp.pathunlock_timer then DoomedCorp.pathunlock_timer = $-1 end
end
addHook("HUD", OpenAltPath)

addHook("LinedefExecute", function()
    DoomedCorp.pathunlock_timer = TICRATE*3
    P_LinedefExecute(16)
end, "DC_OPENPATH")