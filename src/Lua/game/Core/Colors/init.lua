local PATH = "game/Core/Colors"

local function addColor(_path)
	dofile(PATH .. "/" .. _path .. "/color.lua")
end 

addColor("Chroma")
addColor("Zombie")