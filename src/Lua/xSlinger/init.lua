-- VERSIONLESS BUILD

dofile "xSlinger/freeslots"

rawset(_G, "xSlinger", {})

xSlinger.Knockback = {}

dofile "xSlinger/knockback" -- Knockback system by Luigi Budd.

dofile "xSlinger/libs/w2s" -- credits in file

xSlinger.settings = {}

xSlinger.BulletList = {}

xSlinger.init = loadfile("xSlinger/classes/xslinger_t.lua")

xSlinger.visible_huds = {
	health = true;
}

xSlinger.skin_properties = {}

function xSlinger.initPlayerSpawn(player)
	local xS = player.xSlinger
	xS.team = 1
	
	xS:inv_add("main", 5)
end

function xSlinger.initPlayerHealth(player)
	player.mo.health = 100
	player.mo.maxhealth = 100
end

function xSlinger.getLambdaObject(self)
	if self.player and self.player.valid then
		return self.player
	elseif self.mo and self.mo.valid then
		return self.mo
	end
end

xSlinger.METATABLES = {}
xSlinger.METATABLES.add = function(name, metatable)
	name = $:upper()
	
	if xSlinger.METATABLES[name] then
		return end;
		
	xSlinger.METATABLES[name] = metatable
	registerMetatable(metatable)
end

dofile "xSlinger/metatables/mobj_t"
dofile "xSlinger/metatables/player_t"
dofile "xSlinger/metatables/xSlinger_t"
dofile "xSlinger/metatables/iteminfo_t"

xSlinger.default_item_background = "XSG_BACKGROUND"
xSlinger.default_item_background_color = SKINCOLOR_SILVER

xSlinger.registered_items = {}
xSlinger.registered_items_ordered = {}

-- Fallback
xSlinger.registered_items[-1] = {
	id = -1;
	
	displayname = "Unknown";
	
	icon = "M_FNOPE";
	icon_autoscale = true;
	
	background = xSlinger.default_item_background;
	background_color = xSlinger.default_item_background_color;
	
	missile = MT_NULL;
	
	damage = 1;
	knockback = 0; -- fixed_t
	
	autouse = false;
	
	count = -1;
	maxcount = -1;
	
	ammo = -1;
	maxammo = -1;
	
	reload_time = 2*TICRATE;
	firerate = 0;
	firerate_left = 0;
	
	delay = 0; -- cooldown, dont use at all for setting items.
	
	flags2 = 0; -- MF2_...
	
	autopickup = false;

	sounds = {
		use = sfx_None; -- "use"/"fire" entry supports tables for randomized sounds.
		reload = {sfx_xsrel1, sfx_xsrel2}; -- [1]: Reload Start | [2] Reload Finish 
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	droppable = false;
	
	drop_on_death = true;
}

-- Empty Slot Item
xSlinger.registered_items[""] = {
	displayname = "Empty";

	id = "";
	
	background = xSlinger.default_item_background;
	background_color = xSlinger.default_item_background_color;
	
	sounds = {
		use = sfx_None;
	};
	
	drop_on_death = false;
}

-- http://lua-users.org/wiki/CopyTable
function xSlinger.deepcopy(orig)
	local deepcopy = xSlinger.deepcopy
	
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

dofile "xSlinger/register" -- item registering

dofile "xSlinger/missile" -- missile handling

dofile "xSlinger/invthink" -- inventory thinkers

dofile "xSlinger/damage"

dofile "xSlinger/effects"

dofile "xSlinger/teams"

dofile "xSlinger/gametypes"

-- HUD
dofile "xSlinger/hud/interactions"
dofile "xSlinger/hud/tags"
dofile "xSlinger/hud/inventory"
dofile "xSlinger/hud/health"

addHook("PlayerSpawn", function(player)
	xSlinger.initPlayerSpawn(player)
	
	--xS:slot_set(1, "red_ring")
end)

addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid and player.mo.health) then
		return end;
	
	if player.mo.maxhealth == nil then
		xSlinger.initPlayerHealth(player)
	end
		
	xSlinger.DoThinker(player.mo)
end)

COM_AddCommand("giveitem", function(player, item, count)
	if not item then
		return end;
		
	if not xSlinger.registered_items[item] then
		return end;
		
	local xS = player.xSlinger
	local item = xS:give_item(item, tonumber(count))
	
	if not item then
		CONS_Printf(player, "inventory full bruh")
	end
end, COM_ADMIN)

dofile "xSlinger/health"

dofile "xSlinger/shields"

dofile "xSlinger/interactions"

dofile "xSlinger/itemdrop"

-- separate into own file
mobjinfo[MT_BLUECRAWLA].npc_name = "Blue Crawla"
mobjinfo[MT_BLUECRAWLA].npc_spawnhealth = {120,230}
mobjinfo[MT_BLUECRAWLA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_BLUECRAWLA].rubydrop = {2,4}
mobjinfo[MT_BLUECRAWLA].painsound = sfx_dmpain
mobjinfo[MT_BLUECRAWLA].forcedamage = 10
mobjinfo[MT_BLUECRAWLA].forceknockback = 10*FRACUNIT
mobjinfo[MT_BLUECRAWLA].relativeknockback = true