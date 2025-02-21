ZE2:AddTimer("ALPHACOMBS_1", {
	text = "Defend First Barrier",
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(3)
		S_StartSound(nil, 90, nil)
	end,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "ALPHACOMBSTIMER1",
})

ZE2:AddTimer("ALPHACOMBS_2", {
	text = "Defend Second Barrier",
	time = 26*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(7)
		S_StartSound(nil,90,nil)
	end,
	textcolor = SKINCOLOR_BLACK,
	lua_linedef_exec = "ALPHACOMBSTIMER2",
})

ZE2:AddTimer("ALPHACOMBS_3", {
	text = "Leaving Platform",
	time = 20*TICRATE,
	on_end_tag = 23,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "ALPHACOMBSTIMER3",
})