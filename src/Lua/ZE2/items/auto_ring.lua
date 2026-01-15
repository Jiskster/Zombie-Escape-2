xSlinger.registerItem("auto_ring", {
	displayname = "Automatic Ring";
	
	icon = "XSG_AUTO";
	
	missile = MT_THROWNAUTOMATIC;

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
	
	knockback = 3*FRACUNIT;
	
	flags2 = MF2_AUTOMATIC;
	
	ammo = 50;
	
	reload_time = TICRATE*2;
	firerate = 3;

	skin_override = {
		["knuckles"] = {
			damage = 20;
			maxammo = 100;
			ammo = 100;
			firerate = 2;
			knockback = 5*FRACUNIT;
			reload_time = TICRATE*4;
		}
	}
})
