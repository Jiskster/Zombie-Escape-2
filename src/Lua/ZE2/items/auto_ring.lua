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
	deathsound = sfx_itemup,
})

xSlinger.registerItem("auto_ring", {
	displayname = "Automatic Ring";

	icon = "XSG_AUTO";

	missile = "AUTO_RING";

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

	knockback = 4*FRACUNIT;

	flags2 = MF2_AUTOMATIC;

	ammo = 50;

	reload_time = TICRATE*2;

	firerate = 2;

	skin_override = {
		["knuckles"] = {
			damage = 10;
			maxammo = 100;
			ammo = 100;

			knockback = 6*FRACUNIT;
			reload_time = TICRATE*4;
		}
	},
	
	flags2 = MF2_AUTOMATIC,

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

    animation_time = TICRATE;
})
