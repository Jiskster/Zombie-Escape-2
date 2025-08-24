local explosion_ring = ZE2:CreateItem("explosion_ring", {
	displayname = "Explosion Ring",
	object = MT_THROWNEXPLOSION,
	icon = "BOMBIND",
	firerate = TICRATE*3,
	color = SKINCOLOR_BLACK,
	damage = 120,
	knockback = 160*FRACUNIT,
	knockback_tics = TICRATE*2,
	price = 700,
})

ZE2:RegisterShop_ItemID(explosion_ring)