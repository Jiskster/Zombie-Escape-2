freeslot("S_ZE2_APPLE_DROP", "SPR_ZE2_APPLE")

states[S_ZE2_APPLE_DROP] = {
	sprite = SPR_ZE2_APPLE,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_APPLE_DROP,
}

xSlinger.registerItem("apple", {
	displayname = "Apple";

	icon = "APPLEIND";

	dropstate = S_ZE2_APPLE_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	color = SKINCOLOR_RED;

	firerate = 50;

	sounds = {
		use = sfx_eatapl;
	};

	count = 1;
	maxcount = 16;

	usefunc = function(self, mobj)
		mobj:ChangeHealth(20)
	end;

	hold_object = {
		state = S_ZE2_APPLE_DROP;
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
		ignorecolor = true;
	};

	hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
})