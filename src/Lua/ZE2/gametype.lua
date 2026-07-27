/* Was meant for the ringslinger-esk system. Might use this name for separating
what ZE2 has.

rawset(_G, "XSLINGER", {});
*/

rawset(_G, "ze2_modname", "ze2"); -- For customhud.

freeslot("TOL_ESCAPE", "TOL_SWARM", "TOL_PLAGUE");

ZE2.wait_time = 15*TICRATE;

ZE2.MaxKarma = 500

ZE2.CharacterSlots = {}

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

xSlinger.registerEffect("alphazombie.rage_regen", {
	max_duration = TICRATE,

	---@param effect table
	---@param mobj mobj_t
	---@param time_left tic_t
	tick = function(effect, mobj, time_left)
		local player = mobj.player

		if not (player and player.valid) then 
			return
		end

		if (player.ze2.special_cooldown <= 0) then 
			return 
		end

		player.ze2.special_cooldown = player.ze2.special_cooldown - 2

		if (player.ze2.special_cooldown < 0) then
			player.ze2.special_cooldown = 0
		end
	end;
})

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

	if xSlinger.Effects[effect_name] == nil then
		print('\x82WARNING\x80: Effect name "'..effect_name..'" is not valid. (line #'..(#line)..')')
		return
	end

	mo:give_effect(effect_name, effect_attribs, effect_duration)
end, "ZE2_GIVEPLREFFECT")

-- ze2_info only
function ZE2:TryBooleanAction(player, _table, strict)
	if not _table then
		if strict == true then
			error("Table expected")
		end
		return false
	end

	if _table.var == nil then
		if strict == true then
			error("Var expected")
		end

		return false
	end

	if (_table.condition) then
		if not player.ze2[_table.var] then
			if _table.action then
				_table.action()
			end
		end

		player.ze2[_table.var] = true
	else
		player.ze2[_table.var] = false
	end

	return true
end

G_AddGametype({
	name = "Escape Mode",
	identifier = "ze2",
	typeoflevel = TOL_ESCAPE,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none, -- We have ingame intermission, so we dont need an intermission type
	headerleftcolor = 152,
	headerrightcolor = 40,
	description = "Escape from the Zombies! Don't get caught and eaten by them! They can catch up with you anytime..."
})

G_AddGametype({
	name = "Swarm Mode",
	identifier = "swarm",
	typeoflevel = TOL_SWARM,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none,
	eaderleftcolor = 152,
	headerrightcolor = 40,
	description = "WIP"
})

G_AddGametype({
	name = "Plague Mode",
	identifier = "plague",
	typeoflevel = TOL_PLAGUE,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none,
	eaderleftcolor = 152,
	headerrightcolor = 40,
	description = "WIP"
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
