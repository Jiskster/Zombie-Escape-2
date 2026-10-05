freeslot("S_ZE2_THROWNSPLASH1", "S_ZE2_THROWNSPLASH2", "S_ZE2_SPLASH_DROP", "S_ZE2_SPLASHBOOM", "SPR_RNGP")
freeslot("sfx_rs_spl", "sfx_rs_sp2")

local A_SplashBoom = function(mo)
	for j = 1, 3 do
		local amtbubbles = 8 * j
		for i = 0, amtbubbles do
			local fa = i*(ANGLE_180/amtbubbles)*2
			
			local mobj = xSlinger.SpawnMissile({
				source = mo.target,
				type = "SPLASH_RING_AOE",
				angle = 0,
				aiming = 0,
				iteminfo = mo.iteminfo,
				origin = mo,
				damage = 2,
			})
			
			if mobj and mobj.valid then
				mobj.destscale = mobj.scale * 2
				mobj.sprite = SPR_BUBL
				mobj.frame = $ + (B | FF_FULLBRIGHT)
				mobj.fuse = 15 + (j * 2) + (i % 2)
				mobj.tics = mobj.fuse
				
				mobj.momz = FixedMul(sin(fa),mo.scale * (5 * j))
				P_InstaThrust(mobj, mo.angle+ANGLE_90,FixedMul(cos(fa),mo.scale * (5 * j)))
			end
		end
	end
end

states[S_ZE2_THROWNSPLASH1] = {
	nextstate = S_ZE2_THROWNSPLASH2,
	sprite = SPR_RNGP,
	frame = FF_FULLBRIGHT,
	tics = 1,
}

states[S_ZE2_THROWNSPLASH2] = {
	nextstate = S_ZE2_THROWNSPLASH1,
	sprite = SPR_RNGP,
	frame = FF_FULLBRIGHT|1,
	tics = 1,
}

states[S_ZE2_SPLASHBOOM] = {
	tics = TICRATE,
	action = A_SplashBoom
}

states[S_ZE2_SPLASH_DROP] = {
	nextstate = S_ZE2_SPLASH_DROP,
	sprite = SPR_RNGP,
	frame = FF_FULLBRIGHT,
	tics = -1,
}

local function bubbleWobble(bubble)
	bubble.spritexscale = ((FU*3)/2) + cos(FixedAngle(leveltime*ANG2))/10
	bubble.spriteyscale = ((FU*3)/2) + sin(FixedAngle(leveltime*ANG2))/10
end

xSlinger.registerEffect("bubble.float", {
	max_duration = 2*TICRATE,
	tick = function(effect, mobj, time_left)
		P_SetObjectMomZ(mobj, FU/2)
		
		if not (mobj.bubblefloat and mobj.bubblefloat.valid) then
			mobj.bubblefloat = P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_THOK)
			local bubblefloat = mobj.bubblefloat
			
			bubblefloat.fuse = 4
			bubblefloat.state = S_EXTRALARGEBUBBLE
			
			bubbleWobble(bubblefloat)
			
			bubblefloat.tics = -1
		else
			P_MoveOrigin(mobj.bubblefloat, mobj.x, mobj.y, mobj.z)
			local bubblefloat = mobj.bubblefloat
			bubblefloat.fuse = 4
			
			bubbleWobble(bubblefloat)
		end
	end,
})

local missile_splash_ring = 
xSlinger.registerMissile("SPLASH_RING", {
	speed = 90*FRACUNIT,
	displayname = "Splash Ring",
	state = S_ZE2_THROWNSPLASH1,
	deathstate = S_ZE2_SPLASHBOOM,
	deathsound = sfx_rs_sp2,
	externaldeathsound = true,
	tick = function(self, pmo, mo)
		mo.momx = $ * 94/100
		mo.momy = $ * 94/100
		mo.momz = $ * 94/100
	end
})

local missile_splash_ring_aoe = 
xSlinger.registerMissile("SPLASH_RING_AOE", {
	speed = 0,
	displayname = "Splash Ring",
	state = S_THOK,
	addflags = MF_SLIDEME,
	safeground = true,
	tick = function(self, pmo, mo)
		mo.momx = $ * 96/100
		mo.momy = $ * 96/100
		mo.momz = $ * 96/100
	end,
})

xSlinger.registerItem("splash_ring", {
	displayname = "Splash Ring",
	
	icon = "SPLASHIND",
	
	missile = "SPLASH_RING",
	
	dropstate = S_ZE2_SPLASH_DROP;
	
	color = SKINCOLOR_GOLD,
	
	sounds = {
		use = sfx_rs_spl,
		reload = {sfx_xsrel1, sfx_xsrel2},
		pickup = sfx_None,
		drop = sfx_None,
	},
	
	hold_object = {
		state = S_ZE2_SPLASH_DROP;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU;
			y = FU/2;
			z = 0;
		};
		pos_anim = {
			x = -FU;
			y = (FU*3)/2;
			z = -FU/3;
		};
	};
	
	ammo = 4,

	reload_time = 3*TICRATE,
	
	firerate = 20,

	fuse = TICRATE,
	
	damage = 88,
	
	hitfunc = function(self, src, mo, inf)
		if not mo and not mo.valid then return end
		
		mo:give_effect("bubble.float", {
			normalspeed_multiplier = (FU*3)/4,
			actionspd_multiplier = 3*FU/2,
		}, TICRATE, true)
		
		mo.momx = $ * 7/10
		mo.momy = $ * 7/10
	end,
	
	animation_time = TICRATE,
})