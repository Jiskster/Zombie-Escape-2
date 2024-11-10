local auto_ring = ZE2:CreateItem("Automatic Ring",  {
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	firerate = 2,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 5,
	velocity_multiplier = 2*FRACUNIT + FRACUNIT/2,
	knockback = 3*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 50,
	reload_time = TICRATE*4,
	price = 50,
	skin_overwrite = {
		["knuckles"] = {
			damage = 50,
			max_ammo = 75,
			ammo = 75,
			firerate = 4,
			reload_time = TICRATE*7,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)