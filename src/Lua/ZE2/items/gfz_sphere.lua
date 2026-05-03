-- Render by Marilyn / Speccy

freeslot("MT_ZE2_GFZSPHERE", "S_ZE2_GFZSPHERE", "SPR_GFZS")

mobjinfo[MT_ZE2_GFZSPHERE] = {
	spawnstate = S_ZE2_GFZSPHERE,
	--activesound = sfx_shgn,
	deathstate = S_SPRK1,
	xdeathstate = S_SPRK1,
	speed = 60*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_ZE2_GFZSPHERE] = {
	nextstate = S_ZE2_GFZSPHERE,
	sprite = SPR_GFZS,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	tics = -1,
	var1 = 3,
	var2 = 2,
}

freeslot("S_ZE2_GFZSPHERE_DROP", "SPR_ZE2_GFZSPHERE")

states[S_ZE2_GFZSPHERE_DROP] = {
	sprite = SPR_ZE2_GFZSPHERE, -- uhhh problematic naming???
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_GFZSPHERE_DROP,
}

xSlinger.registerItem("GFZSPHERE",  {
	displayname = "GFZSPHERE";

	missile = MT_ZE2_GFZSPHERE;

	icon = "GFZSPHEREIND";

	firerate = 40;

	color = SKINCOLOR_BROWN;

	dropstate = S_ZE2_GFZSPHERE_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	knockback = 125*FRACUNIT;
	damage = 115;
	sounds = {
		use = sfx_kc5b;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	ammo = 3;

	autouse = true;

	reload_time = TICRATE*4;
})