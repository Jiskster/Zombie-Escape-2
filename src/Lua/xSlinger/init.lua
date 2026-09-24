-- VERSIONLESS BUILD

rawset(_G, "xSlinger", {})

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

dofile "xSlinger/freeslots"

dofile "xSlinger/hooks"

xSlinger.Knockback = {}

dofile "xSlinger/knockback" -- Knockback system by Luigi Budd.

dofile "xSlinger/libs/w2s" -- credits in file

xSlinger.settings = {}

xSlinger.visible_huds = {
	health = true;
	inventory = true;
}

xSlinger.skin_properties = {}

dofile "xSlinger/initPlayer"

function xSlinger.initPlayerSpawn(player)
	xSlinger.initPlayer(player)
	
	local xS = player.xSlinger
	
	if player.mo and player.mo.valid then
		player.mo.team = 1
	end
	
	xS.reload = 0

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

dofile "xSlinger/metatables/mobj_t"
dofile "xSlinger/metatables/xSlinger_t"
dofile "xSlinger/metatables/iteminfo_t"

xSlinger.init = loadfile("xSlinger/classes/xslinger_t.lua")

xSlinger.default_item_background = "XSG_BACKGROUND"
xSlinger.default_item_background_color = SKINCOLOR_SILVER

xSlinger.registered_items = {}
xSlinger.registered_items_ordered = {}

xSlinger.registered_missiles = {}
xSlinger.registered_missiles_ordered = {}

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

	droppable = true;
	single_drop = false;

	drop_on_death = true;
}

setmetatable(xSlinger.registered_items[-1], xSlinger.METATABLES.ITEMINFO) -- Just in case of an error.

dofile "xSlinger/register" -- item registering

-- Empty Slot Item
xSlinger.registerItem("", {
	displayname = "Empty";

	icon = false;

	id = "";

	background = xSlinger.default_item_background;
	background_color = xSlinger.default_item_background_color;

	sounds = {
		use = sfx_None;
	};

	droppable = false;

	drop_on_death = false;
})

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
dofile "xSlinger/hud/debug"

addHook("MobjSpawn", function(mobj)
	if mobj.player and mobj.player.valid then
		xSlinger.initPlayerSpawn(mobj.player)
	end
end, MT_PLAYER)

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

	/*
	if not item then
		CONS_Printf(player, "inventory full bruh: "..tostring(item))
	end
	*/
end, COM_ADMIN)

dofile "xSlinger/health"

dofile "xSlinger/shields"

dofile "xSlinger/interactions"

dofile "xSlinger/breakable"

dofile "xSlinger/itemdrop"

addHook("NetVars", function(net)
	xSlinger.visible_huds = net($)
end)