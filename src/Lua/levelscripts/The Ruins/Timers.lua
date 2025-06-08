ZE2:AddTimer("THERUINSUT_1", {
	text = "Defend Door",
	time = 45*TICRATE,
	on_end_tag = 201,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "THERUINSUT1",
})
