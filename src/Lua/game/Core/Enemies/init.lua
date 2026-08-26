local PATH = "game/Core/Enemies"

local function LoadEnemies(subpath)
	dofile(PATH.."/"..subpath.."/enemies.lua")
end

LoadEnemies("Vanilla")
LoadEnemies("DOOM")