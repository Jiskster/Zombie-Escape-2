local PATH = "game/Core/Title Screen"

local function doTitleFile(_path)
	dofile(PATH .. "/" .. _path)
end

doTitleFile("HUD/titlehud.lua")
doTitleFile("Objects/survivor.lua")
doTitleFile("Objects/zombie.lua")