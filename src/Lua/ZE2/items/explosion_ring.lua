freeslot("S_XS_EXPLOSIONRING_DROP")

states[S_XS_EXPLOSIONRING_DROP] = {
	sprite = SPR_RNGE,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_EXPLOSIONRING_DROP,
}

xSlinger.registerItem("explosion_ring", {
	displayname = "Explosion Ring";
	
	missile = MT_THROWNEXPLOSION;
	
	dropstate = S_XS_EXPLOSIONRING_DROP;
	
	icon = "XSG_BOMB";
	
	firerate = TICRATE*3;
	
	color = SKINCOLOR_BLACK;
	
	damage = 120;
	
	knockback = 100*FRACUNIT;
	knockback_tics = TICRATE;
})