local PATH = "game/Core/Libraries"

local function Load(_folder, _path)
	dofile(PATH .. "/".. _folder .."/" .. _path)
end

Load("Misc", "customhudlib.lua")
Load("Misc", "hudstuff.lua")
Load("Misc", "mobjlib.lua")
Load("Misc", "mtime.lua")

Load("Zombie Escape 2", "require.lua")
Load("Zombie Escape 2", "copy.lua")
Load("Zombie Escape 2", "zcollide.lua")
Load("Zombie Escape 2", "playercount.lua")
Load("Zombie Escape 2", "zombie_funcs.lua")
Load("Zombie Escape 2", "characterlib.lua")