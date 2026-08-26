freeslot("MT_SCENERYZOMBIE")

mobjinfo[MT_SCENERYZOMBIE] = {
	--$Title Scenery Zombie
	--$Category Doomed Corp
	--$Color 1
	doomednum = 1736,
	spawnstate = S_SCENERYPLAY_WALK,
	speed = 0,
	radius = 16*FRACUNIT,
	height = 56*FRACUNIT,
	mass = 1,
	flags = MF_SCENERY
}

--Set scenery zombie
addHook("MobjSpawn", function(mo)
	local alphachance = P_RandomChance(FU / 8)
	local alphascale = (mo.scale * 3) / 2

	mo.skin = "zsonic"
	mo.color = (alphachance and SKINCOLOR_ALPHAZOMBIE) or SKINCOLOR_ZOMBIE
	mo.scale = (alphachance and alphascale) or $
end, MT_SCENERYZOMBIE)