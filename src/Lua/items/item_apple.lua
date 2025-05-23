local apple = ZE2:CreateItem("Apple", {
	icon = "APPLEIND",
	firerate = 50,
	sound = sfx_eatapl,
	limited = true,
	count = 5,
	max_count = 100,
	color = SKINCOLOR_RED,
	ontrigger = function(player)
		player.mo:ChangeHealth(16)
	end,
	price = 50,
})

ZE2:RegisterShop_ItemID(apple)