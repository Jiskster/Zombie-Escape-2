-- Beta name was "Underground Marble", so thats why you see "UG" in the constant names.

ZE2:AddTimer("UGMARBLE_1", {
	text = "Defend Barrier",
	time = 40*TICRATE,
	on_end_tag = 11,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "UGMARBLETIMER1",
})

ZE2:AddTimer("UGMARBLE_2", {
	text = "Defend Barrier 2",
	time = 40*TICRATE,
	on_end_tag = 13,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "UGMARBLETIMER2",
})