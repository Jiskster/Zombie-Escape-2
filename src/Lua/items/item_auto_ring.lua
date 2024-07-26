local auto_ring = ZE2:CreateItem("Automatic Ring",  {
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	firerate = 3,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 20,
	knockback = FRACUNIT/2,
	flags2 = MF2_AUTOMATIC,
	ammo = 100,
	reload_time = TICRATE*3,
	price = 50,
	skin_overwrite = {
		["knuckles"] = {
			damage = 40,
			max_ammo = 150,
			ammo = 150,
			firerate = 2,
			reload_time = TICRATE*6,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)