local PATH = "game/Core/Effects"

local function LoadEffect(_path)
	dofile(PATH .. "/" .. _path .. "/effect.lua")
end

LoadEffect("Burning")
LoadEffect("Rage")
LoadEffect("Rage Regen")