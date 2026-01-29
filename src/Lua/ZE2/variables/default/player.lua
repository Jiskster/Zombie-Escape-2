return {
	crouching = false,

	survivor_inventory_limit = 5,
	
	sprintmeter = 100*FU,
	isSprinting = false,
	sprintdelay = 0, -- x > 0 = sprintmeter wont increase
	
	isJumping = false,
	isRunning = false,
	isSprung = false,
	lastJumped = false,
	
	runstart = 0,
	rundelay = 0,

	cash = 500,
	cash_limit = 25000,
	currencydelay = 0,

	injoinqueue = false,
	injoinqueue_delay = 0,
	outofgame = false,
	respawntics = 0,
	
	karma = 1,

	was_spectating = false,
	was_zombie = false,

	zombie_type = "normal",
	
	damage_fade = 0, -- tic_t
	damage_fade_max = 0,
	
	checkpoint_number = 0,
	checkpoint_catchuptics = 0, 
	
	lower_hud_offset = 0,
	special_cooldown = 0,
	
	zombie_next_type = nil,

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
	
	teamchat_enabled = false,
}