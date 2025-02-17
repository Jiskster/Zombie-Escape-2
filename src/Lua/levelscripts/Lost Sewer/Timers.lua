ZE2:AddTimer("LOSTSEWER_1", {
	text = "Defend Wall",
	time = 30*TICRATE,
	on_end_tag = 30,
	textcolor = SKINCOLOR_SILVER,
	lua_linedef_exec = "LOSWR1",
})

ZE2:AddTimer("LOSTSEWER_2", {
	text = "Defend Door",
	time = 30*TICRATE,
	on_end_tag = 69,
	textcolor = SKINCOLOR_SILVER,
	lua_linedef_exec = "LOSWR2",
})

ZE2:AddTimer("LOSTSEWER_3", {
	text = "Defend Moving Platform",
	time = 45*TICRATE,
	on_end_tag = 70,
	textcolor = SKINCOLOR_SILVER,
	lua_linedef_exec = "LOSWR3",
})