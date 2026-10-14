-- electricity sound: sfx_beelec

xSlinger.registerItem("volt_ring", {
	
	-- HUD

	displayname = "Volt Ring",
	icon = "VOLTIND",
	
	-- Missile Properties
	
	color = SKINCOLOR_BLUE,
	
	-- Item Properties
	
	ammo = 2, -- todo: use count instead
	firerate = TICRATE*6,
	sounds = {
		use = sfx_s3k45,
		reload = {sfx_xsrel1, sfx_xsrel2},
		pickup = sfx_None,
		drop = sfx_None,
	},
})