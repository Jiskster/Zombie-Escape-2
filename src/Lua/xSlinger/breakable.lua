freeslot("MT_XS_BREAKABLE")

mobjinfo[MT_XS_BREAKABLE] = {
    --$Category xSlinger
	--$Name xSlinger Breakable

    --$Arg0 Health
    --$Arg0Default 100
	--$Arg0Type 15
	--$Arg0Tooltip The amount of health this breakable will initially have.

    --$Arg1 Trigger Tag
	--$Arg1Default 0
	--$Arg1Type 15
	--$Arg1Tooltip The tag to be called when the breakable is destroyed.

    --$Arg2 Respawneable
    --$Arg2Default 0
    --$Arg2Type 11
    --$Arg2Tooltip If this breakable should respawn after being broken.
    --$Arg2Enum { 0 = "No"; 1 = "Yes"; }

    --$Arg3 Respawn Delay
    --$Arg3Default 0
	--$Arg3Type 0
	--$Arg3Tooltip The amount of wait in tics before this breakable respawn (if enabled).

    --$Arg4 Radius
    --$Arg4Default 64
	--$Arg4Type 23

    --$Arg5 Height
    --$Arg5Default 64
	--$Arg5Type 24

    --$NotAngled

    doomednum = 50600,

	spawnhealth = 1000,

	spawnstate = S_INVISIBLE,
	deathstate = S_INVISIBLE,
	radius = 64*FU,
	height = 64*FU,
	flags = MF_NOGRAVITY|MF_SHOOTABLE,
}
mobjinfo[MT_XS_BREAKABLE].antiknockback = true
mobjinfo[MT_XS_BREAKABLE].nodamagetext = true

addHook("MapThingSpawn", function(mobj, thing)
    if not mobj or not mobj.valid then return end

    mobj.health = thing.args[0]
    mobj.breakable = {
        health = mobj.health,
        triggertag = thing.args[1],
        respawneable = (thing.args[2] == 1) and true or false,
        respawndelay = thing.args[3]
    }
    mobj.radius = thing.args[4] * FU
    mobj.height = thing.args[5] * FU
end, MT_XS_BREAKABLE)

addHook("MobjFuse", function (mobj)
    mobj.health = mobj.breakable.health
    mobj.flags = mobj.flags & ~(MF_NOCLIPTHING)
    mobj.flags = mobj.flags | MF_SHOOTABLE
    mobj.fuse = 0
    return true
end, MT_XS_BREAKABLE)

addHook("MobjDeath", function(mobj, inflictor, source, damagetype)
    if not mobj or not mobj.valid then return end

    local player
    if  inflictor.player then
        player = inflictor
    elseif source.player then
        player = source
    end

    if not player or not player.valid then return end

    P_LinedefExecute(mobj.breakable.triggertag, player)

    mobj.flags = mobj.flags & ~(MF_SHOOTABLE)
    mobj.flags = mobj.flags | MF_NOCLIPTHING
    if mobj.breakable.respawneable then
        mobj.health = 1
        mobj.fuse = mobj.breakable.respawndelay
    end

    return true
end, MT_XS_BREAKABLE)