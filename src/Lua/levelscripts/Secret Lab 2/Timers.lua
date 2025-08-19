ZE2:AddTimer("SecretLab2_1", {
	text = "Elevator opens in:",
	time = 20*TICRATE,
	on_end_tag = 16,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "SCLAB2_1",
})

ZE2:AddTimer("SecretLab2_2", {
	text = "Elevator opens in:",
	time = 30*TICRATE,
	on_end_tag = 23,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "SCLAB2_2",
})

ZE2:AddTimer("SecretLab2_3", {
	text = "Doors will open in:",
	time = 25*TICRATE,
	on_end_tag = 36,
	textcolor = SKINCOLOR_GALAXY,
	lua_linedef_exec = "SCLAB2_3",
})

ZE2:AddTimer("SecretLab2_4", {
	text = "Gates will open in:",
	time = 15*TICRATE,
	on_end_tag = 41,
	textcolor = SKINCOLOR_WHITE,
	lua_linedef_exec = "SCLAB2_4",
})

ZE2:AddTimer("SecretLab2_5", {
	text = "The Final Gate will open in:",
	time = 60*TICRATE,
	on_end_tag = 30,
	textcolor = SKINCOLOR_YELLOW,
	lua_linedef_exec = "SCLAB2_5",
})