ZE2:AddTimer("WESTOPOLIS_1", {
	text = "Defend Spring Container",
	time = 30*TICRATE,
	on_end_tag = 98,
	textcolor = SKINCOLOR_PINK,
	lua_linedef_exec = "WESTOP1",
})

ZE2:AddTimer("WESTOPOLIS_2", {
	text = "Defend Barrier",
	time = 60*TICRATE,
	on_end_tag = 112,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "WESTOP2",
})