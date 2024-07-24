local auto_ring = ZE2:CreateItem("Automatic Ring",  {
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	firerate = 2,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 12,
	knockback = 14*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 100,
	reload_time = TICRATE*3,
	price = 50,
	skin_overwrite = {
		["knuckles"] = {
			damage = 30,
			max_ammo = 150,
			ammo = 150,
			firerate = 1,
			reload_time = TICRATE*6,
		}
	}
})

ZE2:RegisterShop_ItemID(auto_ring)