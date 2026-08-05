local path = "levelscripts"
local folder

local function dofolder(file)
	dofile("ZE2/"..path.."/"..folder.."/"..file)
end

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