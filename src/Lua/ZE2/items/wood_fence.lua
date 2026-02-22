freeslot("MT_PROPWOOD","S_PROP1","S_PROP1_PAIN","S_PROP1_BREAK","SPR_WPRP")

mobjinfo[MT_PROPWOOD] = {
    sprite = SPR_WPRP,
	spawnstate = S_PROP1,
	painstate = S_PROP1_PAIN,
	painsound = sfx_dmpain,
	deathstate = S_PROP1_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 50,
	speed = 0,
	radius = 96*FRACUNIT,
	height = 138*FRACUNIT,
	flags = MF_SHOOTABLE|MF_SOLID|MF_SPECIAL,
}

mobjinfo[MT_PROPWOOD].npc_name = "Wood Fence"
mobjinfo[MT_PROPWOOD].npc_spawnhealth = {300,600}
mobjinfo[MT_PROPWOOD].npc_name_color = SKINCOLOR_BROWN

states[S_PROP1] = {
	tics = 1,
	sprite = SPR_WPRP,
	frame = FF_FULLBRIGHT|FF_PAPERSPRITE,
	nextstate = S_PROP1,
	action = function(mo)
		--Crush the fence if its getting crushed (duh)
		if (mo.ceilingz - mo.floorz < mo.height) then
			P_KillMobj(mo, nil, nil, DMG_CRUSHED)
		end
	end
}

states[S_PROP1_PAIN] = {
	tics = 4,
	sprite = SPR_WPRP,
	frame = C|FF_FULLBRIGHT|FF_PAPERSPRITE,
	nextstate = S_PROP1,
}

states[S_PROP1_BREAK] = {
	nextstate = S_NULL,
	sprite = SPR_WPRP,
	action = function(mo)
		A_Scream(mo)

		--Cool !
		local real_rad = FixedDiv(mo.radius,mo.scale) >> FRACBITS
		local fa = mo.angle
		for i = 0, 16 do
			local sign = (i & 1) and 1 or -1
			local plank = P_SpawnMobjFromMobj(mo,
				P_ReturnThrustX(nil, fa, P_RandomRange(-real_rad, real_rad)*FU),
				P_ReturnThrustY(nil, fa, P_RandomRange(-real_rad, real_rad)*FU),
				P_RandomRange(0, FixedDiv(mo.height,mo.scale)>>FRACBITS)*FU,
				MT_THOK
			)
			plank.tics = -1
			plank.fuse = TICRATE

			plank.state = S_WOODDEBRIS
			plank.frame = $|FF_PAPERSPRITE

			plank.flags = MF_NOCLIP|MF_NOCLIPHEIGHT

			plank.angle = fa + P_RandomRange(-180,180)*ANG1
			plank.rollangle = FixedAngle(P_RandomRange(0,359)*FU+P_RandomFixed())

			P_Thrust(plank, fa, (P_RandomRange(1,10)*plank.scale +  P_RandomFixed()) * sign)
			P_SetObjectMomZ(plank,P_RandomRange(2,10)*FU+P_RandomFixed())
		end
		mo.flags2 = $|MF2_DONTDRAW
	end,
	frame = B,
	tics = TICRATE
}

freeslot("S_ZE2_WOODFENCE_DROP", "SPR_ZE2_WOODFENCE")

states[S_ZE2_WOODFENCE_DROP] = {
	sprite = SPR_ZE2_WOODFENCE, -- uhhh problematic naming???
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_WOODFENCE_DROP,
}

xSlinger.registerItem("wood_fence", {
	displayname = "Wood Fence";

	icon = "FENCEIND";

	dropstate = S_ZE2_WOODFENCE_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	firerate = TICRATE*5;

	count = 2;
	maxcount = 100;

	color = SKINCOLOR_BROWN;
	--TODO: it would be nice if we could get like a sort of indicator
	--		where the fence would be placed in first person
	usefunc = function(self, mo)
		local wood = P_SpawnMobj(mo.x+FixedMul(128*FRACUNIT, cos(mo.angle)),
					             mo.y+FixedMul(128*FRACUNIT, sin(mo.angle)),
								 mo.z, MT_PROPWOOD)
		wood.angle = mo.angle+ANGLE_90
		S_StartSound(mo, sfx_jshard)
		wood.renderflags = $|RF_PAPERSPRITE
		wood.team = mo.team
		wood.target = mo
	end;
	skin_override = {
		["tails"] = {
			firerate = TICRATE*3,
		}
	};
})

local function HeightCheck(wood, tmo)
	if (wood.z > (tmo.z + tmo.height)) or (tmo.z > (wood.z + wood.height)) then return false end
	return true
end

local function TeamCheck(wood, tmo)
	if tmo.player and tmo.player.valid
	and (wood.team == tmo.player.xSlinger.team) then
		return false
	end

	if (wood.team == tmo.team) then return false end
	
	return true
end

addHook("MobjCollide", function(wood, tmo)
	if not wood.health then return false end -- Skip earlier if we dont have health so don't do any unneeded checks
	if not HeightCheck(wood, tmo) then return end -- Do not run the hook anymore if tmo is not between the fence's height
	if wood.team and not TeamCheck(wood, tmo) then return false end -- Don't collide if it's on the same team
	if tmo.player then return true end --Block players only
end, MT_PROPWOOD)

addHook("TouchSpecial", function(_, _) return true end, MT_PROPWOOD)