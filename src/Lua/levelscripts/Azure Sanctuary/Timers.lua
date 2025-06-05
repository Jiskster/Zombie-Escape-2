ZE2:AddTimer("AZURESANCTUARY_1", {
	text = "Defend Temple Gate",
	time = 25*TICRATE,
	on_end_tag = 25,
	textcolor = SKINCOLOR_BLUE,
	lua_linedef_exec = "AZURTIMER1",
})

ZE2:AddTimer("AZURESANCTUARY_2", {
	text = "Defend Debris",
	time = 35*TICRATE,
	on_end_tag = 39,
	textcolor = SKINCOLOR_GREY,
	lua_linedef_exec = "AZURTIMER2",
})

ZE2:AddTimer("AZURESANCTUARY_3", {
	text = "Reach the top of the Temple",
	time = 35*TICRATE,
	on_end_tag = 6,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "AZURTIMER3",
})

ZE2:AddTimer("AZURESANCTUARY_4", {
	text = "Protect the Raft",
	time = 15*TICRATE,
	on_end_tag = 92,
	textcolor = SKINCOLOR_BROWN,
	lua_linedef_exec = "AZURTIMER4",
})