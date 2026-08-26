local PATH = "game/Core/Player/Zombie VFX"

local function LoadVFX(_path)
	dofile(PATH .. "/" .. _path .. "/vfx.lua")
end

LoadVFX("Infection")
LoadVFX("Blood Droplets")
LoadVFX("Alpha Overlay")