--Object definition
freeslot("MT_WESTOEMERALD")
mobjinfo[MT_WESTOEMERALD] = {
    --$Title Chaos Emerald (Trigger)
	--$Sprite CEMGA0
	--$Category Westopolis
    --$Arg0 Emerald Color
    --$Arg0Type 11
    --$Arg0Default 0
    --$Arg0Enum { 0="Green"; 1="Purple"; 2="Blue"; 3="Cyan"; 4="Orange"; 5="Red"; 6="Gray"; 7="Random"; }
    --$Arg0ToolTip "Sets the color of the emerald from the defined list"
    --$Arg1 Sparkle?
    --$Arg1Type 11
    --$Arg1Enum yesno
    --$Arg1Default yes
    --$Arg1ToolTip "Make the emerald drop sparkles?"
    --$Arg2 Linedef Execute Tag
    --$Arg2ToolTip "Tag to execute when touching the emerald"
	--$Color 7
    doomednum = 4200,
    spawnstate = S_CEMG1,
    deathstate = S_SPRK1,
    deathsound = sfx_ncitem,
    radius = 16*FRACUNIT,
    height = 24*FRACUNIT,
    flags = MF_NOGRAVITY|MF_SPECIAL
} -- UZB moment

--color: for the sparkles
--frame: to change the CEMG frame
local Emerald = {
    [0] = {color = SKINCOLOR_EMERALD, frame = A},
    [1] = {color = SKINCOLOR_SIBERITE, frame = B},
    [2] = {color = SKINCOLOR_SAPPHIRE, frame = C},
    [3] = {color = SKINCOLOR_AQUAMARINE, frame = D},
    [4] = {color = SKINCOLOR_GOLDENROD, frame = E},
    [5] = {color = SKINCOLOR_GARNET, frame = F},
    [6] = {color = SKINCOLOR_BLUEBELL, frame = G}
}

--Replica of A_GoldMonitorSparkle but colorized and for advanced usage
--
--var1 = color
--var2 = radius
---@param actor mobj_t
---@param var1 skincolornum_t
---@param var2 fixed_t
function A_GoldMonitorSparkleColor(actor, var1, var2)
    if not actor or not actor.valid then return end

    local angle = FixedAngle(((leveltime * 21) % 360) * FRACUNIT)
    local offsetx = P_ReturnThrustX(actor, angle, var2 or actor.radius)
    local offsety = P_ReturnThrustY(actor, angle, var2 or actor.radius)
    for index = FRACUNIT, FRACUNIT * 2, FRACUNIT / 2 do
        local sparkle = P_SpawnMobjFromMobj(actor, offsetx, offsety, 0, MT_BOXSPARKLE)
        sparkle.colorized = true
        sparkle.color = var1 or SKINCOLOR_GREEN
        sparkle.renderflags = sparkle.renderflags | RF_FULLBRIGHT
        P_SetObjectMomZ(sparkle, index, false)
    end
end

-- Set the emerald frame and sparkles color from desired thing arguments
addHook("MapThingSpawn", function(mobj, thing)
    local emerald_argcolor
    if (thing.args[0] == 7) then -- if argument 0 is 7 ("Random"), randomize through the emerald table
        emerald_argcolor = P_RandomRange(0, #Emerald)
    else
        emerald_argcolor = thing.args[0]
    end

    mobj.frame = Emerald[emerald_argcolor].frame -- set the emerald sprite
    mobj.renderflags = mobj.renderflags | RF_FULLBRIGHT

    if (thing.args[1] == 0) then -- 0 means "yes" in argument 1, set the emerald color
        mobj.color = Emerald[emerald_argcolor].color
    end
end, MT_WESTOEMERALD)

-- Spawn Emerald Sparkles if desired
addHook("MobjThinker", function(mobj)
    if ((leveltime % 10) ~= 0) then return end --run this thinker each 10 tics
    if not mobj or not mobj.valid or (mobj.health <= 0) and (mobj.color == nil) then return end

    A_GoldMonitorSparkleColor(mobj, mobj.color, mobj.radius/3)
end, MT_WESTOEMERALD)

--Execute a linedef tag on death
addHook("MobjDeath", function(mobj)
    if not mobj or not mobj.valid then return end
    if (mobj.spawnpoint == nil) then return end

    P_LinedefExecute(mobj.spawnpoint.args[2], mobj, (mobj.subsector ~= nil) and mobj.subsector.sector or nil) --execute from argument 2 ("Linedef Execute Tag")
end, MT_WESTOEMERALD)