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

-- [[ Secret Blue key ]] --

rawset(_G, "secret_showtime", 0)

addHook("NetVars", function(net)
    secret_showtime = net($)
end)

freeslot("MT_TDOCKS_BLUEKEY", "MT_TDOCKS_BLUEKEYHOLD", "SPR_THEDOCKS_BLUEKEY", "sfx_scthah", "sfx_sctopn")

mobjinfo[MT_TDOCKS_BLUEKEY] = {
    doomednum = -1,
    spawnstate = S_TEAMRING,
    deathsound = sfx_zelda,
    radius = 30 * FU,
    height = 30 * FU,
    flags = MF_SPECIAL|MF_NOGRAVITY
}

addHook("MobjSpawn", function(mo)
    mo.sprite = SPR_THEDOCKS_BLUEKEY
    mo.renderflags = $|RF_FULLBRIGHT
end, MT_TDOCKS_BLUEKEY)

addHook("TouchSpecial", function(mo, toucher)
    toucher.tdocks_has_key = true
    local keyhold = P_SpawnMobjFromMobj(toucher, 0, 0, 0, MT_TDOCKS_BLUEKEYHOLD)
    keyhold.target = toucher
    CONS_Printf(toucher.player, "You got the ".."\x84".."Blue Key!")
end, MT_TDOCKS_BLUEKEY)

-- You got it! the key will orbit around you now.

mobjinfo[MT_TDOCKS_BLUEKEYHOLD] = {
    doomednum = -1,
    spawnstate = S_TEAMRING,
    speed = 4 * FU,
    radius = 20 * FU,
    height = 30 * FU,
    flags = MF_SCENERY|MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING
}

addHook("MobjSpawn", function(mo)
    mo.sprite = SPR_THEDOCKS_BLUEKEY
    mo.renderflags = $|RF_FULLBRIGHT
    mo.spriteyoffset = - 17 * FU
end, MT_TDOCKS_BLUEKEYHOLD)

addHook("MobjThinker", function(mo)
    if not (mo and mo.valid) then return end
    local t = mo.target

    if not (t and t.valid and t.tdocks_has_key) then
        P_RemoveMobj(mo)
        return
    end

    A_RotateSpikeBall(mo, 0, 0)
end, MT_TDOCKS_BLUEKEYHOLD)

-- Spawn The key at random position in the map.

-- Idk how to use map thing spawners to randomize the spawn
-- But it's better this way so players don't figure out via map editor loll.
local key_positions = {
    [1] = {x = -6400, y = 512, z = -192},
    [2] = {x = -5686, y = 2180, z = -96},
    [3] = {x = 736, y = 3520, z = -8},
    [4] = {x = 1440, y = -672, z = 16},
    [5] = {x = -1248, y = 1376, z = 168}
}

addHook("MapLoad", function(map)
    if (map ~= 58) then return end

    local keypos = key_positions[P_RandomRange(1, #key_positions)]

    P_SpawnMobj(keypos.x * FU, keypos.y * FU, keypos.z * FU, MT_TDOCKS_BLUEKEY)
end)

-- Secret activation

-- Arg 1: Linedef to trigger when a player activates the secret
addHook("LinedefExecute", function(line, mo)
    local line_exec = line.args[0] or 0

    if mo.tdocks_has_key then
        P_LinedefExecute(line_exec)
        secret_showtime = 5 * TICRATE
        mo.tdocks_has_key = false
    end
end, "BLUEDOOR")

-- "A secret has been revealed!" hud msg

addHook("ThinkFrame", function()
    if not secret_showtime then return end
    secret_showtime = $ - 1
end)

addHook("HUD", function(v)
    if not secret_showtime then return end
    v.drawString(160, 20, "A secret has been revealed!", V_ALLOWLOWERCASE|V_GREENMAP, "thin-center")
end)
