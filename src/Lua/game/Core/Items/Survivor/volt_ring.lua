local explode_radius = 250 * FU

freeslot("MT_ARAZ", "S_ARAZ", "SPR_ARAZ")
freeslot("S_ZE2_VOLTRING", "S_ZE2_VOLTRING_DEATH", "SPR_RNGV")

local function spawnLine(mobj, angle, dist)
	local t = P_SpawnMobjFromMobj(mobj, cos(angle)*dist, sin(angle)*dist, 0, MT_ARAZ)
	t.angle = angle + ANGLE_90
	t.momx = cos(angle)*48
	t.momy = sin(angle)*48
	
	t.blendmode = AST_ADD
	t.color = SKINCOLOR_BLUE
end

local function giveElectricEffect(mobj)
	mobj:give_effect("volt_electric", {
		normalspeed_multiplier = (FU*8)/10,
		knockback_multiplier = 3*FU,
		actionspd_multiplier = FU/4,
		damage_multiplier = FU*2,
	}, 4*TICRATE, true)
end

mobjinfo[MT_ARAZ] = {
	spawnstate = S_ARAZ,
	radius = 24*FU,
	height = 32*FU,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPTHING|MF_NOCLIPHEIGHT,
}

states[S_ARAZ] = {
	sprite = SPR_ARAZ,
	frame = A|FF_PAPERSPRITE|FF_FULLBRIGHT,
	tics = 42,
}

states[S_ZE2_VOLTRING] = {
	sprite = SPR_RNGV,
	frame = A|FF_FULLBRIGHT|FF_ANIMATE,
	tics = -1,
	var1 = 7,
	var2 = 2,
}

states[S_ZE2_VOLTRING_DEATH] = {
	sprite = SPR_NULL,
	tics = 10,
	action = function(mo)
		local linecount = 32
		for i=1,linecount do
			local a = mo.angle + FixedAngle(FixedDiv(360, linecount)*i)
			
			spawnLine(mo, a, 32)
		end
		
		local xpld_radius = FixedMul(mo.scale, explode_radius)
		searchBlockmap("objects", function(refmo, foundmobj)
			if not foundmobj.health then return end
			if not (foundmobj.flags & MF_SHOOTABLE) then return end
			if (foundmobj.team == mo.team) then return end

			local dist = R_PointToDist2(mo.x, mo.y, foundmobj.x, foundmobj.y)
			local distz = R_PointToDist2(mo.z, mo.z, foundmobj.z, foundmobj.z)
			if (dist > xpld_radius or distz > xpld_radius) then return end
			if not P_CheckSight(mo, foundmobj) then return end

			giveElectricEffect(foundmobj)

			P_DamageMobj(foundmobj, mo, mo.target, 1, 0) -- Damage any mobj around.
		end, mo,
		mo.x - xpld_radius, mo.x + xpld_radius,
		mo.y - xpld_radius, mo.y + xpld_radius)

		P_StartQuake(32 * FU, TICRATE/2, {x = mo.x, y = mo.y, z = mo.z})
	end,
}

addHook("MobjThinker", function(mobj)
	mobj.momx = FixedMul($, (FU*8)/10)
	mobj.momy = FixedMul($, (FU*8)/10)
	
	mobj.alpha = FixedMul($, (FU*7)/10)
	mobj.spriteyscale = FixedMul($, (FU*13)/10)
	mobj.spritexscale = FixedMul($, (FU*11)/10)
	
	mobj.angle = $ + ANG1*mobj.tics
end, MT_ARAZ)

xSlinger.registerEffect("volt_electric", {
	max_duration = 8 * TICRATE,
	tick = function(effect, mobj, time_left)
		if mobj and mobj.valid then
			if not (time_left % 24) then
				S_StartSound(mobj, sfx_beelec)
			end
			
			if not (time_left & 12) then
				local ov = P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_OVERLAY)
				ov.sprite = SPR_ELEC
			end
		end
	end;
})

local missile_volt_ring =
xSlinger.registerMissile("VOLT_RING", {
	state = S_ZE2_VOLTRING,
	deathstate = S_ZE2_VOLTRING_DEATH,
	deathsound = sfx_s3k79,
	externaldeathsound = true,
	displayname = "Volt Ring",
	speed = 15*FU,
	delflags = MF_NOGRAVITY,
	tick = function(self, pmo, missile)
		P_SetObjectMomZ(missile, -3*FU, true)
		
		if not (leveltime % 3) then
			local ghost = P_SpawnGhostMobj(missile)
			ghost.fuse = 15
			ghost.blendmode = AST_ADD
		end
	end,
})

xSlinger.registerItem("volt_ring", {
	
	-- HUD

	displayname = "Volt Ring",
	icon = "VOLTIND",
	animation_time = 20;
	
	-- Missile Properties
	
	color = SKINCOLOR_BLUE,
	
	-- Item Properties
	
	damage = 180,
	dropstate = S_ZE2_VOLTRING;
	ammo = 2,
	firerate = 6*TICRATE,
	reload_time = 8*TICRATE,
	sounds = {
		use = sfx_s3k45,
		reload = {sfx_xsrel1, sfx_xsrel2},
		pickup = sfx_None,
		drop = sfx_None,
	},
	usefunc = function(self, mobj)
		local missile =
		xSlinger.SpawnMissile({
			source = mobj,
			type = "VOLT_RING",
			angle = mobj.angle,
			aiming = mobj.player.aiming,
			allow_aim = true,
			iteminfo = self,
		})
		
		if missile and missile.valid then
			P_SetObjectMomZ(missile, 40*FU)
		end
	end,
	onhit = function(self, src, mo, inf)
		if not mo and not mo.valid then return end
		giveElectricEffect(mo)
	end,
	hold_object = {
		state = S_ZE2_VOLTRING;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU,
			y = FU/2,
			z = 0,
		};
		pos_anim = {
			x = -FU,
			y = (FU*3)/2,
			z = -FU/3,
		},
	},
})