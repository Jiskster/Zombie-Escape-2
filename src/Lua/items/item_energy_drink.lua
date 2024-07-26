freeslot("sfx_edprdn") -- no, not edp445
freeslot("sfx_rblxdr")

local energydrink = ZE2:CreateItem("Energy Drink", {
	icon = "ENERGYDRINKIND",
	firerate = TICRATE*30,
	sound = sfx_rblxdr,
	limited = true,
	count = 3,
	max_count = 15,
	color = SKINCOLOR_MASTER,
	ontrigger = function(player)
		ZE2:GivePlayerEffect(player, "Energy_Drink", {
			normalspeed_multiplier = 3*FRACUNIT/2,
			damage_multiplier = 3*FRACUNIT/2,
		}, 7*TICRATE, true)
	end,
	price = 115,
})

ZE2:RegisterShop_ItemID(energydrink)