local auto_ring = ZE2:CreateItem("Automatic Ring",  {
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	firerate = 4,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 20,
	velocity_multiplier = 2*FRACUNIT,
	knockback = 3*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 50,
	reload_time = TICRATE*3,
	price = 50,
	skin_overwrite = {
		["knuckles"] = {
			damage = 40,
			max_ammo = 100,
			ammo = 100,
			firerate = 3,
			reload_time = TICRATE*6,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)