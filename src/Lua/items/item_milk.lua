freeslot("sfx_gulpy")

local milk = ZE2:CreateItem("Milk", {
	icon = "MILKIND",
	iconscale = FU/2,
	firerate = 20,
	sound = sfx_gulpy,
	limited = true,
	count = 5,
	max_count = 25,
	color = SKINCOLOR_WHITE,
	ontrigger = function(player)
		ZE2:ChangeStamina(player, 40*FRACUNIT)
	end,
	price = 50,
})

ZE2:RegisterShopItem(milk)