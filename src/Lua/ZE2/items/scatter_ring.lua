-- RS NEO port.

freeslot(
"MT_ZE2_THROWNSCATTER",
"S_ZE2_THROWNSCATTER1",
"S_ZE2_THROWNSCATTER2",
"S_ZE2_THROWNSCATTER3",
"S_ZE2_THROWNSCATTER4",
"S_ZE2_THROWNSCATTER5",
"S_ZE2_THROWNSCATTER6",
"S_ZE2_THROWNSCATTER7"
)

freeslot("sfx_shgn")

sfxinfo[sfx_shgn].caption = "Shotgun fires"

-- totally not from ringslinger neo
mobjinfo[MT_ZE2_THROWNSCATTER] = { 
	spawnstate = S_ZE2_THROWNSCATTER1,
	--activesound = sfx_shgn,
	deathstate = S_SPRK1,
	xdeathstate = S_SPRK1,
	speed = 72*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_ZE2_THROWNSCATTER1] = {
	nextstate = S_ZE2_THROWNSCATTER2,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER2] = {
	nextstate = S_ZE2_THROWNSCATTER3,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER3] = {
	nextstate = S_ZE2_THROWNSCATTER4,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER4] = {
	nextstate = S_ZE2_THROWNSCATTER5,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER5] = {
	nextstate = S_ZE2_THROWNSCATTER6,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER6] = {
	nextstate = S_ZE2_THROWNSCATTER7,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}
states[S_ZE2_THROWNSCATTER7] = {
	nextstate = S_ZE2_THROWNSCATTER1,
	sprite = SPR_TSCR,
	frame = FF_FULLBRIGHT,
	tics = 1,
}

freeslot("S_XS_SCATTERRING_DROP")

states[S_XS_SCATTERRING_DROP] = {
	sprite = SPR_RNGS,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_SCATTERRING_DROP,
}

addHook("MobjFuse", function(mobj)
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
end, MT_ZE2_THROWNSCATTER)

xSlinger.registerItem("scatter_ring", {
	displayname = "Scatter Ring";
	
	icon = "XSG_SCAT";
	
	dropstate = S_XS_SCATTERRING_DROP;
	
	color = SKINCOLOR_PURPLE;
	
	damage = 27;
	
	velocity_multiplier = 2*FRACUNIT;
	
	spread = 4;
	
	knockback = 21*FRACUNIT;
	knockback_tics = 33;
	
	fuse = TICRATE/4;
	
	ammo = 4;
	reload_time = 4*TICRATE;
	
	autouse = false;

	firerate = TICRATE;
	
	flags2 = 0; -- MF2_...
	
	sounds = {
		use = sfx_shgn;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	usefunc = function(self, mo)
		local mt = MT_ZE2_THROWNSCATTER
		local spread = self.spread
		local player = mo.player

		-- Horizontal
		for i = -1, 1 do
			local shot = xSlinger.SpawnMissile({
				source = mo, 
				type = mt,
				angle = mo.angle + i * ANG1*spread,
				allow_aim = true,
				iteminfo = self,
			})
			
			if shot and shot.valid
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		
		-- Vertical
		for i = -1, 1, 2 do
			local prevaim = player.aiming 
			
			player.aiming = $ + i * ANG1*spread
			local shot = xSlinger.SpawnMissile({
				source = mo, 
				type = mt,
				angle = mo.angle,
				allow_aim = true,
				iteminfo = self,
			})
			player.aiming = prevaim
			if shot and shot.valid
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		
		do -- Player push back
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(mo) * aim > 0 then
				aim = ($ * 8)
			end
			mo.momz = $ + FixedMul(mo.scale, aim)
			P_Thrust(mo, mo.angle, -FRACUNIT*9)
			
			if player and player.valid then
				P_MovePlayer(player)
			end
		end
	end
})