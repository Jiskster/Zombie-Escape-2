ZE2:AddTimer("THERUINSUT_1", {
	text = "Defend Door",
	time = 45*TICRATE,
	on_end_tag = 201,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "THERUINSUT1",
})

ZE2:AddTimer("THERUINSUT_2", {
	text = "Break Time! (Toriel's house)",
	time = 35*TICRATE,
	on_end_tag = 202,
	extrainfo = {
		[1] = {
			event_time = 10*TICRATE,
			event_func = do 
				S_StartSound(nil, sfx_utdgr)
				chatprint("\x82\* Zombie battle in\x85 10 \x82seconds!")
			end
		},
		[2] = {
			event_time = 1*TICRATE,
			event_func = do
				S_StartSound(nil, sfx_utbtl)
			end
		}
	},
	on_end = function()
		S_ChangeMusic("UTBTL2", true)
		mapmusname = "UTBTL2"
		
		ZE2:StartTimer("THERUINSUT_3")
		
		for player in players.iterate do
			if player.mo and player.mo.valid and (player.ze2.team == 1) then
				P_LinedefExecute(113, player.mo)
			end
		end
	end,
	textcolor = SKINCOLOR_LATTE,
	lua_linedef_exec = "THERUINSUT2",
})

ZE2:AddTimer("THERUINSUT_3", {
	text = "Zombies Incoming!",
	time = 5*TICRATE,
	textcolor = SKINCOLOR_RED,
	on_end = function()
		ZE2:StartTimer("THERUINSUT_4")
	
		for player in players.iterate do
			if player.mo and player.mo.valid and (player.ze2.team == 2) then
				P_LinedefExecute(113, player.mo)
			end
		end
	end,
	lua_linedef_exec = "THERUINSUT3",
})

ZE2:AddTimer("THERUINSUT_4", {
	text = "Survive the zombies!",
	time = 50*TICRATE,
	textcolor = SKINCOLOR_GREEN,
	on_end = function()	
		for player in players.iterate do
			if player.mo and player.mo.valid and (player.ze2.team == 1) then
				P_LinedefExecute(114, player.mo) -- 114 is the teleport after the zombie attack
			end
		end
	end,
	lua_linedef_exec = "THERUINSUT4",
})