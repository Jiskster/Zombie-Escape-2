ZE2:AddTimer("SPOOKYFLOWER_1", {
	text = "Defend Barrier",
	time = 45*TICRATE,
	on_end_tag = 5,
	textcolor = SKINCOLOR_BROWN,
	lua_linedef_exec = "SPOOKYF1",
})

ZE2:AddTimer("SPOOKYFLOWER_2", {
	text = "Defend The Second Barrier",
	time = 50*TICRATE,
	on_end_tag = 17,
	textcolor = SKINCOLOR_BROWN,
	lua_linedef_exec = "SPOOKYF2",
})