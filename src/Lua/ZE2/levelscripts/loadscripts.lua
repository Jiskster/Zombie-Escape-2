local path = "levelscripts"
local folder

local function dofolder(file)
	dofile("ZE2/"..path.."/"..folder.."/"..file)
end

-- You can only set it if the time left is lower than the previous
-- TODO: Flicker the game time red for a second when this gets called.
addHook("LinedefExecute", function(line, mo)
	if not udmf then return end
	if not (mo.player and mo.player.valid) then return end
	if not (mo.health) then return end

	local args = line.args
	local player = mo.player

	if (args[0] == -1) then return end
	
	local seconds = args[0]
	
	if ZE2.time_limit then
		local newtime = ZE2.time_limit - seconds*TICRATE

		if newtime >= ZE2.game_time then
			ZE2.game_time = newtime -- TODO: bro i don't like how ZE2.game_time is handled in general, it should count down.
		end
	end
end, "ZE2_SETSECONDS")

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
