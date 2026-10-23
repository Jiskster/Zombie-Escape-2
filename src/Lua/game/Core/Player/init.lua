local PATH = "game/Core/Player"

local function dopath(_path)
	dofile(PATH .. "/" .. _path)
end

dopath("pregame.lua")

dopath("replacealpha.lua")

dopath("Intermission/intermission.lua")

dopath("HUD/init.lua")

dopath("Variables/init.lua")

dopath("Zombie VFX/init.lua")

dopath("Social/emotes.lua")
dopath("Social/teamchat.lua")

dopath("Controls/crouch.lua")
dopath("Controls/ladder.lua")
dopath("Controls/sprint.lua")
dopath("Controls/applyconfig.lua")
dopath("Controls/jumpfatigue.lua")
dopath("Controls/sourcephys.lua")
dopath("Controls/misc.lua")
dopath("Controls/alphazombie.lua")

dopath("Health/falldamage.lua")
dopath("Health/messages.lua")
dopath("Health/hurt.lua")
dopath("Health/damageindicator.lua")

dopath("Spawn/respawntimer.lua")
dopath("Spawn/initcharacter.lua")
dopath("Spawn/zombiespawn.lua")

dopath("configs.lua")
dopath("midgamejoin.lua")