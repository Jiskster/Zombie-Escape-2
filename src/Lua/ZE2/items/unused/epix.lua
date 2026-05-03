freeslot("sfx_epix33")
sfxinfo[sfx_epix33].caption = "Dog barks"

freeslot("S_ZE2_EPIX_DROP", "SPR_EPIXDAWG")

states[S_ZE2_EPIX_DROP] = {
	sprite = SPR_EPIXDAWG,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_EPIX_DROP,
}

xSlinger.registerItem("epix", {
	displayname = "epixgamer3333333";

	icon = "EPIXIND";

	dropstate = S_ZE2_EPIX_DROP;
	dropscale = FU/2;

	color = SKINCOLOR_TAN;

	firerate = TICRATE;

	sounds = {
		use = sfx_epix33;
	};
})