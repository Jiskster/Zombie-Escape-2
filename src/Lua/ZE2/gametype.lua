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

ZE2.DEFAULT_ROUNDS = 2
ZE2.queuing_round = false
ZE2.rounds_left = ZE2.DEFAULT_ROUNDS

ZE2.PreviousMaps = {}

ZE2.JumpSprintFatigue = 17*FRACUNIT

ZE2.HUD = {}

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
	name = "Escape (ZE2)",
	identifier = "ze2",
	typeoflevel = TOL_ESCAPE,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none, -- We have ingame intermission, so we dont need an intermission type
	headerleftcolor = 152,
	headerrightcolor = 40,
	description = "Escape from the Zombies! Don't get caught and eaten by them! They can catch up with you anytime..."
})

G_AddGametype({
	name = "Swarm (ZE2)",
	identifier = "swarm",
	typeoflevel = TOL_SWARM,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none,
	eaderleftcolor = 152,
	headerrightcolor = 40,
	description = "WIP"
})

G_AddGametype({
	name = "Plague (ZE2)",
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
