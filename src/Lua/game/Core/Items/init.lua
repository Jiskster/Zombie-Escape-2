local PATH = "game/Core/Items"

local function dopath(_path)
	dofile(PATH .. "/" .. _path)
end

local function SurvivorItem(_path)
	dopath("Survivor/" .. _path)
end
local function ZombieItem(_path)
	dopath("Zombie/" .. _path)
end

-- Rings
SurvivorItem "red_ring.lua"
SurvivorItem "auto_ring.lua"
SurvivorItem "bounce_ring.lua"
SurvivorItem "scatter_ring.lua"
SurvivorItem "grenade_ring.lua"
SurvivorItem "explosion_ring.lua"
SurvivorItem "rail_ring.lua"
SurvivorItem "flame_ring.lua"
SurvivorItem "accel_ring.lua"

-- Misc
SurvivorItem "blue_spring.lua"
SurvivorItem "wood_fence.lua"
SurvivorItem "apple.lua"
SurvivorItem "energy_drink.lua"
SurvivorItem "amys_heart.lua"
SurvivorItem "auto_turret.lua"

ZombieItem "insta_burst.lua"
ZombieItem "fist.lua"