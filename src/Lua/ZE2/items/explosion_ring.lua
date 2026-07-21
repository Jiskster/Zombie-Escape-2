freeslot("S_XS_EXPLOSIONRING")

states[S_XS_EXPLOSIONRING] = { -- for drop only
	sprite = SPR_RNGE,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_EXPLOSIONRING,
}

local missile_explosion_ring = xSlinger.registerMissile("EXPLOSION_RING", {
	speed = 60*FRACUNIT,
	displayname = "Explosion Ring",
	state = S_THROWNEXPLOSION1,
	deathstate = S_RINGEXPLODE,
	deathsound = sfx_pop,
	delflags = MF_NOGRAVITY,
})

xSlinger.registerItem("explosion_ring", {
	displayname = "Explosion Ring";

	missile = "EXPLOSION_RING";

	dropstate = S_XS_EXPLOSIONRING;

	icon = "XSG_BOMB";

	sounds = {
		use = sfx_cannon;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	firerate = (TICRATE*3)/2;

	ammo = 3;

	color = SKINCOLOR_BLACK;

	damage = 120;

	reload_time = 4*TICRATE;

	knockback = 100*FRACUNIT;
	knockback_tics = TICRATE;
})