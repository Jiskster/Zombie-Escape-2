freeslot("sfx_lndplc")
freeslot("MT_ZE2_LANDMINE","S_ZE2_LANDMINE","S_ZE2_LANDMINE2", "SPR_MMVC")

mobjinfo[MT_ZE2_LANDMINE] = {
    sprite = SPR_MMVC,
	spawnstate = S_ZE2_LANDMINE,
	painstate = S_ZE2_LANDMINE,
	painsound = sfx_None,
	deathstate = S_BOSSEXPLODE,
	deathsound = sfx_s1c4,
	spawnhealth = 50,
	speed = 0,
	radius = 48*FRACUNIT,
	height = 48*FRACUNIT,
	flags = MF_SPECIAL,
}

states[S_ZE2_LANDMINE] = {
	nextstate = S_ZE2_LANDMINE2,
	sprite = SPR_MMVC,
	frame = FF_FULLBRIGHT|A,
	tics = 70,
}

states[S_ZE2_LANDMINE2] = {
	nextstate = S_ZE2_LANDMINE,
	sprite = SPR_MMVC,
	frame = FF_FULLBRIGHT|B,
	tics = 70,
}

local landmine = ZE2:CreateItem("Landmine",  {
	--object = MT_THROWNGRENADE,
	icon = "LANDMINEIND",
	firerate = 15,
	color = SKINCOLOR_BLACK,
	damage = 100,
	limited = true,
	count = 25,
	max_count = 255,
	sound = sfx_lndplc,
	price = 500,
	ontrigger = function(player)
		local landmine = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_ZE2_LANDMINE)
		
		landmine.target = player.mo
		landmine.spritexscale = $*2
		landmine.spriteyscale = $*2
		landmine.mobjteam = player["ze2_info"].team
		landmine.forcedamage = ZE2:FetchInventorySlot(player).damage
	end,
})

addHook("TouchSpecial", function(special, toucher)
	if special and special.valid and special.mobjteam and special.forcedamage then
		if toucher and toucher.valid and toucher.player and toucher.player.valid then
			local player = toucher.player
			
			if special.mobjteam ~= player["ze2_info"].team then
				P_DamageMobj(toucher, special, special.target, special.forcedamage)
				toucher.momx = 0
				toucher.momy = 0
				P_KillMobj(special, toucher)
			end
		end
	end
	
	return true
end, MT_ZE2_LANDMINE)

ZE2:RegisterShop_ItemID(landmine)