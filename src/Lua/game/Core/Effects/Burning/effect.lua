local flame_colors = {
	SKINCOLOR_FLAME, SKINCOLOR_KETCHUP, SKINCOLOR_GARNET, SKINCOLOR_ORANGE, --SKINCOLOR_RUST, SKINCOLOR_COPPER
}

freeslot(
	"MT_ZE2_FLAME",
	"S_ZE2_FLAME1",
	"S_ZE2_FLAME2",
	"S_ZE2_FLAME3",
	"SPR_RNGF"
)

mobjinfo[MT_ZE2_FLAME] = {
	spawnstate = S_ZE2_FLAME1,
	deathstate = S_SPRK1,
	deathsound = sfx_s3k7e,
	speed = 100*FRACUNIT,
	radius = 24*FRACUNIT,
	height = 48*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY|MF_SLIDEME
}

states[S_ZE2_FLAME1] = {
	nextstate = S_ZE2_FLAME2,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS50|1,
	tics = 10
}
states[S_ZE2_FLAME2] = {
	nextstate = S_ZE2_FLAME3,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS40|2,
	tics = 10
}
states[S_ZE2_FLAME3] = {
	frame = FF_FULLBRIGHT|FF_TRANS30|3,
	tics = 20
}

xSlinger.registerEffect("burning", {
	max_duration = 8 * TICRATE,
	tick = function(effect, mobj, time_left)
		if mobj and mobj.valid then
			if (time_left % 20) == 0 then
				local damage = 35
				if (mobj.team == 1) then
					damage = 2
				end

				P_DamageMobj(mobj, nil, mobj.flameringtarget, damage)
				if not mobj or not mobj.valid then return end

				S_StartSoundAtVolume(nil, sfx_s248, 127, mobj.player)
				S_StartSoundAtVolume(nil, sfx_s3kc2s, 127, mobj.player)
			end

			local rad = FixedDiv(mobj.radius, mobj.scale)/FU
			local hei = FixedDiv(mobj.height, mobj.scale)/FU
			if (time_left % 3) == 0 then
				for i = 0,1 do
					-- P_SpawnMobjFromMobj already scales offsets.
					local flm = P_SpawnMobjFromMobj(mobj,
									P_RandomRange(-rad,rad)*FU,
									P_RandomRange(-rad,rad)*FU,
									P_RandomRange(0, hei)*FU,
								i and MT_FLAMEPARTICLE or MT_ZE2_FLAME)

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
					flm.dontdrawforviewmobj = mobj
					if (i == 0) then
						-- P_SetObjectMomZ(flm,P_RandomRange(2,4)*mobj.scale+P_RandomFixed())
					else
						P_SetObjectMomZ(flm, P_RandomRange(3,6)*FU)
					end
				end
			end
			local smoke = P_SpawnMobjFromMobj(mobj,
				P_RandomRange(-rad,rad)*FU,
				P_RandomRange(-rad,rad)*FU,
				P_RandomRange(0,hei)*FU,
				MT_SMOKE
			)
			P_SetObjectMomZ(smoke,P_RandomRange(1,2)*mobj.scale+P_RandomFixed())
			smoke.scale = $ + P_RandomRange(0,FU/2)
			smoke.alpha = FU/2
			smoke.dontdrawforviewmobj = mobj
		end
	end;
	endfunc = function(self, mobj)
		if not mobj or not mobj.valid then return end
		mobj.flameringtarget = nil
	end;
})
