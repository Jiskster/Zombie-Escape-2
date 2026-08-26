ZE2:AddTimer("ANCIENT_CATACOMBS_1", {
	text = "Defend Barrier",
	time = 24*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(2)
		S_StartSound(nil, 90, nil)
	end,
	textcolor = SKINCOLOR_SANDY,
	lua_linedef_exec = "CATATIMER1",
})

ZE2:AddTimer("ANCIENT_CATACOMBS_2", {
	text = "Defend Big Barrier",
	time = 29*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(3)
		S_StartSound(nil,90,nil)
	end,
	textcolor = SKINCOLOR_TAN,
	lua_linedef_exec = "CATATIMER2",
})