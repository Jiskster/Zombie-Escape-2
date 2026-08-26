freeslot("MT_CRRING", "S_CRRING")

mobjinfo[MT_CRRING] = {
	//$Category Zombie Escape 2
	//$Name Exit Ring
	//$Sprite SIGNF0

	doomednum = 860,
	spawnstate = S_CRRING,
	painchance = 192*FRACUNIT,
	spawnhealth = 1,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

states[S_CRRING] = {
	sprite = SPR_RING,
	frame = FF_FULLBRIGHT|FF_ANIMATE|FF_ADD|A,
	tics = -1,
	var1 = 23,
	var2 = 1,
	nextstate = S_CRRING,
}

addHook("MobjSpawn", function(mobj)
	mobj.scale = $ * 4
	mobj.colorized = true
	mobj.color = SKINCOLOR_CHROMA

	mobj.corona = P_SpawnMobjFromMobj(mobj, 0, 0, 16*FU*P_MobjFlip(mobj), MT_CORONA)
end, MT_CRRING)

addHook("MobjThinker", function(mobj)
	if mobj.corona and mobj.corona.valid then
		local corona = mobj.corona
		corona.color = mobj.color
		corona.alpha = (FU/4) + abs(cos(leveltime*ANG1*5))/2
		corona.scale = FRACUNIT
		corona.colorized = true
		corona.dispoffset = 3
	end
end, MT_CRRING)

addHook("MobjRemoved", function(mobj)
	if mobj and mobj.valid then
		if mobj.corona and mobj.corona.valid then
			P_RemoveMobj(mobj.corona)
		end
	end
end, MT_CRRING)

addHook("TouchSpecial", function(special,toucher)
	local game = ZE2.Game
	if toucher and toucher.valid and toucher.player and toucher.player.valid then
		special.team = toucher.team
		local player = toucher.player
		if not player then return end
		if (not player.ze2.ghostmode) and (not game.ended) and (game.active) then
			player.ze2.ghostmode = true
			
			special.flags = $ | MF_NOCLIP
			special.z = $ - (special.height/2)*P_MobjFlip(special)
			special.state = S_RINGEXPLODE
			S_StopSound(special)
		
			S_StartSound(nil,sfx_s3kb3)

			ZE2:StartWin(toucher.team, true)
		end
		return true
	end
end, MT_CRRING)