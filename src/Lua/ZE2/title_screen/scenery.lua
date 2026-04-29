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
local accessible_skincolors = {}
local function UpdateSkinColors() --If new accessible skincolors are found
	for i = 1, #skincolors - 1 do
		if accessible_skincolors[i] then continue end --Is already on the list? skip
		if not skincolors[i].accessible then continue end --Is not accessible? skip
		table.insert(accessible_skincolors, skincolors[i].name)
	end
end
UpdateSkinColors(); addHook("AddonLoaded", UpdateSkinColors) --Update when ZE2 is loaded and when other addons loads

addHook("MobjSpawn", function(mo)
	mo.skin = ZE2.registered_skins[P_RandomRange(1, #ZE2.registered_skins)]
	mo.color = R_GetColorByName(accessible_skincolors[P_RandomRange(1, #accessible_skincolors)])
end, MT_SCENERYPLAYER)

--Set scenery zombie
addHook("MobjSpawn", function(mo)
	local alphachance = P_RandomChance(FU / 8)
	local alphascale = (mo.scale * 3) / 2

	mo.skin = "zsonic"
	mo.color = (alphachance and SKINCOLOR_ALPHAZOMBIE) or SKINCOLOR_ZOMBIE
	mo.scale = (alphachance and alphascale) or $
end, MT_SCENERYZOMBIE)