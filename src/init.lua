local dofile = dofile;

freeslot("MT_ZVISUAL") -- just put it here, is gonna be a general propuse mobj visual
mobjinfo[MT_ZVISUAL] = {doomednum = -1, spawnstate = S_INVISIBLE, speed = 0, radius = 0, height = 0, flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIPHEIGHT}

dofile "xSlinger/init" -- Load xSlinger

local path = ""
local subpath = ""

rawset(_G, "ZE2", {
	Knockback = {};
});

local function ze2file(path)
	print("ZE2/"..subpath..path)
	
	return dofile("ZE2/"..subpath..path)
end

local function set_subpath(var)
	if var ~= nil then
		subpath = var
	else
		error("missing subpath input")
	end
end

local function I_LoadLibs(sp)	
	set_subpath (sp);

	ze2file "fixedfromstring.lua"
	ze2file "json.lua"
	ze2file "mobjlib.lua"
	ze2file "customhudlib.lua"
	ze2file "countingplayers.lua"
	ze2file "mtimeconv.lua"
	
	set_subpath "";
	
	print("I_LoadLibs();")
end; 

local function I_Main(sp)
	set_subpath (sp);
	
	ze2file "zombie/zombie_colors.lua"
	
	ze2file "skincolors.lua"

	ze2file "crouch.lua"

	ze2file "characterconfigs.lua"

	ze2file "console.lua"
	ze2file "health_and_combat.lua" -- main stuff 

	ze2file "characterselect.lua"

	ze2file "capitalism.lua"
	ze2file "exiting.lua"
	ze2file "timers.lua"
	ze2file "emotes.lua"

	ze2file "maptimers.lua"
	ze2file "checkpointsystem.lua"
	
	ze2file "ladder.lua"
	ze2file "teamchat.lua"
	
	set_subpath "";
	
	print("I_Main();")
end;

local function I_LoadItems(sp)
	set_subpath (sp);
	
	ze2file "apple.lua"
	ze2file "red_ring.lua"
	ze2file "scatter_ring.lua"
	ze2file "auto_ring.lua"
	ze2file "blue_spring.lua"
	ze2file "explosion_ring.lua"
	ze2file "wood_fence.lua" 
	ze2file "rail_ring.lua" -- new and after
	ze2file "milk.lua"
	ze2file "grenade.lua"
	ze2file "insta_burst.lua"
	ze2file "flame_ring.lua"
	ze2file "gfz_sphere.lua"
	ze2file "energy_drink.lua"
	
	-- Unused always at the end.
	ze2file "unused/epix.lua"
	ze2file "unused/saxa.lua"
	
	/*
	ze2file "item_bounce_ring.lua"
	
	ze2file "item_infinity_ring.lua"
	
	ze2file "item_landmine.lua"
	
	*/
	
	set_subpath "";
	
	print("I_LoadItems();")
end

ze2file "freeslot/sounds"

ze2file "gametype.lua"

ze2file "functions/main"

I_LoadLibs("libraries/")

ze2file "variables/main"

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
		
		if (foundmobj.team == actor.team) then
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

ze2file "enemies/vanilla.lua"
ze2file "enemies/doom.lua"

I_Main("main/")

ze2file "hooks/main"

I_LoadItems("items/")

ze2file "objects/megahp.lua"
ze2file "objects/teleporter_gfx.lua"
ze2file "objects/corona.lua"

ze2file "hud/setup"

-- [ Level Scripts ] -- 
ze2file "levelscripts/loadscripts.lua"

ze2file "main/debug/commands.lua"

ze2file "title_screen/scenery.lua"
ze2file "title_screen/hud.lua"