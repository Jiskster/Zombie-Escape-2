freeslot("sfx_gulpy")

xSlinger.registerItem("milk", {
	displayname = "Milk";
	
	icon = "MILKIND";
	iconscale = FU/2;
	
	firerate = 20;
	
	sounds = {
		use = sfx_gulpy;
	};
	
	count = 5;
	maxcount = 25;
	
	color = SKINCOLOR_WHITE;
	
	usefunc = function(self, mo)
		if mo.player and mo.player.valid then
			local ze2 = mo.player.ze2
			ze2:ChangeStamina(40*FRACUNIT)
		end
	end;
	
	price = 250;
})