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
mobjinfo[MT_PROPWOOD].npc_spawnhealth = {150,250}
mobjinfo[MT_PROPWOOD].npc_name_color = SKINCOLOR_BROWN

states[S_PROP1] = {
	tics = 1,
	sprite = SPR_WPRP,
	frame = FF_FULLBRIGHT|FF_PAPERSPRITE,
	nextstate = S_PROP1,
	action = function(mo)
		--Crush the fence if its getting crushed (duh)
		if ((mo.ceilingz - mo.floorz) < mo.height) then
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

freeslot("MT_PROPCHECK")

addHook("MobjLineCollide", function(check, line)
	return false
end, MT_PROPCHECK)

addHook("MobjMoveCollide", function(check, mobj)
	if not check or not check.valid then return end
	if not (mobj.flags & MF_SOLID) then return false end
	if not ZE2.ZCollide(check, mobj) then return false end
	if mobj.player and mobj.player.valid then
		if (mobj.player.xSlinger.team == check.target.player.xSlinger.team) then return false end
	end
	return true
end, MT_PROPCHECK)

---@param mobj mobj_t
local function FenceCheck(mobj)
	if not P_IsObjectOnGround(mobj) then return false end

	local distance = 128 * FU
	local x = mobj.x + FixedMul(distance, cos(mobj.angle))
	local y = mobj.y + FixedMul(distance, sin(mobj.angle))
	local z = mobj.z
	local check = P_SpawnMobj(x, y, z, MT_PROPCHECK)
	check.target = mobj
	check.height = mobjinfo[MT_PROPWOOD].height
	check.radius = mobjinfo[MT_PROPWOOD].radius
	check.scale = FU
	check.flags2 = MF2_DONTDRAW
	check.alpha = 0
	check.fuse = 2

	if not P_CheckPosition(check, x, y) then return false end
	if (check.floorz < (mobj.z - check.height)) then return false end
	if (check.floorz > (mobj.z + mobj.height)) then return false end
	if (check.ceilingz < (check.z + check.height)) then return false end
	return true
end

---@param self any
---@param mobj mobj_t
local function FenceVisual(self, mobj)
	local distance = 128 * FU
	local x = mobj.x + FixedMul(distance, cos(mobj.angle))
	local y = mobj.y + FixedMul(distance, sin(mobj.angle))
	local z = mobj.z

	local visual = mobj.visual_fence
	if not visual or not visual.valid then
		visual = P_SpawnMobj(x, y, z, MT_ZVISUAL)
		mobj.visual_fence = visual
	end

	local valid = FenceCheck(mobj)
	visual.height = mobjinfo[MT_PROPWOOD].height
	visual.radius = mobjinfo[MT_PROPWOOD].radius
	visual.momx = mobj.momx
	visual.momy = mobj.momy
	visual.momz = mobj.momz
	visual.sprite = SPR_WPRP
	visual.frame = 0|FF_ADD
	visual.angle = mobj.angle + ANGLE_90
	P_MoveOrigin(visual, x, y, z)

	local color = valid and SKINCOLOR_TURQUOISE or SKINCOLOR_RED
	visual.color = color
	visual.colorized = true
	visual.drawonlyforplayer = mobj.player
	visual.alpha = FU / 2
	visual.fuse = 3
end

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
	holdfunc = FenceVisual;

	--TODO: it would be nice if we could get like a sort of indicator
	--		where the fence would be placed in first person
	usefunc = function(self, mo)
		if not FenceCheck(mo) then return true end

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
			firerate = TICRATE*25,
			count = -1,
			maxcount = -1,
			background_color = SKINCOLOR_ORANGE,
		}
	};

	hold_object = {
		state = S_ZE2_WOODFENCE_DROP;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU;
			y = FU/2;
			z = 0;
		};
		pos_anim = {
			x = -FU;
			y = (FU*3)/2;
			z = -FU/3;
		};
	};

	hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
})

local function TeamCheck(wood, tmo)
	if tmo.player and tmo.player.valid
	and (wood.team == tmo.player.xSlinger.team) then
		return true
	end

	if (wood.team == tmo.team) then return true end

	return false
end

addHook("MobjCollide", function(wood, tmo)
	if not wood.health then return false end -- Skip earlier if we dont have health so don't do any unneeded checks
	if not ZE2.ZCollide(wood, tmo) then return end -- Do not run the hook anymore if tmo is not between the fence's height
	if wood.team and TeamCheck(wood, tmo) then return false end -- Don't collide if it's on the same team
	if tmo.player then return true end --Block players only
end, MT_PROPWOOD)

addHook("TouchSpecial", function(_, _) return true end, MT_PROPWOOD)