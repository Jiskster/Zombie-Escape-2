freeslot("MT_MCTORCH","S_MCTORCH","SPR_MCTR")
freeslot("MT_CREEPER","S_CREEPER","SPR_CRPR")
local mcmapnum = G_FindMapByNameOrCode("MAPJ4")

mobjinfo[MT_MCTORCH] = {
	doomednum = 2308,
	spawnstate = S_MCTORCH,
	spawnhealth = 100,
	reactiontime = 8,
	radius = 8*FRACUNIT,
	height = 16*FRACUNIT,
	flags =	MF_NOBLOCKMAP|MF_NOGRAVITY|MF_SCENERY,
	seestate = S_MCTORCH,
}

states[S_MCTORCH] = {
	sprite = SPR_MCTR,
	frame = A,
	tics = 0,
	nextstate = S_MCTORCH,
}

mobjinfo[MT_CREEPER] = {
	doomednum = 2309,
	spawnstate = S_CREEPER,
	spawnhealth = 100,
	reactiontime = 8,
	radius = 20*FRACUNIT,
	height = 85*FRACUNIT,
	flags =	MF_ENEMY|MF_SPECIAL|MF_SHOOTABLE,
	seestate = S_CREEPER,
}
mobjinfo[MT_CREEPER].npc_name = "Creeper"
mobjinfo[MT_CREEPER].npc_spawnhealth = {80,80}

states[S_CREEPER] = {
	sprite = SPR_CRPR,
	frame = A,
	tics = 0,
	nextstate = S_CREEPER,
}

ZE2:AddTimer("MC_PART1", {
	text = "Wooden Platform",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8D\Wooden Platform is now leaving!")
		P_LinedefExecute(46)
		P_LinedefExecute(48)
		P_LinedefExecute(51)
	end,
	textcolor = SKINCOLOR_BROWN,
}) 

ZE2:AddTimer("MC_PART2", {
	text = "Obsidian Wall",
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8F\The Obsidian Wall has broken!")
		P_LinedefExecute(56)
	end,
	textcolor = SKINCOLOR_BLACK,
}) 

ZE2:AddTimer("MC_PART3", {
	text = "Iron Door",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x8F\The Iron Door has broken!")
		P_LinedefExecute(61)
	end,
	textcolor = SKINCOLOR_WHITE,
}) 

ZE2:AddTimer("MC_PART4", {
	text = "Stone Platform",
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		chatprint("\x86\The Stone Platform is now leaving the area!")
		P_LinedefExecute(63)
	end,
	textcolor = SKINCOLOR_GREY,
}) 

local function Minecraft_Part1()
	chatprint("\x8D\Wooden Platform \x80will leave in\x85 30 \x80seconds")
	S_StartSound(nil, sfx_oldrad)
	ZE2:StartTimer("MC_PART1")
end

local function Minecraft_Part2()
	chatprint("\x8F\Obsidian Wall \x80will break in\x85 40 \x80seconds")
	S_StartSound(nil, sfx_oldrad)
	S_ChangeMusic("MC2", true)
	mapmusname = "MC2"
	ZE2:StartTimer("MC_PART2")
end

local function Minecraft_Part3()
	chatprint("Iron Door will open in\x82 30 \x80seconds")
	S_StartSound(nil, sfx_oldrad)
	ZE2:StartTimer("MC_PART3")
end

local function Minecraft_Part4()
	chatprint("\x86\Stone Platform \x80will leave in\x85 30 \x80seconds")
	S_StartSound(nil, sfx_oldrad)
	S_ChangeMusic("MC3", true)
	mapmusname = "MC3"
	ZE2:StartTimer("MC_PART4")
end

addHook("LinedefExecute", Minecraft_Part1, "47ACT1")
addHook("LinedefExecute", Minecraft_Part2, "47ACT2")
addHook("LinedefExecute", Minecraft_Part3, "47ACT3")
addHook("LinedefExecute", Minecraft_Part4, "47ACT4")