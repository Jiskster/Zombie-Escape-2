-- These variables are initiated into the ZE2 global.
-- Initiate require.lua first.

local queue = {
	"require", -- Remember, initiate this first!!!
	"copy", -- Always second.
	"player/init",
	"player/thinker",
	"init_gamevars",
	"getMaxRoundsFromMap",
	"getCurrentRound",
	"zCollide",
	"skinlist",
}

for i,path in ipairs(queue) do
	print(path + " DONE!")
	dofile("functions/global/" + path)
end