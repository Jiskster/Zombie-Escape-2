freeslot("MT_SCENERYPLAYER", "MT_SCENERYZOMBIE", "S_SCENERYPLAY_STND", "S_SCENERYPLAY_WALK")

states[S_SCENERYPLAY_STND] = {SPR_PLAY, A, 1, nil, 0, 0, S_SCENERYPLAY_WALK}
states[S_SCENERYPLAY_WALK] = {states[S_PLAY_WALK].sprite, states[S_PLAY_WALK].frame, 2*TICRATE, nil, 0, 0, S_SCENERYPLAY_WALK}

mobjinfo[MT_SCENERYPLAYER] = {
	--$Title Scenery Player
	--$Category Doomed Corp
	--$Color 1
	doomednum = 1735,
	spawnstate = S_SCENERYPLAY_STND,
	speed = 0,
	radius = 16*FRACUNIT,
	height = 56*FRACUNIT,
	mass = 1
}

mobjinfo[MT_SCENERYZOMBIE] = {
	--$Title Scenery Zombie
	--$Category Doomed Corp
	--$Color 1
	doomednum = 1736,
	spawnstate = S_SCENERYPLAY_STND,
	speed = 0,
	radius = 16*FRACUNIT,
	height = 56*FRACUNIT,
	mass = 1
}

--Set scenery player skin and color
addHook("MobjSpawn", function(mo)
	mo.skin = ZE2.registered_skins[P_RandomRange(1, #ZE2.registered_skins)]
	mo.color = R_GetColorByName(skincolors[P_RandomRange(1, #skincolors - 1)].name)
end, MT_SCENERYPLAYER)

--Set scenery zombie
addHook("MobjSpawn", function(mo)
	local alphachance = P_RandomChance(FU / 8)
	local alphascale = (mo.scale * 3) / 2

	mo.skin = "zsonic"
	mo.color = (alphachance and SKINCOLOR_ALPHAZOMBIE) or SKINCOLOR_ZOMBIE
	mo.scale = (alphachance and alphascale) or $
end, MT_SCENERYZOMBIE)