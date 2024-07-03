-- Render by Marilyn / Speccy

freeslot("MT_ZE2_GFZSPHERE", "S_ZE2_GFZSPHERE", "SPR_GFZS")

mobjinfo[MT_ZE2_GFZSPHERE] = { 
	spawnstate = S_ZE2_GFZSPHERE,
	--activesound = sfx_shgn,
	deathstate = S_SPRK1,
	xdeathstate = S_SPRK1,
	speed = 60*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

states[S_ZE2_GFZSPHERE] = {
	nextstate = S_ZE2_GFZSPHERE,
	sprite = SPR_GFZS,
	frame = FF_FULLBRIGHT|FF_ANIMATE,
	tics = -1,
	var1 = 3,
	var2 = 2,
}

local gfz_sphere = ZE2:CreateItem("GFZSPHERE",  {
	object = MT_ZE2_GFZSPHERE,
	icon = "GFZSPHEREIND",
	firerate = 40,
	--color = SKINCOLOR_RED,
	color = SKINCOLOR_BROWN,
	knockback = 125*FRACUNIT,
	damage = 90,
	price = 130,
	sound = sfx_kc5b,
	ammo = 3,
	autouse = true,
	reload_time = TICRATE*4,
})

ZE2:RegisterShopItem(gfz_sphere)