dofile "xSlinger/init.lua"

local function loadgame(_path)
	dofile("game/".._path)
end

local function loadcore(_path)
	dofile("game/Core/".._path)
end

local function loaddebug(_path)
	dofile("game/Debug/".._path)
end

-- NOTE: Root loads before any folder.

-- [ GAME ] --

-- "game/" root
loadgame "global.lua"
loadgame "cvars.lua"
loadgame "commands.lua"
loadgame "sounds.lua"

-- gametypes
loadgame "Gametypes/init.lua"

-- [ CORE ] --

-- map load
loadcore "mapload.lua"

-- clocks (game state system)
loadcore "clocks.lua"

-- win handler
loadcore "winhandler.lua"

-- libraries
loadcore "Libraries/init.lua"

-- effects
loadcore "Effects/init.lua"

-- objects
loadcore "Objects/init.lua"

-- enemies
loadcore "Enemies/init.lua"

-- colors
loadcore "Colors/init.lua"

-- player scripts
loadcore "Player/init.lua"

-- items
loadcore "Items/init.lua"

-- title screen
loadcore "Title Screen/init.lua"

-- level scripts
loadcore "Level Scripts/maptimers.lua"
loadcore "Level Scripts/loadscripts.lua"

-- debug
loaddebug "commands.lua"