freeslot("S_ZE2_BLUESPRING_DROP")

states[S_ZE2_BLUESPRING_DROP] = {
	sprite = SPR_SPRB,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_BLUESPRING_DROP,
}

xSlinger.registerItem("blue_spring", {
	displayname = "Blue Spring";
	
	icon = "BLUESPRINGIND";
	
	dropstate = S_ZE2_BLUESPRING_DROP;
	
	firerate = 4*TICRATE;

	count = 1;
	maxcount = 2;
	
	color = SKINCOLOR_BLUE;
	
	usefunc = function(self, mo)
		local spring = P_SpawnMobj(mo.x+FixedMul(128*FRACUNIT, cos(mo.angle)),
					             mo.y+FixedMul(128*FRACUNIT, sin(mo.angle)), 
								 mo.z, MT_BLUESPRING)
		spring.angle = mo.angle+ANGLE_90
		S_StartSound(mo, sfx_jshard)
		spring.target = mo
		
		if (spring.ceilingz - spring.floorz < (spring.height*5))
			spring.fuse = 3 -- Kills crouch parts spring softlocking
		else
			spring.fuse = 5*TICRATE
		end
	end;
})