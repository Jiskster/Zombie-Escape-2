-- NOTE: Load first in "Scenery/"

freeslot("MT_SCENERYPLAYER", "S_SCENERYPLAY_WALK")

states[S_SCENERYPLAY_WALK] = {states[S_PLAY_WALK].sprite, states[S_PLAY_WALK].frame, 2*TICRATE, nil, 0, 0, S_SCENERYPLAY_WALK}

mobjinfo[MT_SCENERYPLAYER] = {
	--$Title Scenery Player
	--$Category Doomed Corp
	--$Color 1
	doomednum = 1735,
	spawnstate = S_SCENERYPLAY_WALK,
	speed = 0,
	radius = 16*FRACUNIT,
	height = 56*FRACUNIT,
	mass = 1,
	flags = MF_SCENERY
}

addHook("MobjSpawn", function(mo)
	mo.skin = "sonic"
	mo.skin = ZE2.registered_skins[P_RandomRange(1, #ZE2.registered_skins)]
	mo.color = ZE2.GetRandomSkinColor()
end, MT_SCENERYPLAYER)