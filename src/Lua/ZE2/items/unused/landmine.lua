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

local landmine = ZE2:CreateItem("landmine",  {
	displayname = "Landmine",
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
		landmine.mobjteam = player.xSlinger.team
		landmine.forcedamage = ZE2:FetchInventorySlot(player).damage
	end,
})

--short for specialoverride
local function SO(card)
	card.flags = $|MF_SPECIAL
	card.health = card.info.spawnhealth
	return true
end

addHook("TouchSpecial", function(special, toucher)
	if not (special and special.valid) then return end
	if not (toucher and toucher.valid) then return end
	if not (special.health) then return end
	if not (toucher.health) then return SO(special); end

	if (special.mobjteam == nil or special.forcedamage == nil) then return SO(special); end
	
	local p = toucher.player
	if not (p and p.valid) then return SO(special); end
	if (p.xSlinger.team == special.mobjteam) then return SO(special); end

	-- so the toucher must be of a different team
	P_DamageMobj(toucher, special, special.target, special.forcedamage)
	toucher.momx = 0
	toucher.momy = 0
	P_KillMobj(special, toucher)
end, MT_ZE2_LANDMINE)

--ZE2:RegisterShop_ItemID(landmine)