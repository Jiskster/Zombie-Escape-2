freeslot("sfx_poyox1", "sfx_poyox2", "sfx_poyox3")
freeslot("S_ZE2_SAXA_DROP", "SPR_SAXABRUH")

states[S_ZE2_SAXA_DROP] = {
	sprite = SPR_SAXABRUH,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_SAXA_DROP,
}

xSlinger.registerItem("saxa", {
	displayname = "Saxashitter";
	
	icon = "SAXAIND";
	
	dropstate = S_ZE2_SAXA_DROP;
	dropscale = FU/8;
	
	color = SKINCOLOR_JET;
	
	firerate = TICRATE;
	
	sounds = {
		use = {sfx_poyox1, sfx_poyox2, sfx_poyox3};
	};
})