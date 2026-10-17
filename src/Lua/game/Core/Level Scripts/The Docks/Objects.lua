-- [[ ORB Holder ]] --

freeslot("MT_ORBHOLDER")

mobjinfo[MT_ORBHOLDER] = {
    --$Title Orb Holder
    --$Sprite BGARA1
    --$Category The Docks
    --$Color 2
    --$Arg0 Color
    --$Arg0Type 11
    --$Arg0Default 0
    --$Arg0Enum { 1="Yellow"; 2="Green"; 3="Blue";}
    --$Arg0ToolTip "Sets the color of the orb holder and the orb itself"
    doomednum = 11001,
    spawnstate = S_GARGOYLE,
    radius = 20 * FU,
    height = 40 * FU,
    flags = MF_SOLID|MF_SCENERY
}

local orbholder_colors = {
    [1] = {"thedocks_orbholder_yellow", D}, -- translation, frame (from the nights orb)
    [2] = {"thedocks_orbholder_green", C},
    [3] = {"thedocks_orbholder_blue", E}
}

addHook("MapThingSpawn", function(mo, thing)
    local argcolor = thing.args[0]

    -- Set up the orb holder's specific sprite and 
    mo.sprite = SPR_BGAR -- I'm afraid to use Azure Gargoyle's state
    mo.translation = orbholder_colors[argcolor][1]

    -- The Orb on top
    local orb = P_SpawnMobjFromMobj(mo, 0, 0, mobjinfo[mo.type].height + 5 * FU, MT_THOK)
    orb.sprite = SPR_IDYA
    orb.renderflags = $|RF_FULLBRIGHT
    orb.tics = -1
    orb.frame = orbholder_colors[argcolor][2]
end, MT_ORBHOLDER)

-- [[ Barrel ]] --

freeslot("MT_TDOCKS_BARREL", "SPR_THEDOCKS_BARREL")

mobjinfo[MT_TDOCKS_BARREL] = {
    --$Title Barrel
    --$Sprite BARRA1
    --$Category The Docks
    --$Color 2
    doomednum = 11002,
    spawnstate = S_GARGOYLE,
    radius = 24 * FU,
    height = 65 * FU,
    flags = MF_SOLID|MF_SCENERY
}

addHook("MobjSpawn", function(mo)
    mo.sprite = SPR_THEDOCKS_BARREL
end, MT_TDOCKS_BARREL)
