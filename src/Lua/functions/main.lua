-- These variables are initiated into the ZE2 global.
-- Initiate require.lua first.

local queue = {
	"require", -- Remember, initiate this first!!!
	"copy", -- Always second.
	"init_gamevars",
	"getMaxRoundsFromMap",
	"getCurrentRound",
	"zCollide",
	"skinlist",
	"ResetPlayer",
	"PlayZombieSound",
	"ZombifyPlayer",
}

print("<ZE2>: Loading Global Functions")
for i,path in ipairs(queue) do
	dofile("functions/global/" + path)
end
print("<ZE2>: Finished Global Functions")