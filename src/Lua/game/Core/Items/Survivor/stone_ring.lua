freeslot(
	"S_ZE2_THROWNSTONE1", "S_ZE2_THROWNSTONE2", "S_ZE2_THROWNSTONE3", "S_ZE2_THROWNSTONE4",
	"S_ZE2_STONEBREAK", "S_ZE2_STONEDEBRIS"
)
freeslot("SPR_RNGK", "SPR_ROIQ")
freeslot("sfx_rs_sto")

local function A_StoneBreak(mo)
	for i = -2, 2 do
		local ang = i * ANG1 * 22
		local mobj = xSlinger.SpawnMissile({
			type = "STONE_DEBRIS",
			source = mo.target,
			origin = mo,
			angle = mo.target.angle + ang,
			iteminfo = mo.iteminfo,
			forceknockback = 50*FRACUNIT - abs(i)*FU*20,
			damage = 25,
			allow_aim = true
		})
		
		if mobj and mobj.valid then
			--mobj.scale = $ * 6/5
			mobj.shadowscale = FRACUNIT
			
			local momz = 7*FRACUNIT - abs(i)*FU
			if (mo.eflags & MFE_UNDERWATER) then
				momz = $ * 2/3
			end
			
			P_SetObjectMomZ(mobj, momz, false)
			
			if i == 0 then -- middle 
				S_StartSound(mobj, sfx_s3k59)
			end
		end
	end
end

states[S_ZE2_STONEBREAK] = {
	tics = 1,
	action = A_StoneBreak
}
states[S_ZE2_THROWNSTONE1] = {
	nextstate = S_ZE2_THROWNSTONE2,
	sprite = SPR_RNGK,
	frame = FF_FULLBRIGHT,
	tics = 1,
	--action = A_ThrownRing
}
states[S_ZE2_THROWNSTONE2] = {
	nextstate = S_ZE2_THROWNSTONE3,
	sprite = SPR_RNGK,
	frame = FF_FULLBRIGHT|1,
	tics = 1,
	--action = A_ThrownRing
}
states[S_ZE2_THROWNSTONE3] = {
	nextstate = S_ZE2_THROWNSTONE4,
	sprite = SPR_RNGK,
	frame = FF_FULLBRIGHT|2,
	tics = 1,
	--action = A_ThrownRing
}
states[S_ZE2_THROWNSTONE4] = {
	nextstate = S_ZE2_THROWNSTONE1,
	sprite = SPR_RNGK,
	frame = FF_FULLBRIGHT|3,
	tics = 1,
	--action = A_ThrownRing
}

states[S_ZE2_STONEDEBRIS] = {
	sprite = SPR_ROIQ,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	var1 = 7,
	var2 = 2,
	tics = 35
}

local missile_stone_ring = 
xSlinger.registerMissile("STONE_RING", {
	speed = 48*FRACUNIT,
	displayname = "Stone Ring",
	state = S_ZE2_THROWNSTONE1,
	deathstate = S_ZE2_STONEBREAK,
	radius = 32*FRACUNIT,
	height = 32*FRACUNIT,
	delflags = MF_NOGRAVITY,
})

local missile_stone_debris = 
xSlinger.registerMissile("STONE_DEBRIS", {
	speed = 23*FRACUNIT,
	displayname = "Stone Debris",
	state = S_ZE2_STONEDEBRIS,
	deathstate = S_INVISIBLE, -- TODO: if you remove this line, it errors for some reason, fix it.
	radius = 32*FRACUNIT,
	height = 48*FRACUNIT,
	addflags = MF_BOUNCE|MF_GRENADEBOUNCE,
	delflags = MF_NOGRAVITY,
	safeground = true,
	
	blocked = function(self, pmo, mo, line)
		if not line then
			return end;

		P_BounceMove(mo)
		
		return true
	end
})

xSlinger.registerItem("stone_ring", {
	
	-- HUD

	displayname = "Stone Ring",
	icon = "STONIND",
	animation_time = 20;
	
	-- Missile Properties
	
	missile = "STONE_RING",
	color = SKINCOLOR_BROWN,
	knockback = 50*FRACUNIT;
	knockback_tics = TICRATE;
	
	-- Item Properties
	
	damage = 150,
	ammo = 6,
	firerate = 18,
	reload_time = 4*TICRATE,
	sounds = {
		use = sfx_rs_sto,
		reload = {sfx_xsrel1, sfx_xsrel2},
		pickup = sfx_None,
		drop = sfx_None,
	},
	hold_object = {
		state = S_ZE2_THROWNSTONE1;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU,
			y = FU/2,
			z = 0,
		};
		pos_anim = {
			x = -FU,
			y = (FU*3)/2,
			z = -FU/3,
		},
	},
})