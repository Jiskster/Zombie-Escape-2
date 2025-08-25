ZE2:AddTimer("FROZENCHAOS_1", {
	text = "Defend First Barrier",
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(3)
		S_StartSound(nil, 90, nil)
	end,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "FROZENCHAOSTIMER1",
})

ZE2:AddTimer("FROZENCHAOS_2", {
	text = "Defend Second Barrier",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
		S_StartSound(nil,90,nil)
	end,
	textcolor = SKINCOLOR_CYAN,
	lua_linedef_exec = "FROZENCHAOSTIMER2",
})

ZE2:AddTimer("FROZENCHAOS_3", {
	text = "Defend Final Barrier",
	time = 18*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(7)
		S_StartSound(nil,90,nil)
	end,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "FROZENCHAOSTIMER3",
})

ZE2:AddTimer("FROZENCHAOS_4", {
	text = "Leaving Platform",
	time = 40*TICRATE,
	on_end_tag = 23,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "FROZENCHAOSTIMER4",
})