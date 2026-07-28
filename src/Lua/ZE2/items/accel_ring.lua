freeslot("S_ZE2_THROWNACCEL", "S_ZE2_THROWNACCEL2", "S_ZE2_THROWNACCEL_HOLD")
freeslot("SPR_RNGC")
freeslot("sfx_rs_cro")

states[S_ZE2_THROWNACCEL] = {
	sprite = SPR_RNGC,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 3,
	var2 = 1,
	nextstate = S_ZE2_THROWNACCEL,
}

states[S_ZE2_THROWNACCEL2] = {
	sprite = SPR_RNGC,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 3,
	var2 = 2,
	nextstate = S_ZE2_THROWNACCEL2,
}

states[S_ZE2_THROWNACCEL_HOLD] = {
	sprite = SPR_RNGC,
	frame = A,
	tics = -1,
	nextstate = S_ZE2_THROWNACCEL_HOLD,
}

local missile_accel_ring = 
xSlinger.registerMissile("ACCEL_RING", {
	speed = 14*FRACUNIT,
	displayname = "Accel",
	state = S_ZE2_THROWNACCEL,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_di2,
	height = 32*FRACUNIT,
	tick = function(pmo, mo)
		mo.momx = $ * 12/11
		mo.momy = $ * 12/11
		mo.momz = $ * 12/11
		
		if not (leveltime % 3) then
			P_SpawnGhostMobj(mo)
		end
	end
})

xSlinger.registerItem("accel_ring", {
	displayname = "Accel Ring";
	
	icon = "CROSIND";
	
	firerate = 9;
	
	damage = 16;
	
	knockback = 18*FRACUNIT;
	knockback_time = 2*TICRATE;
	
	reload_time = 3*TICRATE;
	
	color = SKINCOLOR_CHARTREUSE;
	
	dropstate = S_ZE2_THROWNACCEL2;
	
	ammo = 8;
	
	sounds = {
		use = sfx_rs_cro;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	hold_object = {
		state = S_ZE2_THROWNACCEL_HOLD;
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

    hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
	
	usefunc = function(self, mo)
		S_StartSound(mo, sfx_thok)
		
		local mt = "ACCEL_RING"
		for j = -1, 1 do
			for i = 0, 2 do
				local shot = xSlinger.SpawnMissile({
					source = mo,
					type = mt,
					angle = mo.angle + ANG20 * j,
					allow_aim = true,
					iteminfo = self,
				})
				
				if shot and shot.valid then
					shot.scale = FRACUNIT * 4/5
					shot.momx = $ * (2+i)/2
					shot.momy = $ * (2+i)/2
					shot.momz = $ * (2+i)/2
				end
			end
		end
	end;
})