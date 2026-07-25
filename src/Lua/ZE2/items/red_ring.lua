freeslot("S_XS_REDRING")

states[S_XS_REDRING] = {
	sprite = SPR_RRNG,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 6,
	var2 = 2,
	nextstate = S_XS_REDRING,
}

local missile_red_ring = 
xSlinger.registerMissile("RED_RING", {
	speed = 600*FRACUNIT,
	displayname = "Red Ring",
	state = S_XS_REDRING,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
})

xSlinger.registerItem("red_ring", {
	displayname = "Red Ring";

	icon = "XSG_RING";

	missile = "RED_RING";

	dropstate = missile_red_ring.state;

	sounds = {
		use = sfx_wpfire;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	color = SKINCOLOR_RED;

	damage = 25;

	velocity_precision = 5;

	knockback = 23*FRACUNIT; -- fixed_t
	knockback_time = 4;

	autouse = false;

	ammo = 16;

	reload_time = 2*TICRATE;
	firerate = 3;

	flags2 = 0; -- MF2_...

	hold_object = {
		state = missile_red_ring.state;
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

	missile_tick = function(self, mo, missile)
		local ghost = P_SpawnGhostMobj(missile)
		ghost.tics = 1
	end;

	missile_subtick = function(self, mo, missile)
		local ghost = P_SpawnGhostMobj(missile)
		ghost.tics = 1
		ghost.frame = $|FF_ADD
	end;

	skin_override = {
		["sonic"] = {
			reload_time = 1*TICRATE;
		};
		["amy"] = {
			reload_time = 1*TICRATE;
		};
		["fang"] = {
			knockback = 32*FRACUNIT;
			damage = 35;
		};
	};
})