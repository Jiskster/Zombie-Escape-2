-- [[ Item properties ]] --

local explode_radius = 315 * FU
local health_cost = 350
local bomb_health = 100
local blind_time = TICRATE * 7

-- [[ The item itself ]] --

freeslot("S_BLOODBOMB", "S_BLOODBOMB_DEATH", "sfx_bbmis")

sfxinfo[sfx_bbmis] = {
    singular = true,
    priority = 128,
    flags = SF_X2AWAYSOUND|SF_NOMULTIPLESOUND
}

states[S_BLOODBOMB] = {SPR_DRAB, FF_FULLBRIGHT|D, -1, function(mo) -- Properties on spawn
	mo.colorized = true
end, 0, 0, S_BLOODBOMB}

states[S_BLOODBOMB_DEATH] = {SPR_NULL, A, 1, function(mo) -- Explode within a radius setted by explode_radius local
	local xpld_radius = FixedMul(mo.scale, explode_radius)

	searchBlockmap("objects", function(refmo, foundmobj)
		if not (foundmobj.flags & MF_SHOOTABLE) then return end
		if (foundmobj.team == mo.team) then return end

		local dist = R_PointToDist2(mo.x, mo.y, foundmobj.x, foundmobj.y)
		local distz = R_PointToDist2(mo.z, mo.z, foundmobj.z, foundmobj.z)
		if (dist > xpld_radius or distz > xpld_radius) then return end
		if not P_CheckSight(mo, foundmobj) then return end

		if foundmobj.player then -- Blind players
			foundmobj.bloodbomb_blindtime = blind_time
			S_StartSound(nil, sfx_prloop, foundmobj.player)
		end

		P_DamageMobj(foundmobj, mo, mo.target, 1, 0) -- Damage any mobj around.
	end, mo,
	mo.x - xpld_radius, mo.x + xpld_radius,
	mo.y - xpld_radius, mo.y + xpld_radius)

	P_StartQuake(64 * FU, TICRATE, {x = mo.x, y = mo.y, z = mo.z})

	A_OldRingExplode(mo, MT_DUST, 0) -- TODO: Change it to blood particles instead...? maybe adapt blood droplets for this.
end, 0, 0, S_NULL}

-- Register it

local xsmissile_bloodbomb =
xSlinger.registerMissile("BLOOD_BOMB", {
	speed = 52*FRACUNIT,
	displayname = "Blood Bomb",
	state = S_BLOODBOMB,
	deathstate = S_BLOODBOMB_DEATH,
	deathsound = sfx_brakrx,
	externaldeathsound = true,
	radius = 20*FU,
	height = 40*FU,
	health = bomb_health,
	antiknockback = true,
	addflags = MF_SHOOTABLE,
	delflags = MF_NOGRAVITY|MF_NOBLOCKMAP,
})

local xsmissile_bloodbomb_guide = 
ZE2.registerCrosshairGuide(xsmissile_bloodbomb.id)

local function spawnVFX(mo, color)
	local x = P_RandomRange(- mo.radius / FU, mo.radius / FU)
	local y = P_RandomRange(- mo.radius / FU, mo.radius / FU)
	local z = P_RandomRange(0, (mo.height / FU) / 3 * 2)

	local infectparticle = P_SpawnMobjFromMobj(mo, x * FU, y * FU, z * FU, MT_THOK)
	infectparticle.state = S_SPINBOBERT_FIRE_TRAIL1
	infectparticle.colorized = true
	infectparticle.color = color or mo.color
	infectparticle.blendmode = AST_SUBTRACT
	infectparticle.renderflags = RF_FULLBRIGHT
	infectparticle.tics = 10
	P_SetObjectMomZ(infectparticle, P_RandomRange(2, 5) * FU)
	
	return infectparticle
end

xSlinger.registerItem("blood_bomb", {

	-- HUD

	displayname = "Blood Bomb";
	icon = "BLOODBOMBIND",
	background_color = SKINCOLOR_CRIMSON,
	animation_time = TICRATE/2;

	-- Missile properties

	color = SKINCOLOR_ALPHAZOMBIE; -- Originally was using player's color but should make sense to use a fixed red color instead.
	missile = "BLOOD_BOMB",
    firerate = 15 * TICRATE;
	damage = 10;
	droppable = false;

	sounds = {
		use = sfx_s1ae;
	};

	usefunc = function(self, mo)
		if not mo and mo.valid then return end

		if mo.health <= health_cost then -- Kill the zombie directly if they throw the bomb with less than required.
			P_KillMobj(mo)
			return
		end

		mo.health = $ - health_cost -- Heh don't use this as a survivor lol
		S_StartSound(mo, skins[mo.skin].soundsid[SKSPLPAN2] or sfx_none)
	end;

	missile_tick = function(self, mo, missile) -- Code of infection vfx.
		if (leveltime % 3 == 0) then return end
		if not (missile and missile.valid) then return end
		
		spawnVFX(missile)
	end;
	
	missile_spawn = function(self, mo, missile)
		S_StartSound(missile, sfx_bbmis)
	end,
	
	holdfunc = function(self, mobj)
		ZE2.drawCrosshairGuide(mobj, xsmissile_bloodbomb_guide.id, FU/2)
	end,
})

-- [[ Explode blindness behavior ]] --

addHook("PlayerThink", function(p)
	local mo = p.mo
	if not (mo and mo.valid) then return end
	if not mo.bloodbomb_blindtime then return end

	mo.bloodbomb_blindtime = $ - 1
	
	local infectparticle = spawnVFX(mo, SKINCOLOR_ALPHAZOMBIE)
	if infectparticle and infectparticle.valid then
		infectparticle.alpha = min(FixedDiv(mo.bloodbomb_blindtime, 3*TICRATE), FU)
	end
	
	if not CV_FindVar("showhud").value then -- Nu uh cheater!
		COM_BufInsertText(p, "showhud 1") -- we are calling it each tic yes, but we aren't filling the netxcmd buffer so.
	end
end)

customhud.SetupItem("blood_bombfade", "zombie_tweaks", function(v)
	if consoleplayer.mo and consoleplayer.mo.bloodbomb_blindtime then
		local mo = consoleplayer.mo
		v.fadeScreen(42, min(10, 12 * mo.bloodbomb_blindtime / blind_time))
	end
end, "gameandscores") -- Love you customhud lib for allowing game and scores drawing at the same time.
