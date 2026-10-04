freeslot("S_XS_AUTORING")
freeslot("S_XS_AUTORING_DROP")

states[S_XS_AUTORING] = {
	sprite = SPR_TAUT,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 6,
	var2 = 1,
	nextstate = S_XS_AUTORING,
}

states[S_XS_AUTORING_DROP] = {
	sprite = SPR_RNGA,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_AUTORING_DROP,
}

local missile_auto_ring = 
xSlinger.registerMissile("AUTO_RING", {
	speed = 120*FRACUNIT,
	displayname = "Auto Ring",
	state = S_XS_AUTORING,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
})

xSlinger.registerItem("auto_ring", {
	displayname = "Automatic Ring";

	icon = "XSG_AUTO";
	
	dropstate = S_XS_AUTORING_DROP;

	sounds = {
		use = sfx_wpfir2;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	color = SKINCOLOR_GREEN;

	autouse = true;

	damage = 7;
	
	velocity_precision = 2;

	knockback = 5*FRACUNIT;

	ammo = 50;

	reload_time = TICRATE*2;

	firerate = 2;
	
	usefunc = function(self, mo)
		local aim = 0
		local ang = mo.angle
		local speed = FixedHypot(FixedHypot(mo.momx, mo.momy), mo.momz)
		if mo.player and mo.player.valid then
			aim = mo.player.aiming
		end
		
		if abs(speed) and (mo.momx or mo.momy) then
			local s = abs(speed)/5
			
			ang = $ + FixedAngle(P_RandomRange(-s/FU, s/FU)*FU)
			aim = $ + FixedAngle(P_RandomRange(-s/FU, s/FU)*FU)
		end
		
		local ring = xSlinger.SpawnMissile({
			source = mo,
			type = "AUTO_RING",
			angle = ang,
			aiming = aim,
			allow_aim = true,
			iteminfo = self,
		})
	end,

	skin_override = {
		["knuckles"] = {
			maxammo = 100;
			ammo = 100;

			knockback = 7*FRACUNIT;
			reload_time = TICRATE*3;
		}
	},
	
	hold_object = {
		state = S_XS_AUTORING;
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

    animation_time = TICRATE/6;
})
