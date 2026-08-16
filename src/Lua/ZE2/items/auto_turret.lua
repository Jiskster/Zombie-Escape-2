local LASER_KNOCKBACK = FRACUNIT

freeslot("MT_ZE2_AUTOTURRET", "S_ZE2_AUTOTURRET")

mobjinfo[MT_ZE2_AUTOTURRET] = {
	spawnhealth = 150,
	spawnstate = S_ZE2_AUTOTURRET,
	painsound = sfx_dmpain,
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

local missile_laser = 
xSlinger.registerMissile("LASER", {
	speed = 30*FRACUNIT,
	displayname = "Laser",
	state = S_TURRETLASER,
	deathstate = S_TURRETLASEREXPLODE1,
	deathsound = sfx_turhit,
})

xSlinger.registerItem("auto_turret", {
	displayname = "Automatic Turret";
	
	icon = "TURRETIND";
	
	firerate = 30*TICRATE;
	turret_tics = 30*TICRATE; -- make same as firerate (or not idk)
	
	sounds = {
		use = sfx_jshard;
	};
	
	usefunc = function(self, mo)
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
local MAX_FIRING = 7*TICRATE
local POWERUP_SOUND = sfx_trpowr

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
			
			S_StartSound(turret, POWERUP_SOUND)
		end
	end
	
	local tracer = searchPlayers(turret)
	
	if tracer and tracer.valid then
		local angletotracer = R_PointToAngle2(turret.x, turret.y, tracer.x, tracer.y)
		
		if not (at.powerup) and not (at.firing) then
			at.powerup = MAX_POWERUP

			S_StartSound(turret, POWERUP_SOUND)
		end
		
		turret.angle = angletotracer
		
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
			end
		end
	elseif not at.powerup then
		at.firing = 0
		
		at.powerup = MAX_POWERUP
		
		S_StartSound(turret, POWERUP_SOUND)
	end
end, MT_ZE2_AUTOTURRET)

addHook("MobjSpawn", function(turret)
	turret.autoturret = {
		powerup = 0,
		firing = 0,
	}
end, MT_ZE2_AUTOTURRET)
