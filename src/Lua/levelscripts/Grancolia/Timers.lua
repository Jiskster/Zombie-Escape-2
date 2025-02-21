ZE2:AddTimer("GRANCOLIA_1", {
	text = "Defend Underground Barrier",
	time = 30*TICRATE,
	on_end_tag = 4,
	textcolor = SKINCOLOR_RUST,
	lua_linedef_exec = "GRANCOLIATIMER1",
})

ZE2:AddTimer("GRANCOLIA_2", {
	text = "Defend Huge Barrier",
	time = 40*TICRATE,
	on_end_tag = 8,
	textcolor = SKINCOLOR_RUST,
	lua_linedef_exec = "GRANCOLIATIMER2",
})

ZE2:AddTimer("GRANCOLIA_3", {
	text = "Defend Final Barrier",
	time = 20*TICRATE,
	on_end_tag = 11,
	textcolor = SKINCOLOR_RUST,
	lua_linedef_exec = "GRANCOLIATIMER3",
})