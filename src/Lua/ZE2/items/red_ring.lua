freeslot("S_XS_REDRING_DROP")

states[S_XS_REDRING_DROP] = {
	sprite = SPR_RRNG,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 6,
	var2 = 2,
	nextstate = S_XS_REDRING_DROP,
}

xSlinger.registerItem("red_ring", {
	displayname = "Red Ring";
	
	icon = "XSG_RING";
	
	missile = MT_REDRING;
	
	dropstate = S_XS_REDRING_DROP;
	
	sounds = {
		use = sfx_wpfire;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	color = SKINCOLOR_RED;
	
	damage = 25;
	
	velocity_precision = 8;
	velocity_multiplier = 8*FRACUNIT;
	
	knockback = 13*FRACUNIT; -- fixed_t
	knockback_time = TICRATE;
	
	autouse = false;

	ammo = 16;
	
	reload_time = 2*TICRATE;
	firerate = 3;
	
	flags2 = 0; -- MF2_...
	
	missile_tick = function(self, mo, missile)
		local ghost = P_SpawnGhostMobj(missile)
		ghost.tics = 1
		P_SetOrigin(ghost, ghost.x, ghost.y, ghost.z) -- fix interpolation being freaky
	end;
	
	missile_subtick = function(self, mo, missile)
		local ghost = P_SpawnGhostMobj(missile)
		ghost.tics = 1
		ghost.frame = $|FF_ADD
		P_SetOrigin(ghost, ghost.x, ghost.y, ghost.z) -- fix interpolation being freaky
	end;
	
	skin_override = {
		["amy"] = {
			reload_time = 1*TICRATE;
		};
		["fang"] = {
			knockback = 16*FRACUNIT;
			damage = 35;
		};
	};
})