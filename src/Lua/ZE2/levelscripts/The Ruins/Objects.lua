freeslot("MT_FLOWEY1", "S_FLOWEY1", "SPR_FLWE")
freeslot("MT_DTREE", "S_DTREE", "SPR_DTRE")
freeslot("MT_TORIEL", "S_TORI_STND", "S_TORI_DIE1")
freeslot("MT_TORIEL2", "SPR_TORI", "S_TORI_FRIENDLY")
freeslot("MT_TORIELFIREBALL", "MT_TORIELFIREBALLTRAIL", "S_TORIELFIREBALL", "S_TORIELFIREBALLTRAIL1", "S_TORIELFIREBALLTRAIL2")
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
mobjinfo[MT_TORIEL].forcedamage = 10
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

-- cuz MT_FIREBALL is bad

states[S_TORIELFIREBALL] = {
	sprite = SPR_FBLL,
	frame = FF_FULLBRIGHT,
	tics = 1,
	action = A_SpawnObjectRelative,
	var1 = 0,
	var2 = MT_TORIELFIREBALLTRAIL,
	nextstate = S_TORIELFIREBALL,
	sprite2 = 0
}

states[S_TORIELFIREBALLTRAIL1] = {
	sprite = SPR_FBLL,
	frame = 1|FF_FULLBRIGHT|FF_TRANS50,
	tics = 1,
	action = A_SetScale,
	var1 = FRACUNIT*3/4,
	var2 = 0,
	nextstate = S_TORIELFIREBALLTRAIL2,
	sprite2 = 0
}

states[S_TORIELFIREBALLTRAIL2] = {
	sprite = SPR_FBLL,
	frame = 1|FF_FULLBRIGHT|FF_TRANS50,
	tics = 8,
	action = A_SetScale,
	var1 = FRACUNIT/6,
	var2 = 1,
	nextstate = S_NULL,
	sprite2 = 0
}

mobjinfo[MT_TORIELFIREBALLTRAIL] = {
	spawnstate = S_TORIELFIREBALLTRAIL1,
	spawnhealth = 1000,
	reactiontime = 8,
	radius = 16 * FRACUNIT,
	height = 16 * FRACUNIT,
	damage = 6,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_RUNSPAWNFUNC
}

mobjinfo[MT_TORIELFIREBALL] = {
	spawnstate = S_TORIELFIREBALL,
	spawnhealth = 1000,
	reactiontime = 8,
	speed = 40 * FRACUNIT,
	radius = 4 * FRACUNIT,
	height = 8 * FRACUNIT,
	mass = DMG_FIRE,
	damage = 6,
	flags = MF_FIRE|MF_BOUNCE
}

addHook("MobjMoveCollide", function (mobj, target)
	if not mobj or not mobj.valid then return false end
	if not target or not target.valid then return false end

	if (target.health <= 0) then return false end 
	if mobj.target and (mobj.target == target) then return false end

	local mobjheight, targetheight = FixedMul(mobj.height, mobj.scale), FixedMul(target.height, target.scale)
	if (target.z > (mobj.z + mobjheight)) then return false end
	if ((target.z + targetheight) < mobj.z) then return false end

	if not (target.flags & MF_SHOOTABLE) then
		return ((target.flags & MF_SOLID) ~= 0)
	end

	P_DamageMobj(target, mobj, mobj.target, mobj.info and mobj.info.damage or 1, DMG_FIRE)
	P_KillMobj(mobj, nil, nil, 0)
	return true
end, MT_TORIELFIREBALL)

addHook("MobjThinker", function (mobj)
	if not mobj or not mobj.valid then return end

	if (R_PointToDist2(0, 0, mobj.momx, mobj.momy) <= (16 * FRACUNIT))then
		P_KillMobj(mobj, nil, nil, 0)
		return
	end

	if (mobj.eflags & MFE_JUSTHITFLOOR) then
		mobj.momz = P_MobjFlip(mobj) * FixedMul(5 * FRACUNIT, mobj.scale);
	end
end, MT_TORIELFIREBALL)