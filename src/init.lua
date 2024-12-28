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
dofile "items/item_red_ring.lua"
dofile "items/item_auto_ring.lua"
dofile "items/item_apple.lua"
dofile "items/item_milk.lua"
dofile "items/item_insta_burst.lua"
dofile "items/item_ws_mirror.lua"
dofile "items/item_wood_fence.lua"
dofile "items/item_explosion_ring.lua"
dofile "items/item_blue_spring.lua"
dofile "items/item_scatter_ring.lua"
dofile "items/item_rail_ring.lua"
dofile "items/item_gfz_sphere.lua"
dofile "items/item_infinity_ring.lua"
dofile "items/item_grenade.lua"
dofile "items/item_landmine.lua"
dofile "items/item_energy_drink.lua"

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
dofile "main/savedata.lua"
dofile "main/maptimers.lua"
dofile "main/checkpointsystem.lua"
dofile "main/shields.lua"
dofile "main/ladder.lua"
dofile "main/teamchat.lua"

dofile "objects/megahp.lua"
dofile "objects/teleporter_gfx.lua"

dofile "hud/pregame.lua"
dofile "hud/characterselect.lua"
dofile "hud/info.lua"
dofile "hud/shop.lua"
dofile "hud/inventory.lua"
dofile "hud/damagefade.lua"
dofile "hud/mapinfo_animation.lua"
dofile "hud/tabscores.lua"
dofile "hud/toggle.lua"
dofile "hud/zombie_shop.lua"
dofile "hud/intermission.lua"
dofile "hud/damageindicator.lua"
dofile "hud/name_tags.lua"
dofile "hud/debug.lua"

dofile "hooks/gamelogic.lua"
dofile "hooks/hud.lua"

dofile "levelscripts/waterfall_objects.lua"
dofile "levelscripts/waterfall_timers.lua"
dofile "levelscripts/noxylous.lua"
dofile "levelscripts/grancolia.lua"
dofile "levelscripts/ug_marble.lua"
dofile "levelscripts/doomedcorp_sounds.lua"
dofile "levelscripts/doomedcorp_electricsparkles.lua"
dofile "levelscripts/doomedcorp_objects.lua"
dofile "levelscripts/doomedcorp_timers.lua"
dofile "levelscripts/doomedcorp_globalsounds.lua"
dofile "levelscripts/fataldesert.lua"

dofile "main/netvars.lua"

dofile "main/debug/cvmake.lua"
dofile "main/debug/commands.lua"

dofile "title_screen/scenery.lua"
dofile "title_screen/hud.lua"