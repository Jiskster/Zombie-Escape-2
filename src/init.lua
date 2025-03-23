dofile "init/gametype.lua"

dofile "libraries/fixedfromstring.lua"
dofile "libraries/json.lua"
dofile "libraries/mobjlib.lua"
dofile "libraries/customhudlib.lua"
dofile "libraries/countingplayers.lua"
dofile "libraries/getcharacterlist.lua"
dofile "libraries/itemlib.lua"
dofile "libraries/mtimeconv.lua"
dofile "libraries/sglib.lua" -- https://github.com/GenericHeroGuy/ringracers-scripts
dofile "libraries/basexx.lua" -- https://github.com/aiq/basexx

dofile "main/shop.lua"

// ITEMS
dofile "items/item_red_ring.lua" -- [1]
dofile "items/item_auto_ring.lua" -- [2]
dofile "items/item_apple.lua" -- [3]
dofile "items/item_milk.lua" -- [4]
dofile "items/item_insta_burst.lua" -- [5]
dofile "items/item_ws_mirror.lua" -- [6]
dofile "items/item_wood_fence.lua" -- [7]
dofile "items/item_explosion_ring.lua" -- [8]
dofile "items/item_blue_spring.lua" -- [9]
dofile "items/item_scatter_ring.lua" -- [10]
dofile "items/item_rail_ring.lua" -- [11]
dofile "items/item_gfz_sphere.lua" -- [12]
dofile "items/item_infinity_ring.lua" -- [13]
dofile "items/item_grenade.lua" -- [14]
dofile "items/item_landmine.lua" -- [15]
dofile "items/item_energy_drink.lua" -- [16]
dofile "items/item_flame_ring.lua" -- [17]

// ITEMS END

dofile "enemies/vanilla.lua"
dofile "enemies/doom.lua"

dofile "main/baseplayer.lua"

dofile "main/zombie/zombie_colors.lua"

dofile "main/pregame_logic.lua"

dofile "main/crouch.lua"

dofile "main/characterconfigs.lua"

dofile "main/console.lua"
dofile "main/health_and_combat.lua" -- main stuff 

dofile "main/intermission.lua"
dofile "main/capitalism.lua"
dofile "main/exiting.lua"
dofile "main/mapinfo_animation.lua"
dofile "main/timers.lua"
dofile "main/emotes.lua"
--dofile "main/savedata.lua"
dofile "main/maptimers.lua"
dofile "main/checkpointsystem.lua"
dofile "main/shields.lua"
dofile "main/ladder.lua"
dofile "main/teamchat.lua"

dofile "objects/megahp.lua"
dofile "objects/teleporter_gfx.lua"
dofile "objects/corona.lua"

dofile "hud/setup"

dofile "hooks/gamelogic.lua"

-- [ Level Scripts ] -- 
dofile "levelscripts/loadscripts.lua"

dofile "main/netvars.lua"

dofile "main/debug/cvmake.lua"
dofile "main/debug/commands.lua"

dofile "title_screen/scenery.lua"
dofile "title_screen/hud.lua"