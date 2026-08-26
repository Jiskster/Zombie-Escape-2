ZE2:AddTimer("DATAZ_1", {
	text = "Defend Barrier",
	time = 25*TICRATE,
	on_end_tag = 2,
	textcolor = SKINCOLOR_YELLOW,
	lua_linedef_exec = "DATAZTIMER1",
})

ZE2:AddTimer("DATAZ_2", {
	text = "Defend Final Barrier",
	time = 40*TICRATE,
	on_end_tag = 6,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "DATAZTIMER2",
})

ZE2:AddTimer("DATAZ_3", {
	text = "Leaving Platform",
	time = 20*TICRATE,
	on_end_tag = 23,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "DATAZTIMER3",
})
