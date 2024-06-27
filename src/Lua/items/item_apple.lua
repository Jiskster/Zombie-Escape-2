local apple = ZE2:CreateItem("Apple", {
	icon = "APPLEIND",
	iconscale = FU/2,
	firerate = 50,
	sound = sfx_eatapl,
	limited = true,
	count = 3,
	color = SKINCOLOR_RED,
	ontrigger = function(player)
		ZE2:ChangeHealth(player.mo, 16)
	end,
	price = 15,
})

ZE2:RegisterShopItem(apple)