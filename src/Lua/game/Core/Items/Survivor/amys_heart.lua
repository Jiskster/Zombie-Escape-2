freeslot("MT_ZE2_AMYS_HEART")
freeslot("S_ZE2_AMYS_HEART")

mobjinfo[MT_ZE2_AMYS_HEART] = {
	spawnstate = S_ZE2_AMYS_HEART,
	spawnhealth = 600,
	painsound = sfx_dmpain,
	deathsound = sfx_ncchip,
	speed = 0,
	radius = 32*FU,
	height = 80*FU,
	flags = MF_SPECIAL|MF_SHOOTABLE,
}

states[S_ZE2_AMYS_HEART] = {
	sprite = SPR_LHRT,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_AMYS_HEART,
}

mobjinfo[MT_ZE2_AMYS_HEART].npc_name = "Amy's Heart"
mobjinfo[MT_ZE2_AMYS_HEART].antiknockback = true

xSlinger.registerItem("amys_heart", {
	displayname = "Amy's Heart";
	
	icon = "AMYSHEARTIND";
	
	background_color = SKINCOLOR_FANCY;
	
	firerate = 50*TICRATE;
	
	sounds = {
		use = sfx_cdpcm6;
	};
	
	color = SKINCOLOR_ROSY;
	
	usefunc = function(self, mo)
		local x = mo.x + cos(mo.angle)*64
		local y = mo.y + sin(mo.angle)*64
		local z = mo.z
		
		local heart = P_SpawnMobj(x, y, z, MT_ZE2_AMYS_HEART)
		heart.target = mo
		heart.team = mo.team
		heart.heart_cooldown = TICRATE
	end;
	
	droppable = false;
})

addHook("TouchSpecial", function(special, toucher)
	if (special.heart_cooldown)
	or (special.target == toucher)
	or (special.team ~= toucher.team) 
	or xSlinger.MobjHasShield(special) then
		return true
	end
	
	for i=1,30 do
		local particle = P_SpawnMobjFromMobj(special, 0, 0, special.height/2, MT_PARTICLE)
		particle.state = S_ZE2_AMYS_HEART
		particle.alpha = FU/2
		particle.blendmode = AST_SUBTRACT
		particle.fuse = 14
		particle.scalespeed = FRACUNIT/10
		particle.momx = P_RandomRange(-6,6)*FU
		particle.momy = P_RandomRange(-10,10)*FU
		particle.momz = P_RandomRange(-6,6)*FU

		particle.destscale = FU/24
	end
	
	xSlinger.GiveShieldToMobj(toucher, 4)
end, MT_ZE2_AMYS_HEART)

addHook("MobjThinker", function(mobj)
	mobj.spriteyoffset = 32*FU
	
	-- wobble wobble
	mobj.spritexscale = FU + cos(FixedAngle(leveltime*ANG10))/12
	mobj.spriteyscale = FU + sin(FixedAngle(leveltime*ANG10))/12
	
	if mobj.heart_cooldown then
		mobj.heart_cooldown = $ - 1
	end
	
	if not (leveltime % 2) then
		local particle = P_SpawnMobjFromMobj(mobj, 0, 0, mobj.height/2, MT_PARTICLE)
		particle.state = S_ZE2_AMYS_HEART
		particle.alpha = FU/8
		particle.blendmode = AST_ADD
		particle.fuse = 25
		particle.scalespeed = FRACUNIT/24
		particle.momx = P_RandomRange(-2,2)*FU
		particle.momy = P_RandomRange(-4,4)*FU
		particle.momz = P_RandomRange(-2,2)*FU

		particle.destscale = FU/16
	end
	
	for player in players.iterate do
		if not (player.mo and player.mo.valid and player.mo.health) then
			continue
		end
		
		if (player.spectator) then
			continue
		end

		if not ZE2.ZCollide(mobj, player.mo) then
			continue
		end
		
		if R_PointToDist2(mobj.x, mobj.y, player.mo.x, player.mo.y) > 320*FU then
			continue
		end
		
		if not P_CheckSight(mobj, player.mo) then
			continue
		end
		
		if (player.mo.team == 2) then
			player.mo:give_effect("amys_love", {
				normalspeed_multiplier = (FU*3)/5,
				damage_multiplier = (FU*3)/4,
			}, 7, true)
		end
	end
end, MT_ZE2_AMYS_HEART)

xSlinger.registerEffect("amys_love", {
	max_duration = 2 * TICRATE,
	tick = function(effect, mobj, time_left)
		if mobj and mobj.valid then
			if not (leveltime % 2) then
				local particle = P_SpawnMobjFromMobj(mobj, 0, 0, mobj.height/2, MT_PARTICLE)
				particle.state = S_ZE2_AMYS_HEART
				particle.alpha = FU/4
				particle.blendmode = AST_ADD
				particle.fuse = 18
				particle.scalespeed = FRACUNIT/P_RandomRange(18,26)
				particle.momx = P_RandomRange(-1,1)*FU
				particle.momy = P_RandomRange(-4,4)*FU
				particle.momz = P_RandomRange(-1,1)*FU

				particle.destscale = FU/16
			end
			
			local ghost = P_SpawnGhostMobj(mobj)
			ghost.fuse = 3
			ghost.color = SKINCOLOR_ROSY
			ghost.colorized = true
		end
	end;
})