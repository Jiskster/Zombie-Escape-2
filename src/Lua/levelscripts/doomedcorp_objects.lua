freeslot("S_DC_CORPSE_SONIC",
	     "S_DC_CORPSE_TAILS1", 
		 "S_DC_CORPSE_TAILS2",
		 "S_DC_HEADCORPSE_INIT",
		 "S_DC_HEADCORPSE1",
		 "S_DC_HEADCORPSE2",
		 "MT_DCCORPSE_1",
		 "MT_DCCORPSE_2",
		 "MT_DCCORPSE_3",
		 "MT_DCCORPSE_4",
		 "SPR_CORP",
		 "SPR_CHED",
		 "S_DC_HEADCORPSE_SEEPLAYER",
		 "S_DC_HEADCORPSE_OPENCREEPYEYES")

--Sonic Corpse

states[S_DC_CORPSE_SONIC] = {SPR_CORP, A, -1, nil, 0, 0, S_DC_CORPSE_SONIC}


mobjinfo[MT_DCCORPSE_1] = {
		--$Title Sonic Corpse
		--$Sprite CORPA0
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1722,
        spawnstate = S_DC_CORPSE_SONIC,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 56*FRACUNIT,
        mass = 1,
}

--Tails Corpse 1

states[S_DC_CORPSE_TAILS1] = {SPR_CORP, B, -1, nil, 0, 0, S_DC_CORPSE_TAILS1}

mobjinfo[MT_DCCORPSE_2] = {
		--$Title Tails Corpse 1
		--$Sprite CORPB0
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1723,
        spawnstate = S_DC_CORPSE_TAILS1,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 56*FRACUNIT,
        mass = 1,
}

--Tails Corpse 2

states[S_DC_CORPSE_TAILS2] = {SPR_CORP, C, -1, nil, 0, 0, S_DC_CORPSE_TAILS2}

mobjinfo[MT_DCCORPSE_3] = {
		--$Title Tails Corpse 2
		--$Sprite CORPC0
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1724,
        spawnstate = S_DC_CORPSE_TAILS2,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 56*FRACUNIT,
        mass = 1,
}

--Deadly Head

states[S_DC_HEADCORPSE_INIT] = {SPR_CHED, A, 2, A_Look, 0, 0, S_DC_HEADCORPSE_INIT}
states[S_DC_HEADCORPSE_SEEPLAYER] = {SPR_CHED, A, 245, nil, 0, 0, S_DC_HEADCORPSE_OPENCREEPYEYES}
states[S_DC_HEADCORPSE_OPENCREEPYEYES] = {SPR_CHED, B, -1, nil, 0, 0, S_DC_HEADCORPSE_OPENCREEPYEYES}

mobjinfo[MT_DCCORPSE_4] = {
		--$Title Deadly Head
		--$Sprite CHEDA1
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1725,
        spawnstate = S_DC_HEADCORPSE_INIT,
		seestate = S_DC_HEADCORPSE_SEEPLAYER,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 20*FRACUNIT,
        mass = 1,
		flags = MF_NOGRAVITY
}

local colorableObjects = {MT_DCCORPSE_1,MT_DCCORPSE_2,MT_DCCORPSE_3,MT_DCCORPSE_4}

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
		return true
		end
	end
return false
end

addHook("MobjSpawn", function(mobj)
	if table.contains(colorableObjects, mobj.type) then
		mobj.color = P_RandomRange(1,158)
	end
end)