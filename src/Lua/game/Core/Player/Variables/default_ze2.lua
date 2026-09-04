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

	selected_character = nil,

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

	teamchat_enabled = false,
	
	vote = {
		selection = 1,
		
		lasthit = nil, -- the leveltime frame where they last hit a map
		
		-- The cmd from the previous frame
		lastside = 0,
		lastforward = 0,
		lastbuttons = 0,
	},

	spectator_cycle = 0,
	
	purchased = {},
}