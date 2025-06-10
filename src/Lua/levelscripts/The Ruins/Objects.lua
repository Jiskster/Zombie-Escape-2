freeslot("MT_FLOWEY1", "S_FLOWEY1", "SPR_FLWE")
freeslot("MT_DTREE", "S_DTREE", "SPR_DTRE")
freeslot("MT_TORIEL", "S_TORI_STND", "S_TORI_DIE1")
freeslot("MT_TORIEL2", "SPR_TORI", "S_TORI_FRIENDLY")
freeslot("S_TORI_DIE1", "S_TORI_DIE2")
freeslot("S_TORI_PAW")

states[S_FLOWEY1] = {
    sprite = SPR_FLWE,
    frame = A,
    tics = 2,
    nextstate = S_FLOWEY1
}

mobjinfo[MT_FLOWEY1] = {
	--$Title Flowey
	--$Sprite FLWEA0
	--$Category Undertale
    doomednum = 1562,
    spawnstate = S_FLOWEY1,
    spawnhealth = 1,
    radius = 21*FRACUNIT,
    height = 21*FRACUNIT,
    flags = MF_SPECIAL,
    speed = 0,
    deathstate = S_FLOWEY1, -- Optional, redundant unless it changes
    painstate = 0,
    painsound = 0,
    deathsound = 0
}

states[S_DTREE] = {
    sprite = SPR_DTRE,
    frame = A,
    tics = 2,
    nextstate = S_DTREE
}

mobjinfo[MT_DTREE] = {
	--$Title Dead Tree
	--$Sprite DTREA0
	--$Category Undertale
    doomednum = 1561,
    spawnstate = S_DTREE,
    spawnhealth = 1,
    radius = 256*FRACUNIT,
    height = 281*FRACUNIT,
    flags = MF_SOLID,
    speed = 0,
    deathstate = S_DTREE, -- Optional, redundant unless it changes
    painstate = 0,
    painsound = 0,
    deathsound = 0
}

-- In order of appearance

mobjinfo[MT_TORIEL2] = {
	--$Title Toriel Prop
	--$Sprite TORIA0
	--$Category Undertale
	doomednum = 1563,
	spawnstate = S_TORI_FRIENDLY,
	painstate = S_TORI_FRIENDLY,
	deathstate = S_TORI_FRIENDLY,
	spawnhealth = 1,
	speed = 0,
	radius = 150*FRACUNIT,
	height = 205*FRACUNIT,
	painsound = 0,
	deathsound = 0,
	flags = MF_NOCLIPTHING,
}

states[S_TORI_FRIENDLY] = {
	sprite = SPR_TORI,
	frame = A,
	tics = 2,
	nextstate = S_TORI_FRIENDLY
}

mobjinfo[MT_TORIEL] = {
	--$Title Toriel Boss
	--$Sprite TORIA0
	--$Category Undertale
	doomednum = 1560,
	spawnstate = S_TORI_STND,
	spawnhealth = 6000,
	seestate = S_TORI_STND,
	seesound = sfx_None,
	reactiontime = 5,
	attacksound = sfx_None,
	painstate = S_TORI_STND,
	painchance = 0,
	painsound = sfx_utatk2,
	deathstate = S_TORI_DIE1,
	deathsound = sfx_utdi,
	xdeathstate = S_TORI_STND,
	speed = 15,
	radius = 150 * FRACUNIT,
	height = 205 * FRACUNIT,
	mass = 0,
	damage = 3,
	activesound = 0,
	raisestate = S_TORI_STND,
	flags = MF_SPECIAL | MF_SHOOTABLE | MF_BOSS
}

mobjinfo[MT_TORIEL].npc_name = "Toriel"
mobjinfo[MT_TORIEL].npc_name_color = SKINCOLOR_WHITE
mobjinfo[MT_TORIEL].npc_spawnhealth = {10000,20000}
--mobjinfo[MT_TORIEL].rubydrop = {30,60}
mobjinfo[MT_TORIEL].forcedamage = 1000
mobjinfo[MT_TORIEL].antiknockback = true

states[S_TORI_STND] = {
	sprite = SPR_TORI,
	frame = A,
	tics = -1,
	nextstate = S_TORI_STND,
}

states[S_TORI_DIE1] = {
	sprite = SPR_TORI,
	frame = B,
	tics = 35,
	nextstate = S_TORI_DIE2
}

states[S_TORI_DIE2] = {
	sprite = SPR_TORI,
	frame = C,
	tics = 70,
	nextstate = S_RINGEXPLODE
}


states[S_TORI_PAW] = {
	sprite = SPR_TORI,
	frame = D,
	tics = -1,
	nextstate = S_TORI_PAW
}
