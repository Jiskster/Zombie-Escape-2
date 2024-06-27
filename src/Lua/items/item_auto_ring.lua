local auto_ring = ZE2:CreateItem("Automatic Ring",  {
	object = MT_THROWNAUTOMATIC,
	icon = "AUTOIND",
	firerate = 2,
	color = SKINCOLOR_GREEN,
	autouse = true,
	damage = 12,
	knockback = 20*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 30,
	reload_time = TICRATE*3,
	price = 50,
})

print(auto_ring)
ZE2:RegisterShopItem(auto_ring)