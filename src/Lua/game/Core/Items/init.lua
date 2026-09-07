freeslot("S_ZE2_RINGEXPLODE")

-- Optimized version of actions.
-- TODO: Remake items that use this and remove this action override.
function A_RingExplode2(actor, var1, var2)
    local vfx = P_SpawnMobj(actor.x, actor.y, actor.z, MT_THOK)
	P_SetMobjStateNF(vfx, S_TNTBARREL_EXPL1)
	vfx.tics = 2
    vfx.fuse = TICRATE
	vfx.team = actor.team
    actor.state = S_INVISIBLE
	actor.fuse = TICRATE
	actor.flags = $ | MF_NOGRAVITY

    S_StartSound(actor, sfx_prloop)
	P_StartQuake(64 * FU, 10, {x = vfx.x, y = vfx.y, z = vfx.z})

    local real_range = 256 * FU
    local bm_range = real_range * 4
    searchBlockmap("objects", function(refmobj, foundmobj)
		if not (foundmobj.flags & MF_SHOOTABLE) then return end
		if (foundmobj.team == actor.team) then return end

        local dist = R_PointToDist2(0, 0, R_PointToDist2(foundmobj.x, foundmobj.y, actor.x, actor.y), foundmobj.z - actor.z)
        if (dist > FixedMul(real_range, actor.scale)) then return end

        actor.flags2 = actor.flags2 | MF2_DEBRIS
        P_DamageMobj(foundmobj, actor, actor.target, 1, 0)
    end, actor, actor.x - bm_range, actor.x + bm_range, actor.y - bm_range, actor.y + bm_range)
end

states[S_ZE2_RINGEXPLODE] = {SPR_NULL, A, 1, A_RingExplode2, 0, 0, S_XPLD1, 0}

local PATH = "game/Core/Items"

local function dopath(_path)
	dofile(PATH .. "/" .. _path)
end

local function SurvivorItem(_path)
	dopath("Survivor/" .. _path)
end
local function ZombieItem(_path)
	dopath("Zombie/" .. _path)
end

-- Rings
SurvivorItem "red_ring.lua"
SurvivorItem "auto_ring.lua"
SurvivorItem "bounce_ring.lua"
SurvivorItem "scatter_ring.lua"
SurvivorItem "grenade_ring.lua"
SurvivorItem "explosion_ring.lua"
SurvivorItem "rail_ring.lua"
SurvivorItem "flame_ring.lua"
SurvivorItem "accel_ring.lua"

-- Misc
SurvivorItem "blue_spring.lua"
SurvivorItem "wood_fence.lua"
SurvivorItem "apple.lua"
SurvivorItem "energy_drink.lua"
SurvivorItem "amys_heart.lua"
SurvivorItem "auto_turret.lua"

ZombieItem "insta_burst.lua"
ZombieItem "fist.lua"