local explosion_ring = ZE2:CreateItem("Explosion Ring", {
	object = MT_THROWNEXPLOSION,
	icon = "BOMBIND",
	firerate = TICRATE + TICRATE/2,
	color = SKINCOLOR_BLACK,
	damage = 70,
	knockback = 90*FRACUNIT,
	price = 140,
})

ZE2:RegisterShopItem(explosion_ring)