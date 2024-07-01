ZE2:CreateItem("Red Ring",  {
	object = MT_REDRING,
	icon = "RINGIND",
	firerate = 10,
	color = SKINCOLOR_RED,
	knockback = 50*FRACUNIT,
	damage = 20,
	velocity_multiplier = 2*FRACUNIT,
	skin_overwrite = {
		["fang"] = {
			displayname = "Cork",
			object = MT_CORK,
			icon = "CORKIND",
			firerate = 26,
			color = SKINCOLOR_BROWN,
			knockback = 80*FRACUNIT,
			velocity_multiplier = 3*FRACUNIT,
			damage = 45,
			
			max_ammo = 10,
			ammo = 10,
			reload_time = 3*TICRATE,
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