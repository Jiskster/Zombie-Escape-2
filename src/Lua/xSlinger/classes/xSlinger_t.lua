local xs_mt = xSlinger.METATABLES.MAIN

local xSlinger_t = setmetatable({
	slot = 1;
	reload = 0;
	delay = 0;
	inventory = {};
	team = 0;
	current_inventory = "main";
	-- player = player_t;
	-- mobj = mobj_t;
}, xs_mt)

return xSlinger_t