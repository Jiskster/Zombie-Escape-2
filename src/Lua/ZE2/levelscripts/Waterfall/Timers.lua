freeslot("sfx_UTMMRY")
sfxinfo[sfx_UTMMRY].caption = "" -- Not found

ZE2:AddTimer("WATERFALL_1", {
	text = "Defend Rock",
	time = 35*TICRATE,
	on_end_tag = 21,
	textcolor = SKINCOLOR_PURPLE,
	lua_linedef_exec = "WATERFALL1",
})

ZE2:AddTimer("WATERFALL_2", {
	text = "Defend Barrier",
	time = 45*TICRATE,
	on_end_tag = 22,
	textcolor = SKINCOLOR_AZURE,
	lua_linedef_exec = "WATERFALL2",
})

ZE2:AddTimer("WATERFALL_3", {
	text = "Leaving platform",
	time = 30*TICRATE,
	on_end_tag = 40,
	textcolor = SKINCOLOR_ORANGE,
	lua_linedef_exec = "WATERFALL3",
})
