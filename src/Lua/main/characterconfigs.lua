-- health and maxhealth are identical values, I see no sense in declaring two of them
-- (perhaps players starting with lower hp?)
ZE2.ZombieConfig = {
	["normal"] = {
		skincolor = SKINCOLOR_MOSS,
		normalspeed = 22 * FRACUNIT,
		health = 1500,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		jumpfactor = 18 * FRACUNIT / 19,
		actionspd = 9*FRACUNIT,
		killaward = 10,
		accelstart = 100,
		acceleration = 29,
		thrustfactor = 5,
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST)
		},
	},
	["alpha"] = {
		skincolor = SKINCOLOR_ALPHAZOMBIE,
		normalspeed = 20 * FRACUNIT,
		health = 3000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		jumpfactor = 19 * FRACUNIT / 19,
		actionspd = 16*FRACUNIT,
		scale = 13*FRACUNIT/10,
		killaward = 20,
		knockback_multiplier = FRACUNIT/2,
		accelstart = 130,
		acceleration = 24,
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST),
		},
	},
	["sigma"] = {
		skincolor = SKINCOLOR_SUPERSILVER4,
		normalspeed = 30 * FRACUNIT,
		health = 1200,
		charability = CA_THOK,
		charability2 = CA2_NONE,
		jumpfactor = 19 * FRACUNIT / 19,
		actionspd = 40*FRACUNIT,
		scale = 13*FRACUNIT/10,
		killaward = 50,
		knockback_multiplier = FRACUNIT/4,
		accelstart = 100,
		acceleration = 15,
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST),
		},
	},
}


ZE2.CharacterConfig = {
	["default"] = {
		normalspeed = 10 * FRACUNIT,
		health = 40,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		jumpfactor = 17 * FRACUNIT / 19,
		sprintboost = 10 * FRACUNIT,
	},
}

ZE2.MobjTouchingPolyObj = function(mobj)
	for polyobj in polyobjects.iterate do
		if polyobj:mobjTouching(mobj) or polyobj:pointInside(mobj.x, mobj.y) then
			return true
		end
	end
	return false
end

ZE2.SetCCtoplayer = function(player)
	local pmo = player.mo
	local cc = ZE2.CharacterConfig
	local cmd = player.cmd
	
	if pmo and pmo.valid and cc[pmo.skin] then
		if cc[pmo.skin].normalspeed then 
			player.normalspeed = cc[pmo.skin].normalspeed or cc["default"].normalspeed
			local sprintboost = cc[pmo.skin].sprintboost or cc["default"].sprintboost
			if (sprintboost) and (player["ze2_info"].isSprinting and player["ze2_info"].sprintmeter > 0) and (player["ze2_info"].team == 1) then
				if cmd.forwardmove > 0 or cmd.sidemove then
					player.normalspeed = max($ + sprintboost - (player["ze2_info"].landfatigue_timer)*FU, 0)
				else -- walking backwards
					player.normalspeed = FixedMul($, 3*FRACUNIT/4) 
				end
				/* UNUSED SPRINT CAM CODE
				if player.camerascale < player.mo.scale + FU/2 then
					player.camerascale = $ + FU/32
				end
				*/
			else
				/* UNUSED SPRINT CAM CODE
				if player.camerascale > player.mo.scale then
					player.camerascale = $ - FU/32
				end
				*/
			end
		end

		if (cc[pmo.skin].charability) then
			player.charability = cc[pmo.skin].charability
		else
			player.charability = cc["default"].charability 
		end
		
		if (cc[pmo.skin].charability2) then 
			player.charability2 = cc[pmo.skin].charability2
		else
			player.charability2 = cc["default"].charability2
		end
		
		if (cc[pmo.skin].jumpfactor) then 
			player.jumpfactor = cc[pmo.skin].jumpfactor
		else
			player.jumpfactor = cc["default"].jumpfactor
		end
		
		if (cc[pmo.skin].actionspd) then 
			player.actionspd = cc[pmo.skin].actionspd 
		else
			player.actionspd = skins[pmo.skin].actionspd
		end

		if (cc[pmo.skin].accelstart) then 
			player.accelstart = cc[pmo.skin].accelstart 
		else
			player.accelstart = skins[pmo.skin].accelstart
		end
		
		if (cc[pmo.skin].acceleration) then 
			player.acceleration = cc[pmo.skin].acceleration 
		else
			player.acceleration = skins[pmo.skin].acceleration
		end
		
		if (cc[pmo.skin].thrustfactor) then 
			player.thrustfactor = cc[pmo.skin].thrustfactor 
		else
			player.thrustfactor = skins[pmo.skin].thrustfactor
		end
		
		if (cc[pmo.skin].charflags) then 
			player.charflags = $|cc[pmo.skin].charflags 
		end
		
		if pmo.shield_def and pmo.shield_def.jumpfactor_multiplier then
			local multi = pmo.shield_def.jumpfactor_multiplier
			
			player.jumpfactor = FixedMul($, multi)
		end
		
		if player["ze2_info"].sprintdelay then
			player.jumpfactor = $ / 2
			player.actionspd = $ / 2
			player.normalspeed = $ / 2
		end
		
		if (cc[pmo.skin].speedcap) and not ZE2.MobjTouchingPolyObj(pmo) then 
			local sprintboost = cc[pmo.skin].sprintboost or cc["default"].sprintboost
			if (sprintboost) and (player["ze2_info"].isSprinting and player["ze2_info"].sprintmeter > 0) and (player["ze2_info"].team == 1) then
				L_SpeedCap(pmo,cc[pmo.skin].speedcap + sprintboost)
			else
				L_SpeedCap(pmo,cc[pmo.skin].speedcap)
			end
		end
	end
end

ZE2.SetCChealth = function(player)
	local pmo = player.mo
	local cc = ZE2.CharacterConfig
	if pmo and pmo.valid then
		if cc[pmo.skin] then
			if (cc[pmo.skin].health) then
				pmo.health = cc[pmo.skin].health
				pmo.maxhealth = pmo.health
			else
				pmo.health = cc["default"].health
				pmo.maxhealth = pmo.health
			end
		else
			pmo.health = cc["default"].health
			pmo.maxhealth = pmo.health
		end
	end
end

ZE2.SetZCtoplayer = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local cc = ZE2.CharacterConfig
	local ztype = player["ze2_info"].zombie_type
	
	if pmo and pmo.valid then
		if zc[ztype] then
			if (zc[ztype].normalspeed) then
				player.normalspeed = zc[ztype].normalspeed
			else
				player.normalspeed = cc["default"].normalspeed
			end
			
			player.normalspeed = $ + player["ze2_info"].zombie_speedbonus
			player.normalspeed = max($ - (player["ze2_info"].landfatigue_timer)*FU, 0) 
			
			if (zc[ztype].charability) then
				player.charability = zc[ztype].charability
			else
				player.charability = cc["default"].charability -- cc isnt a typo
			end
			
			if (zc[ztype].charability2) then 
				player.charability2 = zc[ztype].charability2
			else
				player.charability2 = cc["default"].charability2
			end
			
			if (zc[ztype].jumpfactor) then 
				player.jumpfactor = zc[ztype].jumpfactor
			else
				player.jumpfactor = cc["default"].jumpfactor
			end
			
			if (zc[ztype].actionspd) then 
				player.actionspd = zc[ztype].actionspd 
			end
			
			if (zc[ztype].accelstart) then 
				player.accelstart = zc[ztype].accelstart 
			else
				player.accelstart = 96
			end
			
			if (zc[ztype].acceleration) then 
				player.acceleration = zc[ztype].acceleration 
			else
				player.acceleration = 40
			end
			
			if (zc[ztype].thrustfactor) then 
				player.thrustfactor = zc[ztype].thrustfactor 
			else
				player.thrustfactor = 5
			end

			if (zc[ztype].charflags) then 
				player.charflags = $|zc[ztype].charflags 
			end
		else
			player["ze2_info"].zombie_type = "normal"
		end
	end
end

ZE2.SetZChealth = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local cc = ZE2.CharacterConfig
	local ztype = player["ze2_info"].zombie_type
	
	if pmo and pmo.valid then
		if zc[ztype] then
			local healthpersurvivor = zc[ztype].healthpersurvivor or 0
			
			if (zc[ztype].health) then
				pmo.health = zc[ztype].health + player["ze2_info"].zombie_healthbonus + (ZE2.SurvivorCount()*healthpersurvivor)
				
				pmo.health = max($ - player["ze2_info"].zombie_healthdeduction, 1)
				pmo.maxhealth = pmo.health
			else
				pmo.health = cc["default"].health + player["ze2_info"].zombie_healthbonus + (ZE2.SurvivorCount()*healthpersurvivor) -- cc still isnt a typo
				
				pmo.health = max($ - player["ze2_info"].zombie_healthdeduction, 1)
				pmo.maxhealth = pmo.health
			end
		else
			pmo.health = cc["default"].health + player["ze2_info"].zombie_healthbonus
			
			pmo.health = max($ - player["ze2_info"].zombie_healthdeduction, 1)
			pmo.maxhealth = pmo.health
		end
	end
end

ZE2.SetZCscale = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local ztype = player["ze2_info"].zombie_type
	
	if pmo and pmo.valid then
		if ztype and zc[ztype] then
			pmo.scale = zc[ztype].scale or FRACUNIT
		end
	end
end

ZE2.SetZCinventory = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local ztype = player["ze2_info"].zombie_type
	
	if pmo and pmo.valid then
		if ztype and zc[ztype] and player["ze2_info"] then
			player["ze2_info"].zombie_inventory = ZE2:Copy(zc[ztype].inventory) or {}
			player["ze2_info"].zombie_inventory_limit = ZE2:Copy(zc[ztype].inventory_limit) or 2
		end
	end
end

ZE2.AddConfig = function(charname, input_table)
	if ZE2.CharacterConfig[charname] then
		print("Failed to add character: "..charname.." (Character already registered)")
	end

	ZE2.CharacterConfig[charname] = input_table
	ZE2.CharacterConfig[charname].sprintboost = $ or ZE2.CharacterConfig["default"].sprintboost
	table.insert(ZE2.registered_skins, charname)
	
	print("Added chararacter config: ".. charname)
end

ZE2.AddConfig("sonic", {
	normalspeed = 13 * FRACUNIT,
	health = 25,
	charability = CA_JUMPTHOK,
	charability2 = CA2_NONE,
	jumpfactor = 15 * FRACUNIT / 19,
	actionspd = 8*FRACUNIT,
	sprintboost = 12 * FRACUNIT,
	desc1 = "Fast hedgehog born to speed.",
	desc2 = "Has Low HP, and High Speed",
	desc3 = "Are you up for the challenge?"
})

ZE2.AddConfig("tails", {
	normalspeed = 12 * FRACUNIT,
	health = 55,
	charability = CA_FLY,
	charability2 = CA2_NONE,
	jumpfactor = 18 * FRACUNIT / 19,
	actionspd = 65*FRACUNIT,
	sprintboost = 11 * FRACUNIT,
	bullet_speed_multiplier = (3*FRACUNIT)/2, -- 1.5x
	desc1 = "Has the brains. Without the plane.",
	desc2 = "Flies slow. Slower than sonic."
})

ZE2.AddConfig("knuckles", {
	normalspeed = 10 * FRACUNIT,
	health = 90,
	charability = CA_GLIDEANDCLIMB,
	charability2 = CA2_NONE,
	jumpfactor = 17 * FRACUNIT / 19,
	actionspd = 24*FRACUNIT,
	sprintboost = 10 * FRACUNIT,
	bullet_speed_multiplier = FRACUNIT/2,
	desc1 = "Very Strong feller",
	desc2 = "Glides slow. The slowest."
})

ZE2.AddConfig("amy", {
	normalspeed = 11 * FRACUNIT,
	health = 45,
	charability = CA_TWINSPIN,
	charability2 = CA2_NONE,
	jumpfactor = 20 * FRACUNIT / 19,
	sprintboost = 11 * FRACUNIT,
	desc1 = "Pink Pink Pink.",
	desc2 = "WIP ABILITIES"
})

ZE2.AddConfig("fang", {
	normalspeed = 11 * FRACUNIT,
	health = 75,
	charability = CA_BOUNCE,
	charability2 = CA2_NONE,
	jumpfactor = 20 * FRACUNIT / 19,
	sprintboost = 12 * FRACUNIT,
	desc1 = "He shoots the shooty shoot.",
	desc2 = "Have less momentum to shoot."
})

ZE2.AddConfig("metalsonic", {
	normalspeed = 13 * FRACUNIT,
	health = 70,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	jumpfactor = 15 * FRACUNIT / 19,
	charflags = SF_MACHINE,
	sprintboost = 10 * FRACUNIT,
	desc1 = "He might the the real sonic.",
	desc2 = "Just a fella with an identity crisis.",
})

ZE2.RevertChars = function(p)
	if not p.realmo then return end
	local skin_name = p.realmo.skin
	p.charability = skins[skin_name].ability
	p.charability2 = skins[skin_name].ability2
	p.actionspd = skins[skin_name].actionspd
	p.charflags = skins[skin_name].flags
	p.actionspd = skins[skin_name].actionspd
	p.normalspeed = skins[skin_name].normalspeed
	p.runspeed = skins[skin_name].runspeed
	p.jumpfactor = skins[skin_name].jumpfactor
	p.mindash = skins[skin_name].mindash
	p.maxdash = skins[skin_name].maxdash
end