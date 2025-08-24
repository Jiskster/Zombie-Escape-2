local auto_ring = ZE2:CreateItem("auto_ring",  {
	displayname = "Automatic Ring",
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	sound = sfx_wpfir2,
	firerate = 3,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 7,
	velocity_multiplier = 2*FRACUNIT,
	velocity_precision = 2,
	knockback = 3*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 50,
	reload_time = TICRATE*2,
	price = 250,
	skin_overwrite = {
		["knuckles"] = {
			damage = 20,
			max_ammo = 100,
			ammo = 100,
			firerate = 2,
			knockback = 5*FRACUNIT,
			reload_time = TICRATE*4,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)