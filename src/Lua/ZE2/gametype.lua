/* Was meant for the ringslinger-esk system. Might use this name for separating 
what ZE2 has.

rawset(_G, "XSLINGER", {});
*/

rawset(_G, "ze2_modname", "ze2"); -- For customhud.

freeslot("TOL_ZE2");

ZE2.wait_time = 15*TICRATE;
ZE2.MapVoteStartFrame = 10*TICRATE -- TODO: Remove
ZE2.VoteTimeLimit = 12*TICRATE -- TODO: Remove

-- so it looks better by adding idk
local newroundframe = 15*TICRATE
local newmapframe = newroundframe + 8*TICRATE

ZE2.IntermissionVars = {
	newroundframe = newroundframe;
	newmapframe = newmapframe;
	slideout_anim = 3*TICRATE/2;
}

ZE2.queuing_round = false
ZE2.rounds_left = 3

ZE2.PreviousMaps = {}

ZE2.JumpSprintFatigue = 17*FRACUNIT

ZE2.HUD = {}

local flame_colors = {
	SKINCOLOR_FLAME, SKINCOLOR_KETCHUP, SKINCOLOR_GARNET, SKINCOLOR_ORANGE, --SKINCOLOR_RUST, SKINCOLOR_COPPER
}

xSlinger.registerEffect("alphazombie.rage", {
	tick = function(effect, mobj, time_left)
		local g = P_SpawnGhostMobj(mobj)
		g.destscale = 0
		g.fuse = TICRATE
		g.scalespeed = FixedDiv(g.scale, g.fuse*FU)
		g.blendmode = AST_SUBTRACT
		g.renderflags = RF_FULLBRIGHT
	end;
	endfunc = function(effect, mobj)
		S_StartSound(mobj, sfx_bstdn)
	end
})

xSlinger.registerEffect("burning", {
	tick = function(effect, mobj, time_left)
		if mobj and mobj.valid then
			if (time_left % 20) == 0 then
				local damage = 35
				if (mobj.team == 1) then
					damage = 2
				end
				
				P_DamageMobj(mobj, nil, mobj.flameringtarget, damage)
				S_StartSoundAtVolume(nil, sfx_s248, 127, mobj.player)
				S_StartSoundAtVolume(nil, sfx_s3kc2s, 127, mobj.player)
			end
			
			local rad = FixedDiv(mobj.radius, mobj.scale)/FU
			local hei = FixedDiv(mobj.height, mobj.scale)/FU
			if (time_left % 3) == 0 then
				for i = 0,1
					-- P_SpawnMobjFromMobj already scales offsets.
					local flm = P_SpawnMobjFromMobj(mobj, 
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
		mobj.flameringtarget = nil
	end;
})

/*
	Linedef arguments:

	String arg2: effect name

	(Set arguments to -1 to have them be ignored)
	argument 1: Effect duration (in tics)

	argument 2: player->normalspeed (in int)
	argument 3: normalspeed multiplier (in fixed)
				how to calculate fixed scale:
				1. take a decimal (1.75)
				2. multiply 65536 by the decimal (65536 * 1.75 = 114 688)
				3. round down if necessary

	argument 4: player->actionspd (in int)
	argument 5: actionspd multiplier (in fixed)

	argument 6: charability

	argument 7: damage multiplier (in fixed)
	argument 8: knockback multiplier (in fixed)

*/
local index_to_attrib = {
	[1] = "normalspeed",
	[2] = "normalspeed_multiplier",
	[3] = "actionspd",
	[4] = "actionspd_multiplier",
	[5] = "charability",
	[6] = "damage_multiplier",
	[7] = "knockback_multiplier"
}

local index_mul = {
	[1] = FU,
	[2] = 1,
	[3] = FU,
	[4] = 1,
	[5] = 1,
	[6] = 1,
	[7] = 1
}

addHook("LinedefExecute", function(line, mo)
	if not udmf then return end
	if not (mo.player and mo.player.valid) then return end
	if not (mo.health) then return end

	local args = line.args

	local effect_attribs = {}
	local effect_name = line.stringargs[1]
	local effect_duration = args[0]
	for i = 1, 5 do
		if args[i] == -1 then continue; end
		effect_attribs[index_to_attrib[i]] = args[i] * index_mul[i]
	end

	if xSlinger.Effects[effect_name] == nil
		print('\x82WARNING\x80: Effect name "'..effect_name..'" is not valid. (line #'..(#line)..')')
		return
	end

	mo:give_effect(effect_name, effect_attribs, effect_duration)
end, "ZE2_GIVEPLREFFECT")

G_AddGametype({
	name = "Escape Mode",
	identifier = "ze2",
	typeoflevel = TOL_ZE2,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none, -- No intermission screen for possible inbuilt screen.
	--headerleftcolor = 152,
	--headerrightcolor = 40,
	description = "Escape from the Zombies! Don't get caught and eaten by them! They can catch up with you anytime..."
})

xSlinger.registerGametype(GT_ZE2, {
	teams = {
		{
			name = "Survivors";
		},
		{
			name = "Zombies";
			iframes = 0;
		}
	}
})

xSlinger.skin_properties["zsonic"] = {
	hurtsound = {sfx_zpa1, sfx_zpa2};
}

--LUT
ZE2.paletteToColor = {}
for i=0,255 do
	local color = freeslot("SKINCOLOR__"..i)
	
	local new_ramp = {}
	for ii=1,16 do
		new_ramp[ii] = i
	end
	
	skincolors[color] = {
		name = "_"..tostring(i);
		ramp = new_ramp;
		invcolor = SKINCOLOR_ORANGE;
		invshade = 9;
		chatcolor = V_BLUEMAP;
		accessible = false;
	}
	ZE2.paletteToColor[i] = color
end
