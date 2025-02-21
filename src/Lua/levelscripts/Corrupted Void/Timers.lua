ZE2:AddTimer("CORRUPTEDVOID_1", {
	text = "SURVIVE",
	time = 55*TICRATE,
	on_end_tag = 10,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "CVOIDTIMER1",
})

ZE2:AddTimer("CORRUPTEDVOID_2", {
	text = "Defend Barrier",
	time = 20*TICRATE,
	on_end_tag = 8,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "CVOIDTIMER2",
})

ZE2:AddTimer("CORRUPTEDVOID_3", {
	text = "Good Luck!",
	time = 65*TICRATE,
	on_end_tag = 22,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "CVOIDTIMER3",
})

ZE2:AddTimer("CORRUPTEDVOID_4", {
	text = "Defend Barrier",
	time = 5*TICRATE,
	on_end_tag = 8,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "CVOIDTIMER4",
})