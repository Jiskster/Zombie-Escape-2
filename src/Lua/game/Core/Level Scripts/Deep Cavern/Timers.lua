ZE2:AddTimer("DEEP_CAVERN_1", {
	text = "Defend First Gate",
	time = 30*TICRATE,
	on_end_tag = 25,
	textcolor = SKINCOLOR_BLUE,
	lua_linedef_exec = "DEEPCAVEN1",
})

ZE2:AddTimer("DEEP_CAVERN_2", {
	text = "Break Through The Temple",
	time = 20*TICRATE,
	on_end_tag = 92,
	textcolor = SKINCOLOR_EMERALD,
	lua_linedef_exec = "DEEPCAVEN2",
})

ZE2:AddTimer("DEEP_CAVERN_3", {
	text = "Clear Debris",
	time = 40*TICRATE,
	on_end_tag = 112,
	textcolor = SKINCOLOR_AQUA,
	lua_linedef_exec = "DEEPCAVEN3",
})

ZE2:AddTimer("DEEP_CAVERN_4", {
	text = "Break Open A Hole",
	time = 50*TICRATE,
	on_end_tag = 143,
	textcolor = SKINCOLOR_RED,
	lua_linedef_exec = "DEEPCAVEN4",
})

// Glide KS's Alt Path Code
addHook("LinedefExecute", function()
	if P_RandomChance(FU/2) then
		P_LinedefExecute(111)
		S_StartSound(nil, sfx_s3k6f, nil)
		ZE2:StartTimer("DEEP_CAVERN_3")
	end
end, "DEEPCAVEN3")