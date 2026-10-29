freeslot("MT_PROPSTEEL", "S_STEELPROP", "SPR_SPRP")

mobjinfo[MT_PROPSTEEL] = {
	spawnstate = S_STEELPROP,
	painstate = S_PROP1_PAIN,
	painsound = sfx_dmpain,
	deathstate = S_PROP1_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 50,
	speed = 0,
	radius = 140*FRACUNIT,
	height = 138*FRACUNIT,
	flags = MF_SHOOTABLE|MF_SOLID|MF_SPECIAL,
}

states[S_STEELPROP] = {
	tics = 1,
	sprite = SPR_SPRP,
	frame = FF_FULLBRIGHT|FF_PAPERSPRITE,
	nextstate = S_STEELPROP,
	action = function(mo)
		--Crush the fence if its getting crushed (duh)
		if ((mo.ceilingz - mo.floorz) < mo.height) then
			P_KillMobj(mo, nil, nil, DMG_CRUSHED)
		end
	end
}

mobjinfo[MT_PROPSTEEL].npc_name = "Steel Fence"
mobjinfo[MT_PROPSTEEL].npc_spawnhealth = 1200
mobjinfo[MT_PROPSTEEL].npc_name_color = SKINCOLOR_BONE
mobjinfo[MT_PROPSTEEL].antiknockback = true

freeslot("S_ZE2_STEELFENCE_DROP", "SPR_ZE2_STEELFENCE")

states[S_ZE2_STEELFENCE_DROP] = {
	sprite = SPR_ZE2_STEELFENCE,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_STEELFENCE_DROP,
}

local item_wood_fence = xSlinger.registered_items["wood_fence"]

xSlinger.registerItem("steel_fence", {
	displayname = "Steel Fence",

	icon = "STEELFENCEIND",

	dropstate = S_ZE2_STEELFENCE_DROP,
	dropscale = 2*FU,
	dropyoffset = 8*FU,

	firerate = TICRATE*12,

	count = 1,
	maxcount = 3,

	placetype = MT_PROPSTEEL,
	placehealth = 2250,
	visplacesprite = SPR_SPRP,

	color = SKINCOLOR_BONE,
	holdfunc = item_wood_fence.holdfunc,

	usefunc = item_wood_fence.usefunc,
	skin_override = {
		["tails"] = {
			firerate = TICRATE*8,
			background_color = SKINCOLOR_ORANGE,
		}
	},

	hold_object = {
		state = S_ZE2_STEELFENCE_DROP;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU;
			y = FU/2;
			z = 0;
		},
		pos_anim = {
			x = -FU;
			y = (FU*3)/2;
			z = -FU/3;
		},
		spritescale = {
			x = 2*FU;
			y = 2*FU;
		}
	},

	hold_icon = "SPR_THOK", -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE,
})

local function TeamCheck(wood, tmo)
	if tmo.player and tmo.player.valid
	and (wood.team == tmo.team) then
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
end, MT_PROPSTEEL)

addHook("TouchSpecial", function(_, _) return true end, MT_PROPSTEEL)

addHook("MobjLineCollide", function(check, line)
	return false
end, MT_PROPSTEEL)

addHook("MobjMoveCollide", function(check, mobj)
	if not check or not check.valid then return end
	if (mobj.type == MT_ZE2CHECKPOINT) then return true end
	if (mobj.flags & MF_SPRING) and ZE2.ZCollide(check, mobj) then return true end
	if not (mobj.flags & MF_SOLID) then return false end
	if not ZE2.ZCollide(check, mobj) then return false end
	if mobj.player and mobj.player.valid then
		if (mobj.team == check.target.team) then return false end
	end
	return true
end, MT_PROPSTEEL)