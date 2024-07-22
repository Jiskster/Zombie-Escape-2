-- Ported From RSNEO

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

sfxinfo[sfx_shgn].caption = "Shotgun"

-- totally not from ringslinger neo
mobjinfo[MT_ZE2_THROWNSCATTER] = { 
	spawnstate = S_ZE2_THROWNSCATTER1,
	--activesound = sfx_shgn,
	deathstate = S_SPRK1,
	xdeathstate = S_SPRK1,
	speed = 60*FRACUNIT,
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

local scatter_ring = ZE2:CreateItem("Scatter Ring",  {
	icon = "SCATIND",
	firerate = TICRATE,
	sound = sfx_shgn,
	knockback = 25*FRACUNIT,
	damage = 25,
	fuse = TICRATE/2,
	color = SKINCOLOR_PURPLE,
	price = 150,
	ammo = 8,
	reload_time = 5*TICRATE,
	velocity_multiplier = 2*FRACUNIT,
	ontrigger = function(player, iteminfo)
		local mt = MT_ZE2_THROWNSCATTER
		local mo = player.mo
		local spread = 5
		--S_StartSound(mo, sfx_shgn)
		for i = -1, 1
			local shot = ZE2.SpawnMissile({
				source = mo, 
				mobj_type = mt,
				angle = mo.angle + i * ANG1*spread,
				allow_aim = true,
				iteminfo = iteminfo,
			})
			
			if shot and shot.valid
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		for i = -1, 1, 2
			local prevaim = player.aiming
			player.aiming = $ + i * ANG1*spread
			local shot = ZE2.SpawnMissile({
				source = mo, 
				mobj_type = mt,
				angle = mo.angle,
				allow_aim = true,
				iteminfo = iteminfo,
			})
			player.aiming = prevaim
			if shot and shot.valid
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		if not P_IsObjectOnGround(mo)
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(mo) * aim > 0
				aim = ($ * 2)>>3
			end
			mo.momz = $ + FixedMul(mo.scale, aim)
			P_Thrust(mo, mo.angle, -FRACUNIT*9)
		end
	end
})

addHook("MobjFuse", function(mobj)
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
end, MT_ZE2_THROWNSCATTER)

ZE2:RegisterShop_ItemID(scatter_ring)