local PATH = "game/Core/Player"

local function dopath(_path)
	dofile(PATH .. "/" .. _path)
end

dopath("shop.lua")

dopath("pregame.lua")

dopath("quit.lua")

dopath("Intermission/intermission.lua")

dopath("HUD/init.lua")

dopath("Variables/init.lua")

dopath("Zombie VFX/init.lua")

dopath("Social/emotes.lua")
dopath("Social/teamchat.lua")

dopath("Movement/crouch.lua")
dopath("Movement/ladder.lua")
dopath("Movement/sprint.lua")
dopath("Movement/applyconfig.lua")
dopath("Movement/jumpfatigue.lua")
dopath("Movement/sourcephys.lua")
dopath("Movement/misc.lua")

dopath("Health/hurt.lua")
dopath("Health/damageindicator.lua")

dopath("Spawn/respawntimer.lua")
dopath("Spawn/initcharacter.lua")
dopath("Spawn/zombiespawn.lua")

dopath("Abilities/alphazombie.lua")

dopath("configs.lua")
dopath("midgamejoin.lua")