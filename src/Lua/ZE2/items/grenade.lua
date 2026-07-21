freeslot("S_XS_GRENADERING_DROP")

states[S_XS_GRENADERING_DROP] = {
	sprite = SPR_RNGG,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_GRENADERING_DROP,
}

xSlinger.registerItem("grenade_ring",  {
	displayname = "Grenade";

	missile = MT_THROWNGRENADE;

	dropstate = S_XS_GRENADERING_DROP;

	icon = "GRENIND";

	firerate = 15;

	color = SKINCOLOR_GREEN;

	knockback = 75*FRACUNIT;

	damage = 99;

	count = 5;
	maxcount = 10;

	fuse = 2*TICRATE;

	velocity_multiplier = FRACUNIT/2;
})