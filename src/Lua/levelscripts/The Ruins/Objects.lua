freeslot("MT_FLOWEY1", "S_FLOWEY1", "SPR_FLWE")
freeslot("MT_DTREE", "S_DTREE", "SPR_DTRE")
freeslot("MT_TORIEL2", "SPR_TORI", "S_TORI_FRIENDLY")

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
    flags = MF_NOCLIPTHING,
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