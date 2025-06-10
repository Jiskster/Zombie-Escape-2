local thinkers = {
	[MT_REDRING] = function(pmo, mo)
		local ghost = P_SpawnGhostMobj(mo)
		ghost.tics = 1
		P_SetOrigin(ghost, ghost.x, ghost.y, ghost.z) -- fix interpolation being freaky
	end,
	[MT_CORK] = function(pmo, mo)
		local ghost = P_SpawnGhostMobj(mo)
		ghost.destscale = ghost.scale*4
	end,
}

local precision_thinkers = {
	[MT_REDRING] = function(pmo, mo)
		local ghost = P_SpawnGhostMobj(mo)
		ghost.tics = 1
		ghost.frame = $|FF_ADD
		P_SetOrigin(ghost, ghost.x, ghost.y, ghost.z) -- fix interpolation being freaky
	end,
} 

ZE2:CreateItem("red_ring",  {
	displayname = "Red Ring",
	object = MT_REDRING,
	icon = "RINGIND",
	sound = sfx_wpfire,
	firerate = 4,
	color = SKINCOLOR_RED,
	knockback = 3*FRACUNIT,
	damage = 25,
	velocity_precision = 8,
	velocity_multiplier = 8*FRACUNIT,
	autouse = false,
	max_ammo = 25,
	ammo = 25,
	reload_time = 7*TICRATE/4,
	skin_overwrite = {
		["tails"] = {
			autouse = true
		},
		["fang"] = {
			displayname = "Cork",
			object = MT_CORK,
			icon = "CORKIND",
			firerate = 5,
			color = SKINCOLOR_BROWN,
			knockback = 20*FRACUNIT,
			velocity_multiplier = 2*FRACUNIT,
			damage = 100,
			velocity_precision = 1,
			
			max_ammo = 10,
			ammo = 10,
			reload_time = 1*TICRATE + TICRATE/2,
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
		if thinkers[mo.type] then
			thinkers[mo.type](pmo, mo)
		end
	end,
	precision_thinker = function(pmo, mo)
		if precision_thinkers[mo.type] then
			precision_thinkers[mo.type](pmo, mo)
		end
	end,
})