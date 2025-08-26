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
	speed = 100*FRACUNIT,
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

local flame_colors = {
	SKINCOLOR_FLAME, SKINCOLOR_KETCHUP, SKINCOLOR_GARNET, SKINCOLOR_ORANGE, --SKINCOLOR_RUST, SKINCOLOR_COPPER
}

ZE2.Effects["flame_ring.on_fire"] = {
	thinker = function(player, time_left)
		if player and player.valid and player.mo and player.mo.valid then
			if (time_left % 20) == 0 then
				local damage = 35
				if (player.ze2.team == 1) then
					damage = 2
				end
				P_DamageMobj(player.mo, nil, player.flameringtarget, damage)
				S_StartSoundAtVolume(nil, sfx_s248, 127, player)
				S_StartSoundAtVolume(nil, sfx_s3kc2s, 127, player)
			end
			
			local rad = FixedDiv(player.mo.radius, player.mo.scale)/FU
			local hei = FixedDiv(player.mo.height, player.mo.scale)/FU
			if (time_left % 3) == 0 then
				for i = 0,1
					--P_SpawnMobjFromMobj already scales offsets.
					local flm = P_SpawnMobjFromMobj(player.mo, 
									P_RandomRange(-rad,rad)*FU, 
									P_RandomRange(-rad,rad)*FU, 
									P_RandomRange(0, hei)*FU,
								i and MT_FLAMEPARTICLE or MT_RS_THROWNFLAME)
					
					-- Make intangible.
					flm.flags = $|MF_NOCLIPTHING &~(MF_MISSILE)
					
					-- Make it look cool!
					flm.color = flame_colors[P_RandomRange(1, #flame_colors)]
					flm.frame = $ &~FF_TRANSMASK
					if (i == 0) then
						flm.fuse = TICRATE*3/4
						flm.scale = FU/2
					else
						flm.fuse = P_RandomRange(15,29)
						flm.scale = $ + P_RandomRange(0,FU/2)
					end
					flm.destscale = 0
					flm.scalespeed = FixedDiv(flm.scale, flm.fuse*FU)
					flm.blendmode = AST_ADD
					flm.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
					flm.dontdrawforviewmobj = player.mo
					if (i == 0) then
						-- P_SetObjectMomZ(flm,P_RandomRange(2,4)*player.mo.scale+P_RandomFixed())
					else
						P_SetObjectMomZ(flm, P_RandomRange(3,6)*FU)
					end
				end
			end
			local smoke = P_SpawnMobjFromMobj(player.mo,
				P_RandomRange(-rad,rad)*FU,
				P_RandomRange(-rad,rad)*FU,
				P_RandomRange(0,hei)*FU,
				MT_SMOKE
			)
			P_SetObjectMomZ(smoke,P_RandomRange(1,2)*player.mo.scale+P_RandomFixed())
			smoke.scale = $ + P_RandomRange(0,FU/2)
			smoke.alpha = FU/2
			smoke.dontdrawforviewmobj = player.mo
		end
	end,
	on_end = function(player)
		player.flameringtarget = nil
	end
}

local flame_ring = ZE2:CreateItem("flame_ring",  {
	displayname = "Flame Ring",
	icon = "FLAMIND",
	sound = sfx_None,
	firerate = 2,
	color = SKINCOLOR_ORANGE,
	autouse = true,
	damage = 8,
	knockback = 1*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 30,
	reload_time = TICRATE*5,
	price = 750,
	ontrigger = function(player, iteminfo)
		local pmo = player.mo
		
		local mt = MT_RS_THROWNFLAME
		local wave = sin(leveltime*ANG10) * 600
		local shot = ZE2.SpawnMissile({
			source = pmo, 
			mobj_type = mt,
			angle = pmo.angle + wave,
			allow_aim = true,
			iteminfo = iteminfo,
		})
		
		S_StartSound(shot, sfx_rs_fla)
		
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
			local player = mo.player -- mobj that was hit
			local pv = player.ze2

			player.ze2:GiveEffect("flame_ring.on_fire", {
				normalspeed_multiplier = FU/2,
				actionspd_multiplier = 3*FU/2,
				damage_multiplier = FU/2,
			}, 2*TICRATE)
			
			player.flameringtarget = src
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