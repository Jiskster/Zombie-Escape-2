ZE2:AddTimer("DOOMEDCORP_1", {
	text = "Defend Elevator",
	time = 19*TICRATE,
	on_end_tag = 30,
	textcolor = SKINCOLOR_BLUE,
	lua_linedef_exec = "DOOMEDC1",
})

ZE2:AddTimer("DOOMEDCORP_2", {
	text = "Defend Cave",
	time = 14*TICRATE,
	on_end_tag = 62,
	textcolor = SKINCOLOR_GALAXY,
	lua_linedef_exec = "DOOMEDC2",
})

ZE2:AddTimer("DOOMEDCORP_3", {
	text = "Defend Barrier",
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(63)
		S_StartSound(nil, sfx_buzz3, nil)
	end,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "DOOMEDC3",
})

ZE2:AddTimer("DOOMEDCORP_RARE", {
	text = "[RARE] Defend Ring",
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(77)
		S_StartSound(nil, sfx_buzz3, nil)
	end,
	textcolor = SKINCOLOR_YELLOW,
})

addHook("LinedefExecute", function()
	if P_RandomChance(FU/3)
		P_LinedefExecute(76)
		S_StartSound(nil, sfx_buzz3, nil)
		ZE2:StartTimer("DOOMEDCORP_RARE")
	end
end, "DCRARE")