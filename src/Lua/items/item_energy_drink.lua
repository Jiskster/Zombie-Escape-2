freeslot("sfx_edprdn") -- no, not edp445
freeslot("sfx_rblxdr")

ZE2.Effects["energy_drink"] = {
	thinker = function(player)
		if player.mo and player.mo.valid then
			player["ze2_info"].sprintmeter = 100*FRACUNIT
			
			local ghost = P_SpawnGhostMobj(player.mo)
			ghost.colorized = true
			ghost.color = SKINCOLOR_MASTER
		end
	end,
	on_end = function(player)
		if player.mo and player.mo.valid then
			S_StartSound(player.mo, sfx_edprdn)
		end
	end,
}

local energydrink = ZE2:CreateItem("Energy Drink", {
	icon = "ENERGYDRINKIND",
	firerate = TICRATE*30,
	sound = sfx_rblxdr,
	limited = true,
	count = 3,
	max_count = 15,
	color = SKINCOLOR_MASTER,
	ontrigger = function(player)
		ZE2:GivePlayerEffect(player, "energy_drink", {
			normalspeed_multiplier = 10*FRACUNIT/7,
			damage_multiplier = 2*FRACUNIT,
			knockback_multiplier = 5*FRACUNIT,
		}, 6*TICRATE, true)
	end,
	price = 575,
})

ZE2:RegisterShop_ItemID(energydrink)