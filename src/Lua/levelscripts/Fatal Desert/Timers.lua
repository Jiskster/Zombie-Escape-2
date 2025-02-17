ZE2:AddTimer("FATALDESERT_1", {
	text = "Defend First Barrier",
	time = 18*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(2)
		S_StartSound(nil, 90, nil)
	end,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "DESERTTIMER1",
})

ZE2:AddTimer("FATALDESERT_2", {
	text = "Defend Second Barrier",
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
		S_StartSound(nil,90,nil)
	end,
	textcolor = SKINCOLOR_SANDY,
	lua_linedef_exec = "DESERTTIMER2",
})

ZE2:AddTimer("FATALDESERT_3", {
	text = "Defend Final Barrier",
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
		S_StartSound(nil, 90, nil)
	end,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "DESERTTIMER3",
})