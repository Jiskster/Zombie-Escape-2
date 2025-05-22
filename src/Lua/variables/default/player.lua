return {
	crouching = false,

	inventory_selection = 1,

	survivor_inventory_limit = 5,
	
	survivor_inventory = {
		ZE2:CopyItemFromID(ITEM_RED_RING)
	},

	weapondelay = 0,
	ghostmode = false,
	
	await_fire = false,
	
	reload = 0,
	
	fire_pressed = false,
	
	weaponprev_pressed = false,
	weaponnext_pressed = false,
	weaponkey_pressed = false,
	
	reload_pressed = false,
	
	vote_selection = 1,
	voted = false,
	vote_leftpressed = false,
	vote_rightpressed = false,
	
	shop_selection = 1,

	pregamemenu_type = 1, -- [1]: Character Select
	pregamemenu_lasttype = 1, -- [1]: Character Select
	pregamemenu_active = false,
	pregamemenu_intopmenu = false,
	pregamemenu_intopmenuanim = 0,
	pregamemenu_intopmenuanim_max = TICRATE/2,
	pregamemenu_leftpressed = false,
	pregamemenu_rightpressed = false, 
	pregamemenu_forwardpressed = false,
	pregamemenu_backwardspressed = false,
	pregamemenu_spinpressed = false,
	pregamemenu_jumppressed = false,
	
	charselect_selection = 1,
	charselect_prevselection = 1,
	charselect_selection_anim = 1,
	charselect_hold = 0,

	sprintmeter = 100*FU,
	isSprinting = false,
	sprintdelay = 0, -- x > 0 = sprintmeter wont increase

	team = 1,

	cash = 500,
	rubycap = 25000,
	rubyqueue = 0,
	rubypickupdelay = 0,

	was_spectating = false,
	was_zombie = false,

	zombie_type = "normal",
	
	damage_fade = 0, -- tic_t
	damage_fade_max = 0,
	
	checkpoint_number = 0,
	checkpoint_catchuptics = 0, 
	
	lower_hud_offset = 0,
	special_cooldown = 0,

	zombie_shop_open = false,
	zombie_shop_selection = 1,
	zombie_shop_c1_pressed = false,
	zombie_next_type = nil,
	
	nofrictiontics = 0; 
	
	isSprung = false,
	
	damage_indicator_table = {},
	/*	damage_indicator_table
		[mobj_t] = {
			draw_x = (x),
			draw_y = (y),
			draw_z = (z),
			number = 100,
			tics_left = 35,
			damagenumbers = {list of mobjs},
			real_position = {x,y,z, scale, height, radius},
		}
	*/
	
	landfatigue = false,
	landfatigue_timer = 0,
	
	teamchat_enabled = false,
}