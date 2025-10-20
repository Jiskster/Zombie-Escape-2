if pcall(do return _G["MT_CORONA"] end)
    print("\131NOTICE:\128 Corona objects already loaded.")
    return
end

freeslot(
	"MT_CORONA",
	"S_CORONA",
	"SPR_CORO"
)

mobjinfo[MT_CORONA] = {
	//$Name Corona
	//$Category Starlit Skyway
	//$Sprite PRTLA0
	spawnstate = S_CORONA,
	reactiontime = 16,
	speed = 10*FRACUNIT,
	radius = 32*FRACUNIT,
	height = 32*FRACUNIT,
	damage = 3,
	spawnhealth = 0,
	dispoffset = 0,
	doomednum = 1510,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_SCENERY|MF_NOCLIPHEIGHT
}

states[S_CORONA] = {
	sprite = SPR_CORO,
	frame = A|FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_CORONA
}

addHook("MobjSpawn", function(actor)
	actor.blendmode = AST_ADD
end, MT_CORONA)