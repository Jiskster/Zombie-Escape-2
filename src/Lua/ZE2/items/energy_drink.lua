freeslot("sfx_edprdn") -- no, not edp445
freeslot("sfx_rblxdr")
sfxinfo[sfx_edprdn].caption = "Effect out"
sfxinfo[sfx_rblxdr].caption = "Drinking"

freeslot("S_ZE2_ENERGYDRINK_DROP", "SPR_ZE2_ENERGYDRINK")

states[S_ZE2_ENERGYDRINK_DROP] = {
	sprite = SPR_ZE2_ENERGYDRINK,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_ENERGYDRINK_DROP,
}

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

	dropstate = S_ZE2_ENERGYDRINK_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	firerate = TICRATE*30;

	sounds = {
		use = sfx_rblxdr;
	};

	count = 1;
	maxcount = 4;

	usefunc = function(self, mobj)
		mobj:give_effect("energy_drink", {
			normalspeed_multiplier = 10*FRACUNIT/7,
			damage_multiplier = 2*FRACUNIT,
			knockback_multiplier = 5*FRACUNIT,
		}, 6*TICRATE, true)
	end;

	hold_object = {
		state = S_ZE2_ENERGYDRINK_DROP;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU;
			y = FU/2;
			z = 0;
		};
		pos_anim = {
			x = -FU;
			y = (FU*3)/2;
			z = -FU/3;
		};
	};

	hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
})