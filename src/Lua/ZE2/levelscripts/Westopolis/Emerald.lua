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
    spawnstate = mobjinfo[MT_EMERALD1].spawnstate,
    deathstate = S_SPRK1,
    deathsound = sfx_ncitem,
    radius = 9*FU,
    height = 25*FU,
    flags = MF_NOGRAVITY|MF_SPECIAL
}

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

--Replica of A_GoldMonitorSparkle but colorized
function A_GoldMonitorSparkleColor(actor, var1)
    if not (actor and actor.valid) then return end

    local ngangle = FixedAngle(((leveltime * 21) % 360) * FRACUNIT)
    local xofs = P_ReturnThrustX(actor, ngangle, actor.radius)
    local yofs = P_ReturnThrustY(actor, ngangle, actor.radius)

    for i = FRACUNIT, 2*FRACUNIT, FRACUNIT/2 do
        local sparkle = P_SpawnMobjFromMobj(actor, xofs, yofs, 0, MT_BOXSPARKLE)
        sparkle.colorized = true
        sparkle.color = var1
        sparkle.renderflags = $|RF_FULLBRIGHT
        P_SetObjectMomZ(sparkle, i, false)
    end
end

--Set the emerald frame and sparkles color from desired thing arguments
local function EmeraldSpawnBehavior(mo, thing)
    local emerald_argcolor

    --if arg0 is 7 ("Random"), randomize through the emerald table.
    if thing.args[0] == 7 then emerald_argcolor = P_RandomRange(0, #Emerald) else emerald_argcolor = thing.args[0] end

    mo.frame = Emerald[emerald_argcolor].frame --set emerald sprite
    mo.renderflags = $|RF_FULLBRIGHT

    if thing.args[1] == 0 then --0 is "yes" in the argument
        mo.emmy_sparklecolor = Emerald[emerald_argcolor].color --set emerald color
    end
end

--Spawn Emerald Sparkles if desired
local function EmeraldSparkles(mo)
    if not (leveltime % 10 == 0) then return end --run this thinker each 10 tics
    if not (mo.valid and mo.health and mo.emmy_sparklecolor) then return end

    A_GoldMonitorSparkleColor(mo, mo.emmy_sparklecolor)
end

--Execute a linedef tag on death
local function EmeraldTrigger(mo)
    A_LinedefExecuteFromArg(mo, 2) --execute from argument 2 ("Linedef Execute Tag")
end

addHook("MapThingSpawn", EmeraldSpawnBehavior, MT_WESTOEMERALD)
addHook("MobjThinker", EmeraldSparkles, MT_WESTOEMERALD)
addHook("MobjDeath", EmeraldTrigger, MT_WESTOEMERALD)