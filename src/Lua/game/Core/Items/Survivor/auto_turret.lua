local LASER_KNOCKBACK = 12*FRACUNIT

freeslot("MT_ZE2_AUTOTURRET", "S_ZE2_AUTOTURRET")

mobjinfo[MT_ZE2_AUTOTURRET] = {
	spawnhealth = 70,
	spawnstate = S_ZE2_AUTOTURRET,
	painsound = sfx_dmpain,
	painchance = 192*FRACUNIT,
	deathstate = S_RINGEXPLODE,
	deathsound = sfx_pop,
	radius = 32*FU,
	height = 64*FU,
	flags = MF_SHOOTABLE|MF_SPECIAL,
}

mobjinfo[MT_ZE2_AUTOTURRET].npc_name = "Auto Turret"

states[S_ZE2_AUTOTURRET] = {
	sprite = SPR_TRET,
	frame = A,
	tics = -1,
	nextstate = S_ZE2_AUTOTURRET
}

local missile_laser = xSlinger.registerMissile("LASER", {
	speed = 30*FRACUNIT,
	displayname = "Laser",
	state = S_TURRETLASER,
	deathstate = S_TURRETLASEREXPLODE1,
	deathsound = sfx_turhit,
})

freeslot("MT_PLACEMENT_CHECK")

addHook("MobjLineCollide", function(check, line)
	return false
end, MT_PLACEMENT_CHECK)

addHook("MobjMoveCollide", function(check, mobj)
	if not check or not check.valid then return end
	if (mobj.type == MT_ZE2CHECKPOINT) then return true end
	if (mobj.flags & MF_SPRING) and ZE2.ZCollide(check, mobj) then return true end
	if not (mobj.flags & MF_SOLID) then return false end
	if not ZE2.ZCollide(check, mobj) then return false end
	if mobj.player and mobj.player.valid then
		if (mobj.team == check.target.team) then return false end
	end
	return true
end, MT_PLACEMENT_CHECK)

---@param mobj mobj_t
---@param mobjtype mobjtype_t
local function PlacementCheck(mobj, mobjtype)
	if not P_IsObjectOnGround(mobj) then return false end

	local distance = 50 * FU
	local x = mobj.x + FixedMul(distance, cos(mobj.angle))
	local y = mobj.y + FixedMul(distance, sin(mobj.angle))
	local z = mobj.z
	local check = P_SpawnMobj(x, y, z, MT_PLACEMENT_CHECK)
	check.target = mobj
	check.height = mobjinfo[mobjtype].height
	check.radius = mobjinfo[mobjtype].radius
	check.scale = FU
	check.flags2 = MF2_DONTDRAW
	check.alpha = 0
	check.fuse = 2

	if not P_CheckPosition(check, x, y) then return false end
	if (check.floorz < (mobj.z - check.height)) then return false end
	if (check.floorz > (mobj.z + mobj.height)) then return false end
	if (check.ceilingz < (check.z + check.height)) then return false end
	return true
end

---@param self any
---@param mobj mobj_t
local function PlacementVisual(self, mobj, mobjtype)
	local distance = 50 * FU
	local x = mobj.x + FixedMul(distance, cos(mobj.angle))
	local y = mobj.y + FixedMul(distance, sin(mobj.angle))
	local z = mobj.z

	local visual = mobj.visual_placement
	if not visual or not visual.valid then
		visual = P_SpawnMobj(x, y, z, MT_ZVISUAL)
		mobj.visual_placement = visual
	end

	local valid = PlacementCheck(mobj, mobjtype)
	visual.height = mobjinfo[mobjtype].height
	visual.radius = mobjinfo[mobjtype].radius
	visual.momx = mobj.momx
	visual.momy = mobj.momy
	visual.momz = mobj.momz
	visual.sprite = states[mobjinfo[mobjtype].spawnstate].sprite
	visual.frame = states[mobjinfo[mobjtype].spawnstate].frame|FF_ADD
	visual.angle = mobj.angle
	P_MoveOrigin(visual, x, y, z)

	local color = valid and SKINCOLOR_TURQUOISE or SKINCOLOR_RED
	visual.color = color
	visual.colorized = true
	visual.drawonlyforplayer = mobj.player
	visual.alpha = FU / 2
	visual.fuse = 3
end

xSlinger.registerItem("auto_turret", {
	displayname = "Automatic Turret";

	icon = "TURRETIND";

	count = 1;
	maxcount = 12;

	firerate = 18*TICRATE;
	turret_tics = 18*TICRATE;

	sounds = {
		use = sfx_jshard;
	};

	dropstate = S_ZE2_AUTOTURRET;
	dropscale = (2*FU/3);
	dropyoffset = 16*FU;

	holdfunc = function(self, mobj)
		PlacementVisual(self, mobj, MT_ZE2_AUTOTURRET)
	end;

	usefunc = function(self, mo)
		if not PlacementCheck(mo, MT_ZE2_AUTOTURRET) then return true end

		local x = mo.x + cos(mo.angle)*50
		local y = mo.y + sin(mo.angle)*50
		local z = mo.z

		local turret = P_SpawnMobj(x, y, z, MT_ZE2_AUTOTURRET)
		turret.team = mo.team
		turret.angle = mo.angle
		turret.target = mo
		turret.turretfuse = self:get("turret_tics", mo.skin)
	end
})

addHook("TouchSpecial", function(_,__)
	return true
end, MT_ZE2_AUTOTURRET)

local function searchPlayers(turret)
	local lastdist = INT32_MAX
	local chosetracer
	for player in players.iterate do
		local pmo = player.mo

		if not (pmo and pmo) then
			continue end;

		local dist = R_PointToDist2(turret.x, turret.y, pmo.x, pmo.y)

		if (pmo.team == turret.team) then
			continue end;

		if not (pmo.health) then
			continue end;

		if dist > 1536*FU then
			continue end;

		if not P_CheckSight(turret, pmo) then
			continue end;

		if dist < lastdist then
			lastdist = dist
			turret.tracer = pmo
			chosetracer = pmo
		end
	end

	return chosetracer
end

local MAX_POWERUP = 3*TICRATE
local MAX_FIRING = 3*TICRATE
local POWERUP_SOUND = sfx_trpowr
local POWERUP_VOLUME = 95

addHook("MobjThinker", function(turret)
	if turret.health <= 0 then
		return end;

	if turret.turretfuse then
		turret.turretfuse = $ - 1
		if not turret.turretfuse then
			P_KillMobj(turret)
			return
		end
	end

	local at = turret.autoturret

	if at.powerup then
		at.powerup = $ - 1

		if not at.powerup then
			at.firing = MAX_FIRING
		end
	end

	if at.firing then
		at.firing = $ - 1

		if not at.firing then
			at.powerup = MAX_POWERUP

			S_StartSoundAtVolume(turret, POWERUP_SOUND, POWERUP_VOLUME)
		end
	end

	local tracer = searchPlayers(turret)

	if tracer and tracer.valid then
		local angletotracer = R_PointToAngle2(turret.x, turret.y, tracer.x, tracer.y)

		if not (at.powerup) and not (at.firing) then
			at.powerup = MAX_POWERUP

			S_StartSoundAtVolume(turret, POWERUP_SOUND, POWERUP_VOLUME)
		end

		if at.firing > 0 then
			if (leveltime % 2) == 0 then
				local shot = xSlinger.SpawnMissile({
					source = turret,
					type = "LASER",
					angle = turret.angle,
					damage = 4,
					forceknockback = LASER_KNOCKBACK,
					relativeknockback = true,
				})

				S_StartSound(turret, sfx_trfire)
				
				turret.angle = angletotracer + P_RandomRange(-6, 6)*ANG1
			end
		end
	elseif not at.powerup then
		at.firing = 0

		at.powerup = MAX_POWERUP

		S_StartSoundAtVolume(turret, POWERUP_SOUND, POWERUP_VOLUME)
	end
end, MT_ZE2_AUTOTURRET)

addHook("MobjSpawn", function(turret)
	turret.autoturret = {
		powerup = 0,
		firing = 0,
	}
end, MT_ZE2_AUTOTURRET)
