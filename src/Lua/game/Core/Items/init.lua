freeslot("S_ZE2_RINGEXPLODE")

-- Optimized version of actions.
-- TODO: Remake items that use this and remove this action override.
function A_RingExplode2(actor, var1, var2)
    local vfx = P_SpawnMobj(actor.x, actor.y, actor.z, MT_THOK)
    vfx._override_tnt_explode = true
    vfx.state = S_TNTBARREL_EXPL1
    vfx.fuse = TICRATE
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

function A_TNTExplode(actor, var1, var2)
    if not actor._override_tnt_explode then
        super(actor, var1, var2)
    end
end

-- The missile itself is invisible, you have to spawn a visible indicator when it stops on something.
function ZE2.registerCrosshairGuide(refid)
	local ref = xSlinger.registered_missiles[refid]
	
	if not ref then
		error("invalid missile id")
	end
	
	local m = xSlinger.registerMissile(refid.."_GUIDE", {
		state = S_INVISIBLE,
		speed = ref.speed,
		displayname = ref.displayname,
		radius = ref.radius,
		height = ref.height,
		addflags = MF_NOCLIPTHING,
		delflags = MF_NOGRAVITY,
	})
	
	return m
end

function ZE2.drawCrosshairGuide(mobj, id, alpha)
	if mobj.player and mobj.player.valid then
		local shot = xSlinger.SpawnMissile({
			source = mobj,
			type = id,
			angle = mobj.angle,
			aiming = mobj.player.aiming,
			allow_aim = true,
		})
		
		local x
		local y
		local z
		local valid
		
		if shot and shot.valid then	
			shot.fuse = 3

			for i = 1, 128 do
				P_XYMovement(shot)
				
				if not (shot and shot.valid) then
					break
				end
				
				P_ZMovement(shot)
				
				if not (shot and shot.valid) then
					break
				end
				
				x = shot.x
				y = shot.y
				z = shot.z
				valid = true
				
				if (shot.z == shot.floorz) or (shot.z + shot.height) == shot.ceilingz then
					shot.momx = 0
					shot.momy = 0
					shot.momz = 0
					break
				end
			end
			
			if valid then
				if not (mobj.crossguide and mobj.crossguide.valid) then
					local t = P_SpawnMobj(x, y, z, MT_UNKNOWN)
					t.sprite = SPR_TARG
					t.fuse = 2
					t.tics = -1
					t.alpha = alpha or FU
					t.drawonlyforplayer = mobj.player
					
					mobj.crossguide = t
				else
					local t = mobj.crossguide
					t.fuse = 2
					t.tics = -1
					t.alpha = alpha or FU
					t.drawonlyforplayer = mobj.player
					
					P_MoveOrigin(t, x, y, z)
				end
			end
		end
	end
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
SurvivorItem "splash_ring.lua"

-- Misc
SurvivorItem "blue_spring.lua"
SurvivorItem "wood_fence.lua"
SurvivorItem "apple.lua"
SurvivorItem "energy_drink.lua"
SurvivorItem "amys_heart.lua"
SurvivorItem "auto_turret.lua"

ZombieItem "insta_burst.lua"
ZombieItem "fist.lua"
ZombieItem "blood_bomb.lua"