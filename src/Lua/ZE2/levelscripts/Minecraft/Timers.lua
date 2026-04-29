ZE2:AddTimer("MC_PART1", {
	text = "Wooden Platform",
	time = 42*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8DWooden Platform is now leaving!")
		P_LinedefExecute(48)
		P_LinedefExecute(51)
	end,
	on_end_tag = 46,
	textcolor = SKINCOLOR_BROWN,
})

ZE2:AddTimer("MC_PART2", {
	text = "Obsidian Wall",
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8FThe Obsidian Wall has broken!")
	end,
	on_end_tag = 56,
	textcolor = SKINCOLOR_BLACK,
})

ZE2:AddTimer("MC_PART3", {
	text = "Iron Door",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8FThe Iron Door has broken!")
	end,
	on_end_tag = 61,
	textcolor = SKINCOLOR_WHITE,
})

ZE2:AddTimer("MC_PART4", {
	text = "Stone Platform",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x86The Stone Platform is now leaving the area!")
	end,
	on_end_tag = 63,
	textcolor = SKINCOLOR_GREY,
})

local function Minecraft_Part1()
	S_StartSound(nil, sfx_oldrad)
	ZE2:StartTimer("MC_PART1")
end

local function Minecraft_Part2()
	S_StartSound(nil, sfx_oldrad)
	S_ChangeMusic("MC2", true)
	mapmusname = "MC2"
	ZE2:StartTimer("MC_PART2")
end

local function Minecraft_Part3()
	S_StartSound(nil, sfx_oldrad)
	ZE2:StartTimer("MC_PART3")
end

local function Minecraft_Part4()
	S_StartSound(nil, sfx_oldrad)
	S_ChangeMusic("MC3", true)
	mapmusname = "MC3"
	ZE2:StartTimer("MC_PART4")
end

addHook("LinedefExecute", Minecraft_Part1, "47ACT1")
addHook("LinedefExecute", Minecraft_Part2, "47ACT2")
addHook("LinedefExecute", Minecraft_Part3, "47ACT3")
addHook("LinedefExecute", Minecraft_Part4, "47ACT4")