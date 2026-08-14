freeslot("sfx_dsclwh", "sfx_dsclwm")
freeslot("S_ZE2_FISTVFX")

sfxinfo[sfx_dsclwh].caption = "Swosh"
sfxinfo[sfx_dsclwm].caption = "Punch"

states[S_ZE2_FISTVFX] = {
	sprite = SPR_BARX,
	frame = FF_TRANS90|FF_FULLBRIGHT,
	tics = 5,
	action = function(actor)
		actor.destscale = actor.scale*6
		actor.scalespeed = $ * 2
		actor.color = SKINCOLOR_RED
		actor.colorized = true
		actor.blendmode = AST_ADD
	end
}

local missile_fist = 
xSlinger.registerMissile("FIST", {
	speed = 35*FRACUNIT,
	displayname = "Fist",
	state = S_INVISIBLE,
	deathstate = S_ZE2_FISTVFX,
	deathsound = sfx_dsclwm,
	radius = 32*FRACUNIT,
	height = 32*FRACUNIT,
})

xSlinger.registerItem("fist", {
	displayname = "Fist";
	
	icon = "FISTIND";
	
	missile = "FIST";
	
	delay = 18;
	
	sounds = {
		use = sfx_dsclwh;
	};
	
	color = SKINCOLOR_WHITE;
	
	damage = 16;
	
	fuse = 1;
	
	velocity_precision = 2;
	
	knockback = 15*FRACUNIT;
	knockback_time = 3;
	
	droppable = false;
})