ZE2:AddTimer("ZOMBIO_1", {
	text = "Blocks breaks in",
	time = 30*TICRATE,
	on_end_tag = 98,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "ZOMBIO1",
})

ZE2:AddTimer("ZOMBIO_2", {
	text = "Defend Wooden gate",
	time = 30*TICRATE,
	on_end_tag = 99,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "ZOMBIO2",
})

ZE2:AddTimer("ZOMBIO_3", {
	text = "Blocks opens in",
	time = 30*TICRATE,
	on_end_tag = 101,
	textcolor = SKINCOLOR_WHITE,
	lua_linedef_exec = "ZOMBIO3",
})

ZE2:AddTimer("ZOMBIO_4", {
	text = "Platform leaving",
	time = 20*TICRATE,
	on_end_tag = 103,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "ZOMBIO4",
})