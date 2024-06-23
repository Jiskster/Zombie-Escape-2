ZE2:CreateItem("Red Ring",  {
	object = MT_REDRING,
	icon = "RINGIND",
	firerate = 8,
	color = SKINCOLOR_RED,
	knockback = 25*FRACUNIT,
	damage = 15,
	skin_overwrite = {
		["fang"] = {
			displayname = "Cork",
			object = MT_CORK,
			icon = "CORKIND",
			firerate = 26,
			color = SKINCOLOR_BROWN,
			knockback = 55*FRACUNIT,
			velocity_multiplier = 2*FRACUNIT,
			damage = 45,
			
			-- No Overwrite Support Yet
			--ammo = 10,
			--reload_time = 1*TICRATE,
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
})