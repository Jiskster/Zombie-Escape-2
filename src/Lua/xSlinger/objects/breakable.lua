---@diagnostic disable: inject-field, undefined-field
freeslot("MT_XS_BREAKABLE")

mobjinfo[MT_XS_BREAKABLE] = {
    --$Category xSlinger
	--$Name xSlinger Breakable
    --$Sprite TVTUC0

    --$Arg0 Health
    --$Arg0Default 100
	--$Arg0Type 0
	--$Arg0Tooltip The amount of health this breakable will initially have.

    --$Arg1 Death Trigger Tag
	--$Arg1Default 0
	--$Arg1Type 15
	--$Arg1Tooltip The tag to be called when the breakable is destroyed.

    --$Arg2 Damage Trigger Tag
	--$Arg2Default 0
	--$Arg2Type 15
	--$Arg2Tooltip The tag to be called when the breakable is damaged.

    --$Arg3 Respawn Trigger Tag
	--$Arg3Default 0
	--$Arg3Type 15
	--$Arg3Tooltip The tag to be called when the breakable is damaged.

    --$Arg4 Respawneable
    --$Arg4Default 0
    --$Arg4Type 11
    --$Arg4Tooltip If this breakable should respawn after being broken.
    --$Arg4Enum { 0 = "No"; 1 = "Yes"; }

    --$Arg5 Respawn Delay
    --$Arg5Default 0
	--$Arg5Type 0
	--$Arg5Tooltip The amount of wait in tics before this breakable respawn (if enabled).

    --$Arg6 Visible Health?
    --$Arg6Default 0
    --$Arg6Type 11
    --$Arg6Tooltip If this breakable should display it's health on HUD.
    --$Arg6Enum { 0 = "No"; 1 = "Yes"; }

    --$Arg7 Team Restrict
	--$Arg7Default 0
	--$Arg7Type 12
	--$Arg7Enum {1 = "Team 1"; 2 = "Team 2"; 4 = "Team 3"; 8 = "Team 4";}
	--$Arg7Tooltip Which teams can see this interaction?

    --$Arg8 Radius
    --$Arg8Default 32
	--$Arg8Type 23

    --$Arg9 Height
    --$Arg9Default 64
	--$Arg9Type 24

    --$StringArg0 Display Text
    --$StringArg0Tooltip If set, it will show it on HUD. Only visible when Visible Health is enabled.

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
        damage_triggertag = thing.args[2],
        respawn_triggertag = thing.args[3],
        respawneable = (thing.args[4] == 1) and true or false,
        respawn_delay = thing.args[5],
        visible_health = (thing.args[6] == 1) and true or false,
        team_restrict = {enabled = false}
    }

    for index = 0, 3, 1 do
		if (thing.args[7] & (1 << index)) then
			mobj.breakable.team_restrict[index + 1] = true
			if not mobj.breakable.team_restrict.enabled then
				mobj.breakable.team_restrict.enabled = true
			end
		end
	end

    mobj.radius = thing.args[8] * FU
    mobj.height = thing.args[9] * FU

    mobj.npc_visiblehealth = mobj.breakable.visible_health
    if thing.stringargs[0] then
        mobj.npc_displayname = thing.stringargs[0]
    end

    -- add to a linked table
    xSlinger.breakables[mobj.breakable.triggertag] = xSlinger.breakables[mobj.breakable.triggertag] or {}
    table.insert(xSlinger.breakables[mobj.breakable.triggertag], mobj)
end, MT_XS_BREAKABLE)

---@param mobj mobj_t
local function RespawnLinkedBreakables(mobj) -- link the hp from other breakables with the same tag
    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index = #breakables, 1, -1 do
        local other = breakables[index]
        if (other == mobj) then continue end
        if (other.breakable == nil) then continue end

        other.health = mobj.health
        other.npc_visiblehealth = mobj.npc_visiblehealth
        other.flags = mobj.flags
        other.fuse = mobj.fuse
    end
end

addHook("MobjFuse", function (mobj) -- respawn
    mobj.health = mobj.breakable.health
    mobj.npc_visiblehealth = mobj.breakable.visiblehealth
    mobj.flags = mobj.info.flags
    mobj.fuse = 0
    if (mobj.breakable.respawn_triggertag > 0) then
        P_LinedefExecute(mobj.breakable.respawn_triggertag, nil, (mobj.subsector ~= nil) and mobj.subsector.sector or nil)
    end
    RespawnLinkedBreakables(mobj)
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
    if not CheckBreakable(mobj, attacker.team) then return false end
end, MT_XS_BREAKABLE)

---@param mobj mobj_t
local function AlterLinkedBreakables(mobj) -- link the hp from other breakables with the same tag
    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index = #breakables, 1, -1 do
        local other = breakables[index]
        if (other == mobj) then continue end
        if (other.breakable == nil) then continue end

        other.health = mobj.health
    end
end

---@param mobj mobj_t
---@param inflictor mobj_t?
---@param source mobj_t?
---@param damage integer
---@param damagetype integer
xSlinger.addHook("MobjDamage", function(mobj, inflictor, source, damage, damagetype)
    if not mobj or not mobj.valid then return end
    if (mobj.type ~= MT_XS_BREAKABLE) then return end

    if (mobj.breakable.damage_triggertag > 0) then
        P_LinedefExecute(mobj.breakable.damage_triggertag, source or inflictor, (mobj.subsector ~= nil) and mobj.subsector.sector or nil)
    end
    AlterLinkedBreakables(mobj)
end)

---@param mobj mobj_t
local function RemoveLinkedBreakables(mobj) -- so like doors or windows or whatever can be a breakable with having several mobjs pointing to the same linedef
    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index = #breakables, 1, -1 do
        local other = breakables[index]
        if (other == mobj) then continue end
        if (other.breakable == nil) then continue end

        other.flags = MF_NOGRAVITY|MF_NOCLIPTHING
        if other.breakable.respawneable then
            other.health = 1
            other.npc_visiblehealth = false
            other.fuse = other.breakable.respawn_delay
            continue
        end
        table.remove(breakables, index)
        P_RemoveMobj(other)
    end
end

addHook("MobjDeath", function(mobj, inflictor, source, damagetype)
    if not mobj or not mobj.valid then return end

    local attacker
	if source and source.valid then
		attacker = source
	elseif inflictor and inflictor.valid then
		attacker = inflictor
    end
    if not attacker or not attacker.valid then return false end

    local player = attacker.player
    if not player or not player.valid then return false end

    if (mobj.breakable.triggertag > 0) then
        P_LinedefExecute(mobj.breakable.triggertag, attacker, (mobj.subsector ~= nil) and mobj.subsector.sector or nil)
    end

    mobj.flags = MF_NOGRAVITY|MF_NOCLIPTHING
    if mobj.breakable.respawneable then
        mobj.health = 1
        mobj.npc_visiblehealth = false
        mobj.fuse = mobj.breakable.respawn_delay
        RemoveLinkedBreakables(mobj)
        return true
    end

    local breakables = xSlinger.breakables[mobj.breakable.triggertag]
    for index, other in ipairs(breakables) do
        if (other ~= mobj) then continue end
        table.remove(breakables, index)
        break
    end
    RemoveLinkedBreakables(mobj)
    P_RemoveMobj(mobj)
    return true
end, MT_XS_BREAKABLE)