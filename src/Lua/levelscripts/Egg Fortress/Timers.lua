ZE2:AddTimer("EGGFORTRESS_1", {
	text = "Defend the Gate",
	time = 20*TICRATE,
	on_end_tag = 9,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "FORTTIMER1",
})

ZE2:AddTimer("EGGFORTRESS_2", {
	text = "Defend the Second Gate",
	time = 35*TICRATE,
	on_end_tag = 19,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "FORTTIMER2",
})

ZE2:AddTimer("EGGFORTRESS_3", {
	text = "Defend the Secret Entrance",
	time = 45*TICRATE,
	on_end_tag = 41,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "FORTTIMER3",
})