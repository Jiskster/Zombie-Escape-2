local grenade = ZE2:CreateItem("Grenade",  {
	object = MT_THROWNGRENADE,
	icon = "GRENIND",
	firerate = 15,
	color = SKINCOLOR_GREEN,
	knockback = 50*FRACUNIT,
	damage = 150,
	limited = true,
	count = 15,
	max_count = 255,
	fuse = 2*TICRATE,
	velocity_multiplier = FRACUNIT/2,
	price = 300,
})

ZE2:RegisterShop_ItemID(grenade)