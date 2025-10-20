-- These variables are initiated into the ZE2 global.
-- Initiate require.lua first.

local queue = {
	"Require"; -- Remember, initiate this first!!!
	"Copy"; -- Always second.
	"init_gamevars";
	"getMaxRoundsFromMap";
	"getCurrentRound";
	"ZCollide";
	"skinlist";
	"ResetPlayer";
	"PlayZombieSound";
	"ZombifyPlayer";
	"Knockback/initKnockback";
	"Knockback/addKnockback";
}

print("<ZE2>: Loading ZE2 Functions")
for i,path in ipairs(queue) do
	local full_path = ("ZE2/functions/ZE2/"..path)
	
	dofile(full_path)
end
print("<ZE2>: Finished ZE2 Functions")