local auto_ring = ZE2:CreateItem("auto_ring",  {
	displayname = "Automatic Ring",
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	sound = sfx_wpfir2,
	firerate = 2,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 7,
	velocity_multiplier = 3*FRACUNIT + 4*FRACUNIT/3,
	velocity_precision = 4,
	knockback = 3*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 30,
	reload_time = TICRATE*2,
	price = 250,
	skin_overwrite = {
		["knuckles"] = {
			damage = 40,
			max_ammo = 50,
			ammo = 50,
			firerate = 2,
			knockback = 5*FRACUNIT,
			velocity_multiplier = 2*FRACUNIT,
			reload_time = TICRATE*3,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)