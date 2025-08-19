ZE2:AddTimer("SecretLab1_1", {
	text = "The Final Gate will open in:",
	time = 60*TICRATE,
	on_end_tag = 11,
	textcolor = SKINCOLOR_YELLOW,
	lua_linedef_exec = "SCLAB1_1",
})