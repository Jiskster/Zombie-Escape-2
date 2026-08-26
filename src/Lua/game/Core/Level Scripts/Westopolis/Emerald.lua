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

-- Make the emerald sparkle
local function EmeraldSparkles(mo, color)
    if not mo or not mo.valid then return end

    local rad = mo.radius / 2
    local x = P_RandomRange(- rad / FU, rad / FU)
    local y = P_RandomRange(- rad / FU, rad / FU)
    local z = P_RandomRange(0, (mo.height / FU) / 3 * 2)

    local sparkle = P_SpawnMobjFromMobj(mo, x * FU, y * FU, z * FU, MT_BOXSPARKLE)
    sparkle.colorized = true
    sparkle.color = color or SKINCOLOR_GREEN
    sparkle.renderflags = sparkle.renderflags | RF_FULLBRIGHT
    P_SetObjectMomZ(sparkle, P_RandomRange(1, 3) * FU)
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
    if ((leveltime % 6) ~= 0) then return end --run this thinker each 10 tics
    if not mobj or not mobj.valid or (mobj.health <= 0) and (mobj.color == nil) then return end

    EmeraldSparkles(mobj, mobj.color)
end, MT_WESTOEMERALD)

--Execute a linedef tag on death
addHook("MobjDeath", function(mobj)
    if not mobj or not mobj.valid then return end
    if (mobj.spawnpoint == nil) then return end

    P_LinedefExecute(mobj.spawnpoint.args[2], mobj, (mobj.subsector ~= nil) and mobj.subsector.sector or nil) --execute from argument 2 ("Linedef Execute Tag")
end, MT_WESTOEMERALD)