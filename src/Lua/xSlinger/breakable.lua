freeslot("MT_XS_BREAKABLE")

mobjinfo[MT_XS_BREAKABLE] = {
    --$Category xSlinger
	--$Name xSlinger Breakable

    --$Arg0 Health
    --$Arg0Default 100
	--$Arg0Type 0
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

    --$Arg4 Team Restrict
	--$Arg4Default 0
	--$Arg4Type 12
	--$Arg4Enum {1 = "Team 1"; 2 = "Team 2"; 4 = "Team 3"; 8 = "Team 4";}
	--$Arg4Tooltip Which teams can see this interaction?

    --$Arg5 Radius
    --$Arg5Default 64
	--$Arg5Type 23

    --$Arg6 Height
    --$Arg6Default 64
	--$Arg6Type 24

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

xSlinger.breakables = {}
addHook("MapChange", function()
    xSlinger.breakables = {}
end)

addHook("NetVars", function(netcode)
    xSlinger.breakables = netcode(xSlinger.breakables)
end)

addHook("MapThingSpawn", function(mobj, thing)
    if not mobj or not mobj.valid then return end

    mobj.health = thing.args[0]
    mobj.breakable = {
        health = mobj.health,
        triggertag = thing.args[1],
        respawneable = (thing.args[2] == 1) and true or false,
        respawndelay = thing.args[3],
        team_restrict = {enabled = false}
    }

    for index = 0,3 do
		if (thing.args[4] & (1 << index)) then
			mobj.breakable.team_restrict[index + 1] = true
			if not mobj.breakable.team_restrict.enabled then
				mobj.breakable.team_restrict.enabled = true
			end
		end
	end

    mobj.radius = thing.args[5] * FU
    mobj.height = thing.args[6] * FU

    -- add to a linked table
    xSlinger.breakables[mobj.breakable.triggertag] = xSlinger.breakables[mobj.breakable.triggertag] or {}
    table.insert(xSlinger.breakables[mobj.breakable.triggertag], mobj)
end, MT_XS_BREAKABLE)

addHook("MobjFuse", function (mobj) -- respawn
    mobj.health = mobj.breakable.health
    mobj.flags = mobj.flags & ~(MF_NOCLIPTHING)
    mobj.flags = mobj.flags | MF_SHOOTABLE
    mobj.fuse = 0
    return true
end, MT_XS_BREAKABLE)

-- Team checking too.
---@param mobj mobj_t
---@param team integer
---@return boolean
local function CheckBreakable(mobj, team)
    if not mobj or not mobj.valid then return false end

    local breakable = mobj.breakable
    if breakable.team_restrict and breakable.team_restrict.enabled and not breakable.team_restrict[team] then
        return false
    end
    return true
end

--- Either returning false to disallow damage or returning nil to allow damage (not returning true as it despawns the object xd)
---@param mobj mobj_t
---@param inflictor mobj_t?
---@param source mobj_t?
---@param damage integer
---@param damagetype integer
---@return boolean?
xSlinger.addHook("ShouldDamage", function(mobj, inflictor, source, damage, damagetype)
    if not mobj or not mobj.valid then return end
    if (mobj.type ~= MT_XS_BREAKABLE) then return end

	local attacker
	if source and source.valid then
		attacker = source
	elseif inflictor and inflictor.valid then
		attacker = inflictor
    end
    if not attacker or not attacker.valid then return false end

    local player = attacker.player
    if not player or not player.valid then return false end

    local xS = player.xSlinger
    if not CheckBreakable(mobj, xS.team) then return false end
end)

local function HandleLinkedBreakables(mobj) -- so like doors or windows or whatever can be a breakable with having several mobjs pointing to the same linedef
    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index = #breakables, 1, -1 do
        local other = breakables[index]
        if (other == mobj) then continue end
        if (other.breakable == nil) then continue end

        other.flags = other.flags & ~(MF_SHOOTABLE)
        other.flags = other.flags | MF_NOCLIPTHING
        if other.breakable.respawneable then
            other.health = 1
            other.fuse = other.breakable.respawndelay
            continue
        end
        table.remove(breakables, index)
        P_RemoveMobj(other)
    end
end

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
        HandleLinkedBreakables(mobj)
        return true
    end

    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index, other in ipairs(breakables) do
        if (other ~= mobj) then continue end
        table.remove(breakables, index)
        break
    end
    HandleLinkedBreakables(mobj)
    P_RemoveMobj(mobj)
    return true
end, MT_XS_BREAKABLE)