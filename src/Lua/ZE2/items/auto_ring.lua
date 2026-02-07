freeslot("S_XS_AUTORING_DROP")

states[S_XS_AUTORING_DROP] = {
	sprite = SPR_RNGA,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_AUTORING_DROP,
}

xSlinger.registerItem("auto_ring", {
	displayname = "Automatic Ring";
	
	icon = "XSG_AUTO";
	
	missile = MT_THROWNAUTOMATIC;
	
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
	
	velocity_multiplier = 2*FRACUNIT;
	velocity_precision = 2;
	
	knockback = 4*FRACUNIT;
	
	flags2 = MF2_AUTOMATIC;
	
	ammo = 50;
	
	reload_time = TICRATE*2;
	
	firerate = 2;

	skin_override = {
		["knuckles"] = {
			damage = 20;
			maxammo = 100;
			ammo = 100;
			
			knockback = 6*FRACUNIT;
			reload_time = TICRATE*4;
		}
	}
})
