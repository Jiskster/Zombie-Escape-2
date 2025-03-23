-- RS NEO port.

freeslot(
	"MT_RS_THROWNFLAME",
	"S_RS_THROWNFLAME1",
	"S_RS_THROWNFLAME2",
	"S_RS_THROWNFLAME3",
	"SPR_RNGF",
	"sfx_rs_fla"
)

mobjinfo[MT_RS_THROWNFLAME] = {
	spawnstate = S_RS_THROWNFLAME1,
	deathstate = S_SPRK1,
	deathsound = sfx_s3k7e,
	speed = 80*FRACUNIT,
	radius = 24*FRACUNIT,
	height = 48*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY|MF_SLIDEME
}

states[S_RS_THROWNFLAME1] = {
	nextstate = S_RS_THROWNFLAME2,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS50|1,
	tics = 10
}
states[S_RS_THROWNFLAME2] = {
	nextstate = S_RS_THROWNFLAME3,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS40|2,
	tics = 10
}
states[S_RS_THROWNFLAME3] = {
	frame = FF_FULLBRIGHT|FF_TRANS30|3,
	tics = 20
}

sfxinfo[sfx_rs_fla] = {
	flags = SF_NOMULTIPLESOUND
}

ZE2.Effects["flame_ring.on_fire"] = {
	thinker = function(player, time_left)
		if player and player.valid and player.mo and player.mo.valid then
			if (time_left % 20) == 0 then
				P_DamageMobj(player.mo, nil, player.flameringtarget, 35)
			end
			
			if (time_left % 8) == 0 then
				local flm = P_SpawnMobjFromMobj(player.mo, 
								P_RandomRange(0, (player.mo.radius*2)/FU)*FU - player.mo.radius, 
								P_RandomRange(0, (player.mo.radius*2)/FU)*FU - player.mo.radius, 
								P_RandomRange(0, player.mo.height/FU)*FU,
							MT_RS_THROWNFLAME)
							
				-- Make intangible.
				flm.flags = $ & ~(MF_MISSILE)
				flm.flags = $ | MF_NOCLIPTHING
				
				flm.color = SKINCOLOR_ORANGE
				flm.destscale = FU/2
				flm.scale = FU/2
			end
		end
	end,
	on_end = function(player)
		player.flameringtarget = nil
	end
}

local flame_ring = ZE2:CreateItem("Flame Ring",  {
	icon = "FLAMIND",
	sound = sfx_None,
	firerate = 2,
	color = SKINCOLOR_ORANGE,
	autouse = true,
	damage = 8,
	knockback = 3*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 50,
	reload_time = TICRATE*4,
	price = 850,
	ontrigger = function(player, iteminfo)
		local pmo = player.mo
		
		local mt = MT_RS_THROWNFLAME
		S_StartSound(mo, sfx_rs_fla)
		local wave = sin(leveltime*ANG10) * 600
		local shot = ZE2.SpawnMissile({
			source = pmo, 
			mobj_type = mt,
			angle = pmo.angle + wave,
			allow_aim = true,
			iteminfo = iteminfo,
		})
		
		if not P_IsObjectOnGround(pmo) then
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(pmo) * aim > 0
				aim = $ * 2/8
			end
			pmo.momz = $ + FixedMul(pmo.scale, aim)
			P_Thrust(pmo, pmo.angle, -FRACUNIT*2/3)
		end
	end,
	onhit = function(src, mo, inf)
		if src and src.valid and src.player and src.player.valid 
		and mo and mo.valid and mo.player and mo.player.valid then
			ZE2:GivePlayerEffect(mo.player, "flame_ring.on_fire", {
				normalspeed_multiplier = FU/2,
				actionspd_multiplier = 3*FU/2,
				damage_multiplier = FU/2,
			}, 2*TICRATE)
			
			mo.player.flameringtarget = src
		end
	end
})

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid) return end
	mo.momx = $ * 85/100
	mo.momy = $ * 85/100
	mo.momz = $ * 85/100
	P_SetObjectMomZ(mo, FRACUNIT/5, true)
end, MT_RS_THROWNFLAME)

ZE2:RegisterShop_ItemID(flame_ring)