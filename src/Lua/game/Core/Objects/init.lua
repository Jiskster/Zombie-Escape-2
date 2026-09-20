local PATH = "game/Core/Objects"

local function LoadMapObject(_path)
	dofile(PATH .. "/Map/" .. _path) 
end

local function LoadVFXObject(_path)
	dofile(PATH .. "/VFX/" .. _path)
end

LoadVFXObject("zvisual.lua")
LoadVFXObject("corona.lua")
LoadVFXObject("teleport.lua")
LoadVFXObject("itemdrop.lua")

LoadMapObject("ruby.lua")
LoadMapObject("rubycrate.lua")
LoadMapObject("megahp.lua")
LoadMapObject("exitring.lua")
LoadMapObject("checkpoint.lua")
LoadMapObject("worldtext.lua")