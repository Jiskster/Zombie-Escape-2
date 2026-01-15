xSlinger.registerItem("apple", {
	displayname = "Apple",
	
	icon = "APPLEIND",
	
	color = SKINCOLOR_RED,
	
	firerate = 50,
	
	sounds = {
		use = sfx_eatapl;
	},

	count = 5,
	maxcount = 100,
	
	usefunc = function(self, mobj)
		mobj:ChangeHealth(20)
	end,
})