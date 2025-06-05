ZE2:AddTimer("ALT_NOXYLOUS_1", {
	text = "Defend Barrier",
	time = 25*TICRATE,
	on_end_tag = 2,
	textcolor = SKINCOLOR_BLUE,
	lua_linedef_exec = "ALTNOXYTIMER1",
})

ZE2:AddTimer("ALT_NOXYLOUS_2", {
	text = "Raising the bridge",
	time = 12*TICRATE,
	on_end_tag = 39,
	textcolor = SKINCOLOR_GREEN,
	lua_linedef_exec = "ALTNOXYTIMER2",
})

ZE2:AddTimer("ALT_NOXYLOUS_3", {
	text = "Defend Portal",
	time = 25*TICRATE,
	on_end_tag = 44,
	textcolor = SKINCOLOR_NEON,
	lua_linedef_exec = "ALTNOXYTIMER3",
})
