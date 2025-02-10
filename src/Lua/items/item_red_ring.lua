ZE2:CreateItem("Red Ring",  {
	object = MT_REDRING,
	icon = "RINGIND",
	sound = sfx_wpfire,
	firerate = 4,
	color = SKINCOLOR_RED,
	knockback = 10*FRACUNIT,
	damage = 45,
	velocity_multiplier = 3*FRACUNIT + FRACUNIT/2,
	max_ammo = 35,
	ammo = 35,
	reload_time = 3*TICRATE/2,
	skin_overwrite = {
		["fang"] = {
			displayname = "Cork",
			object = MT_CORK,
			icon = "CORKIND",
			firerate = 5,
			color = SKINCOLOR_BROWN,
			knockback = 20*FRACUNIT,
			velocity_multiplier = 2*FRACUNIT,
			damage = 100,
			
			max_ammo = 10,
			ammo = 10,
			reload_time = 1*TICRATE,
		}
	},
	onspawn = function(pmo, mo)
		if mo.type == MT_CORK then
			mo.flags = $ & ~MF_NOGRAVITY
			
			pmo.momx = $ / 2
			pmo.momy = $ / 2
			pmo.momz = $ / 2
		end
	end,
	thinker = function(pmo, mo)
		if mo.type == MT_CORK then
			local ghost = P_SpawnGhostMobj(mo)
			ghost.destscale = ghost.scale*4
		end
	end
})