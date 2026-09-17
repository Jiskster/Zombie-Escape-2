ZE2:AddTimer("FARLAND_1", {
	text = "Defend Rocks",
	time = 35*TICRATE,
	on_end_tag = 42,
	textcolor = SKINCOLOR_BEIGE,
	lua_linedef_exec = "FARLANDTIMER1",
})

ZE2:AddTimer("FARLAND_2", {
	text = "Defend Cave",
	time = 25*TICRATE,
	on_end_tag = 58,
	textcolor = SKINCOLOR_BLACK,
	lua_linedef_exec = "FARLANDTIMER2",
})

addHook("LinedefExecute", function(line, mobj, sector)
	chatprint("\x82" .. "* The ring is at the top! Reach for it!")
end, "FARLANDWARNING")