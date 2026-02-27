freeslot(
	"sfx_dropen", "sfx_prtal", "sfx_ston", "sfx_trvel", "sfx_mclava", 
	"sfx_mcwatr", "SPR_MCSN", "S_MINECRAFTSUN",	"MT_MINECRAFTSUN",
	"MT_MCTORCH","S_MCTORCH","SPR_MCTR", "MT_CREEPER","S_CREEPER","SPR_CRPR"
)
sfxinfo[sfx_dropen].caption = "Iron Door opens"
sfxinfo[sfx_prtal].caption = "Portal ambience"
sfxinfo[sfx_ston].caption = "Block placed"
sfxinfo[sfx_trvel].caption = "Portal travels"
sfxinfo[sfx_mclava].caption = "Lava drips"
sfxinfo[sfx_mcwatr].caption = "Water flows"

states[S_MINECRAFTSUN] = {SPR_MCSN, A, -1, nil, 0, 0, S_MINECRAFTSUN}

mobjinfo[MT_MINECRAFTSUN] = {
		--$Title Minecraft Sun
		--$Sprite MCSNA0
		--$Category Minecraft
        doomednum = 1737,
        spawnstate = S_MINECRAFTSUN,
        speed = 0,
        radius = 5*FRACUNIT,
        height = 5*FRACUNIT,
        mass = 1,
		flags = MF_NOTHINK|MF_NOGRAVITY|MF_NOCLIP
}

mobjinfo[MT_MCTORCH] = {
	--$Title Minecraft Torch
	--$Sprite MCTRA0
	--$Category Minecraft
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
	--$Title Creeper
	--$Category Minecraft
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