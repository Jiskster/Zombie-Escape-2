freeslot("MT_CRRING","S_CRRING") 

mobjinfo[MT_CRRING] = {
	//$Category Zombie Escape 2
	//$Name Exit Ring
	//$Sprite SIGNF0

	doomednum = 860,
	spawnstate = S_CRRING,
	spawnhealth = 1,
	deathstate = S_SPRK1,
	deathsound = sfx_itemup,
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
	nextstate = S_CRRUBY,
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

addHook("TouchSpecial", function(special,toucher)
	if toucher and toucher.valid and toucher.player and toucher.player.valid then
		local player = toucher.player
		
		if not player.ze2.ghostmode and not ZE2.game_ended and ZE2.round_active then		
			player.ze2.ghostmode = true

			for d=0,16 do
				P_SpawnParaloop(toucher.x, toucher.y, toucher.z+toucher.height, FixedMul(192*FRACUNIT, toucher.scale), 16, MT_NIGHTSPARKLE, i*ANGLE_22h, S_NULL, true)
			end
			S_StartSound(nil,sfx_s3kb3)
			
			ZE2:StartWin(player.ze2.team, true)
		end
		
		return true
	end
end, MT_CRRING)