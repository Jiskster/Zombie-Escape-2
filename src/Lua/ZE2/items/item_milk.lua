freeslot("sfx_gulpy")

local milk = ZE2:CreateItem("milk", {
	displayname = "Milk",
	icon = "MILKIND",
	iconscale = FU/2,
	firerate = 20,
	sound = sfx_gulpy,
	limited = true,
	count = 5,
	max_count = 25,
	color = SKINCOLOR_WHITE,
	ontrigger = function(player)
		player.ze2:ChangeStamina(40*FRACUNIT)
	end,
	price = 250,
})

ZE2:RegisterShop_ItemID(milk)