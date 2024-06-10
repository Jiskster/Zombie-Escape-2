freeslot("sfx_gulpy")

ZE2:CreateItem("Milk", {
	icon = "MILKIND",
	iconscale = FU/2,
	firerate = 32,
	sound = sfx_gulpy,
	limited = true,
	count = 12,
	ontrigger = function(player)
		ZE2:ChangeStamina(player, 25*FRACUNIT)
		ZE2:ChangeHealth(player.mo, 4)
	end,
	price = 20,
})