freeslot("MT_CRRING","S_CRRING") 

mobjinfo[MT_CRRING] = {
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
	mobj.color = SKINCOLOR_BLUE
end, MT_CRRING)

addHook("TouchSpecial", function(special,toucher)
	if toucher and toucher.valid and toucher.player and toucher.player.valid then
		local player = toucher.player
		
		if not player["ze2_info"].ghostmode and not ZE2.game_ended and ZE2.round_active then
			local cash_award = ZE2.PlayerCount()*25
			player["ze2_info"].ghostmode = true
			
			for tplayer in players.iterate do
				if tplayer.spectator then continue end
				if player["ze2_info"].team ~= tplayer["ze2_info"].team then continue end
				
				ZE2:GivePlayerRubies(tplayer, cash_award)
				CONS_Printf(tplayer, "\x83 + Awarded "..cash_award.." cash awarded for winning!")
			end

			for d=0,16 do
				P_SpawnParaloop(toucher.x, toucher.y, toucher.z+toucher.height, FixedMul(192*FRACUNIT, toucher.scale), 16, MT_NIGHTSPARKLE, i*ANGLE_22h, S_NULL, true)
			end
			S_StartSound(nil,sfx_s3kb3)
			ZE2:StartWin(player["ze2_info"].team)
		end
		
		return true
	end
end, MT_CRRING)

addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end --stop the trolling
	if ((ZE2.PlayerCount() > 1) or (mapheaderinfo[gamemap].ze2_solofail)) and ZE2.SurvivorCount() == 0 and not ZE2.game_ended then
		ZE2:StartWin(2)
	end
end)