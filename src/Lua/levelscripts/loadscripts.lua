local path = "levelscripts"
local folder

local function dofolder(file)
	dofile(path.."/"..folder.."/"..file)
end

folder = "Waterfall";

dofolder("Timers");
dofolder("Objects");

folder = "Noxy"; dofolder("Timers");

folder = "Grancolia"; dofolder("Timers");

folder = "Marble Depths"; dofolder("Timers");

folder = "Doomed Corp";

dofolder("Sounds");
dofolder("Electric_Sparkles");
dofolder("Objects");
dofolder("Timers");
dofolder("Global_Sounds");

folder = "Fatal Desert"; dofolder("Timers");

folder = "Alphacombs"; dofolder("Timers");

folder = "Lost Sewer"; 

dofolder("Timers");
dofolder("Enemies");

folder = "Spooky Flower"; dofolder("Timers");

folder = "Corrupted Void"; dofolder("Timers");

folder = "Westopolis"; dofolder("Timers");

folder = "Egg Fortress"; dofolder("Timers");

folder = "Azure Sanctuary"; dofolder("Timers");

folder = "Ancient Catacombs"; dofolder("Timers");

folder = "Minecraft"; 

dofolder("Timers");
dofolder("Footsteps");
dofolder("Sounds_and_Objects");

folder = "Acid Base"; dofolder("Timers");

folder = "The Ruins"; 

dofolder("Sounds")
dofolder("Objects")
dofolder("Timers")
dofolder("BlockZombies")
dofolder("TorielBoss")