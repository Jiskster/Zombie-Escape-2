freeslot("sfx_gulpy")

ZE2:CreateItem("Milk", {
	icon = "MILKIND",
	iconscale = FU/2,
	firerate = 20,
	sound = sfx_gulpy,
	limited = true,
	count = 5,
	ontrigger = function(player)
		ZE2:ChangeStamina(player, 40*FRACUNIT)
	end,
	price = 50,
})