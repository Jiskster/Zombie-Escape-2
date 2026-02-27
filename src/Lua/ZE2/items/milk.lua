freeslot("sfx_gulpy")
sfxinfo[sfx_gulpy].caption = "Drinking"

freeslot("S_ZE2_MILK_DROP", "SPR_ZE2_MILK")

states[S_ZE2_MILK_DROP] = {
	sprite = SPR_ZE2_MILK, -- uhhh problematic naming???
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_MILK_DROP,
}

xSlinger.registerItem("milk", {
	displayname = "Milk";
	
	icon = "MILKIND";
	iconscale = FU/2;
	
	dropstate = S_ZE2_MILK_DROP;
	
	firerate = 20;
	
	sounds = {
		use = sfx_gulpy;
	};
	
	count = 1;
	maxcount = 10;
	
	color = SKINCOLOR_WHITE;
	
	usefunc = function(self, mo)
		if mo.player and mo.player.valid then
			local ze2 = mo.player.ze2
			ze2:ChangeStamina(40*FRACUNIT)
		end
	end;
	
	price = 250;
})