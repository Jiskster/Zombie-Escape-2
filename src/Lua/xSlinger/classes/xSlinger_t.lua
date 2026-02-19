local xs_mt = xSlinger.METATABLES.MAIN

local xSlinger_t = setmetatable({
	slot = 1;
	reload = 0;
	delay = 0;
	inventory = {};
	team = 0;
	selected_interaction = nil; -- mobj_t
	selected_interaction_timer = 0; -- tics
	interaction_hold = 0; -- holding interaction button
	interaction_delay = 0; -- time until you can interact again
	current_inventory = "main";
	viewmobj = nil;
	hold_animation = 0;
	hold_x = 0;
	hold_y = 0;
	hold_z = 0;
	-- player = player_t;
	-- mobj = mobj_t;
}, xs_mt)

return xSlinger_t