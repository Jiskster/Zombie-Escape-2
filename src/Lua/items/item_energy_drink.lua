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
			normalspeed_multiplier = 10*FRACUNIT/7,
			damage_multiplier = 2*FRACUNIT,
			knockback_multiplier = 5*FRACUNIT,
		}, 6*TICRATE, true)
	end,
	price = 575,
})

ZE2:RegisterShop_ItemID(energydrink)