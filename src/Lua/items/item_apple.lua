local apple = ZE2:CreateItem("apple", {
	displayname = "Apple",
	icon = "APPLEIND",
	firerate = 50,
	sound = sfx_eatapl,
	limited = true,
	count = 5,
	max_count = 100,
	color = SKINCOLOR_RED,
	ontrigger = function(player)
		player.mo:ChangeHealth(20)
	end,
	price = 120,
})

ZE2:RegisterShop_ItemID(apple)