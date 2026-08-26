local folder

local function dofolder(file)
	dofile("game/Core/Level Scripts/"..folder.."/"..file)
end

-- [ EFFECT GIVING ] -

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

-- [ SET SECONDS ] -

-- You can only set it if the time left is lower than the previous
-- TODO: Flicker the game time red for a second when this gets called.
addHook("LinedefExecute", function(line, mo)
	local game = ZE2.Game
	if not udmf then return end
	if not (mo.player and mo.player.valid) then return end
	if not (mo.health) then return end
	if (game.ended) then return end

	local args = line.args
	local player = mo.player

	if (args[0] == -1) then return end
	
	local seconds = args[0]
	
	local newtime = seconds*TICRATE
	
	if newtime < game.state_tics then
		game.state_tics = newtime
	end
end, "ZE2_SETSECONDS")

-- [[ END OF LINEDEF EXECUTES ]] --

folder = "Waterfall";

dofolder("Timers");
dofolder("Objects");

folder = "Database Z"; dofolder("Timers");

folder = "Grancolia"; dofolder("Timers");

folder = "Doomed Corp";

dofolder("Sounds");
dofolder("Electric_Sparkles");
dofolder("Objects");
dofolder("Timers");
dofolder("AltPath_Triggering");
dofolder("Global_Sounds");

folder = "Frozen Chaos"; dofolder("Timers");

folder = "Lost Sewer";

dofolder("Timers");
dofolder("Enemies");

folder = "Spooky Flower"; dofolder("Timers");

folder = "Westopolis";

dofolder("Emerald");
dofolder("Timers");
dofolder("Path_Triggering");

folder = "Egg Fortress"; dofolder("Timers");

folder = "Azure Sanctuary"; dofolder("Timers");

folder = "Ancient Catacombs"; dofolder("Timers");

folder = "Minecraft";

dofolder("Timers");
dofolder("Footsteps");
dofolder("Sounds_and_Objects");

folder = "The Ruins";

dofolder("Sounds")
dofolder("Objects")
dofolder("Timers")
dofolder("BlockZombies")
dofolder("TorielBoss")
dofolder("FloweyStuff")

folder = "Secret Lab"; dofolder("Timers");

folder = "Fatal Desert"; dofolder("Timers");

folder = "Zombio Bros";

dofolder("Timers");
dofolder("Map Mechs");
dofolder("Objects");
