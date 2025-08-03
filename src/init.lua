rawset(_G, "ZE2", {});

dofile "gametype.lua"

dofile "freeslot/sounds"

dofile "functions/main"

dofile "main/skincolors.lua"

dofile "libraries/fixedfromstring.lua"
dofile "libraries/json.lua"
dofile "libraries/mobjlib.lua"
dofile "libraries/customhudlib.lua"
dofile "libraries/countingplayers.lua"
dofile "libraries/itemlib.lua"
dofile "libraries/mtimeconv.lua"
dofile "libraries/sglib.lua" -- https://github.com/GenericHeroGuy/ringracers-scripts

dofile "main/shop.lua"

// ITEMS
dofile "items/item_red_ring.lua"
dofile "items/item_auto_ring.lua"
dofile "items/item_apple.lua"
dofile "items/item_milk.lua"
dofile "items/item_wood_fence.lua" 
dofile "items/item_insta_burst.lua"
dofile "items/item_ws_mirror.lua"
dofile "items/item_explosion_ring.lua"
dofile "items/item_blue_spring.lua"
dofile "items/item_scatter_ring.lua"
dofile "items/item_bounce_ring.lua"
dofile "items/item_rail_ring.lua"
dofile "items/item_gfz_sphere.lua"
dofile "items/item_infinity_ring.lua"
dofile "items/item_grenade.lua" 
dofile "items/item_landmine.lua"
dofile "items/item_energy_drink.lua"
dofile "items/item_flame_ring.lua"

dofile "variables/main"

-- Optimized version of actions.
-- TODO: Remake items that use this and remove this action override.
function A_RingExplode2(actor, var1, var2)
    local vfx = P_SpawnMobj(actor.x, actor.y, actor.z, MT_THOK)
    vfx._override_tnt_explode = true
    vfx.state = S_TNTBARREL_EXPL1
    vfx.fuse = TICRATE
    
    actor.state = S_INVISIBLE
    
    S_StartSound(actor, sfx_prloop)
    
	P_StartQuake(64*FU, 10, {x = vfx.x, y = vfx.y, z = vfx.z})
	
    local real_range = 256*FU
    local bm_range = real_range*4
    searchBlockmap("objects", function(refmobj, foundmobj)
        local dist = P_AproxDistance(P_AproxDistance(foundmobj.x - actor.x, foundmobj.y - actor.y), foundmobj.z - actor.z) 
        if dist > FixedMul(real_range, actor.scale) then
            return
        end
        
        if (foundmobj.flags & MF_SHOOTABLE) then
            actor.flags2 = $ | MF2_DEBRIS
            P_DamageMobj(foundmobj, actor, actor.target, 1, 0)
        end
    end, actor, actor.x-bm_range, actor.x+bm_range, actor.y-bm_range, actor.y+bm_range)
end

function A_TNTExplode(actor, var1, var2)
    if not actor._override_tnt_explode then
        super(actor, var1, var2)
    end
end

states[S_RINGEXPLODE] = {SPR_NULL, A, 1, A_RingExplode2, 0, 0, S_XPLD1, 0}

// ITEMS END

dofile "enemies/vanilla.lua"
dofile "enemies/doom.lua"

dofile "main/zombie/zombie_colors.lua"

dofile "main/pregame_logic.lua"

dofile "main/crouch.lua"

dofile "main/characterconfigs.lua"

dofile "main/console.lua"
dofile "main/health_and_combat.lua" -- main stuff 

dofile "main/capitalism.lua"
dofile "main/exiting.lua"
dofile "main/mapinfo_animation.lua"
dofile "main/timers.lua"
dofile "main/emotes.lua"

dofile "main/maptimers.lua"
dofile "main/checkpointsystem.lua"
dofile "main/shields.lua"
dofile "main/ladder.lua"
dofile "main/teamchat.lua"

dofile "hooks/main"

dofile "objects/megahp.lua"
dofile "objects/teleporter_gfx.lua"
dofile "objects/corona.lua"

dofile "hud/setup"

-- [ Level Scripts ] -- 
dofile "levelscripts/loadscripts.lua"

dofile "main/netvars.lua"

dofile "main/debug/cvmake.lua"
dofile "main/debug/commands.lua"

dofile "title_screen/scenery.lua"
dofile "title_screen/hud.lua"