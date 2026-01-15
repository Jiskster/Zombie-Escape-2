freeslot("sfx_edprdn") -- no, not edp445
freeslot("sfx_rblxdr")

xSlinger.registerEffect("energy_drink", {
	tick = function(effect, mobj, time_left)
		local player = mobj.player
		
		if player and player.valid then
			player.ze2.sprintmeter = 100*FRACUNIT
		end

		local ghost = P_SpawnGhostMobj(mobj)
		ghost.colorized = true
		ghost.color = SKINCOLOR_MASTER
	end;
	endfunc = function(effect, mobj)
		S_StartSound(mobj, sfx_edprdn)
	end
})

xSlinger.registerItem("energy_drink", {
	displayname = "Energy Drink";

	icon = "ENERGYDRINKIND";

	color = SKINCOLOR_MASTER;

	firerate = TICRATE*30;

	sounds = {
		use = sfx_rblxdr;
	};

	count = 3;
	maxcount = 15;

	usefunc = function(self, mobj)
		mobj:give_effect("energy_drink", {
			normalspeed_multiplier = 10*FRACUNIT/7,
			damage_multiplier = 2*FRACUNIT,
			knockback_multiplier = 5*FRACUNIT,
		}, 6*TICRATE, true)
	end;
})