freeslot("MT_M_MUSHROOM", "SPR_GKMU", "S_M_MUSHROOM")

states[S_M_MUSHROOM] = {SPR_GKMU, A, -1, nil, 0, 0, S_M_MUSHROOM}
mobjinfo[MT_M_MUSHROOM] = {
    --$Title Mario Mushroom
    --$Sprite GKMUA0
    --$Category Zombio Bros
    --$Arg0 Color
    --$Arg0Type 11
    --$Arg0Enum {0="Green"; 1="Red"; 2="Blue"; 3="Purple";}
    --$Arg0Default 1
    --$Arg0ToolTip Color of the mushroom to use
    doomednum = 10001,
    spawnstate = S_M_MUSHROOM,
    radius = 40*FU,
    height = 100*FU,
    flags = MF_NOTHINK|MF_SCENERY
}

local colors = {
    [0] = SKINCOLOR_GREEN,
    [1] = SKINCOLOR_RED,
    [2] = SKINCOLOR_BLUE,
    [3] = SKINCOLOR_PURPLE,
}

addHook("MapThingSpawn", function(mo, thing)
    mo.color = colors[thing.args[0]] or SKINCOLOR_GREEN
end, MT_M_MUSHROOM)