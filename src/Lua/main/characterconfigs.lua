ZE2.StandardJumpFactor = FixedDiv(90*FU, 100*FU)

-- TODO(?): Maybe each new entry added through modding could have a metatable applied to it
--			so we can be sure there are no "holes" in them? Maybe `newentry.__index = ZE2.CharacterConfig["default"]`
ZE2.ZombieConfig = {
	["normal"] = {
		skin = "zsonic",
		skincolor = SKINCOLOR_MOSS,
		normalspeed = 18 * FRACUNIT,
		health = 10000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 9*FRACUNIT,
		killaward = 10,
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST);
		},
		special = {
			button = 0, -- no button to disable
			/*
			effect = string_t,
			effect_table = table, (just whatever you plug into player.ze2:GiveEffect)
			effect_duration = tic_t,
			cooldown = tic_t,
			sound = sfx, (maybe make an ontrigger func?)
			*/
		}
	},
	["ranged"] = {
		skin = "ztails",
		skincolor = SKINCOLOR_MOSS,
		normalspeed = 20 * FRACUNIT,
		health = 4000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 9*FRACUNIT,
		killaward = 5,
		knockback_multiplier = (3*FU)/2,
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST);
		},
		special = {
			button = 0,
		}
	},
	["heavy"] = {
		skin = "zknuckles",
		skincolor = SKINCOLOR_MOSS,
		normalspeed = 16 * FRACUNIT,
		health = 12000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		jumpfactor = ZE2.StandardJumpFactor,
		actionspd = 9*FRACUNIT,
		killaward = 10,
		knockback_multiplier = 8*(FU/10),
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST);
		},
		special = {
			button = 0,
		}
	},
	["alpha"] = {
		skin = "zsonic",
		skincolor = SKINCOLOR_ALPHAZOMBIE,
		normalspeed = 17 * FRACUNIT,
		health = 15000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 16*FRACUNIT,
		scale = 11*FRACUNIT/10,
		killaward = 30,
		knockback_multiplier = 7*(FU/10),
		inventory_limit = 1,
		inventory = {
			ZE2:CopyItemFromID(ITEM_INSTA_BURST);
		},
		special = {
			button = BT_CUSTOM2,
			effect = "alphazombie.rage",
			effect_table = {
				normalspeed_multiplier = 2*FU,
				actionspd_multiplier = tofixed("1.17"),
				damage_multiplier = 3*FU/2,
				charability = CA_JUMPTHOK,
			},
			effect_duration = 3*TICRATE,
			cooldown = 40*TICRATE,
			sound = sfx_bstup,
		}
	},
}

ZE2.CharacterConfig = {
	["default"] = {
		normalspeed = 10 * FRACUNIT,
		health = 40,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		FixedDiv(85*FU, 100*FU),
		sprintboost = 10 * FRACUNIT,
		jumpfactor = ZE2.StandardJumpFactor,
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
			
			if player.ze2.crouching and P_IsObjectOnGround(pmo) then
				player.normalspeed = $ / 2
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

		if ZE2.sourcemovement.value then
			player.thrustfactor = 0
		else
			if P_IsObjectOnGround(pmo) or
			(not P_IsObjectOnGround(pmo) and cmd.forwardmove < 0 and P_GetPlayerControlDirection(player) == 2) 
			or player.ze2.isSprung then
				player.thrustfactor = 8
			else
				player.thrustfactor = 4
			end
		end
		
		if (cc[pmo.skin].charflags) then 
			player.charflags = $|cc[pmo.skin].charflags 
		end
		
		if pmo.shield_def and pmo.shield_def.jumpfactor_multiplier then
			local multi = pmo.shield_def.jumpfactor_multiplier
			
			player.jumpfactor = FixedMul($, multi)
		end
		
		if player.ze2.sprintdelay then
			if ZE2.sourcemovement.value then player.jumpfactor = 3*$/4 else player.jumpfactor = $ / 2 end
			player.actionspd = $ / 2
			player.normalspeed = $ / 2
		end
		
		if player.ze2.isRunning then
			player.normalspeed = $ + 7*FU
		end

		if (cc[pmo.skin].speedcap) and not ZE2.MobjTouchingPolyObj(pmo) then 
			local sprintboost = cc[pmo.skin].sprintboost or cc["default"].sprintboost
			if (sprintboost) and (player.ze2.isSprinting and player.ze2.sprintmeter > 0) and (player.ze2.team == 1) then
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
	local cmd = player.cmd
	local zc = ZE2.ZombieConfig
	local cc = ZE2.CharacterConfig
	local ztype = player.ze2.zombie_type
	
	if pmo and pmo.valid then
		if zc[ztype] then
			if (zc[ztype].normalspeed) then
				player.normalspeed = zc[ztype].normalspeed
			else
				player.normalspeed = cc["default"].normalspeed
			end
			
			if player.ze2.crouching and P_IsObjectOnGround(pmo) then
				player.normalspeed = $ / 2
			end
			
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
				player.accelstart = 128
			end
			
			if (zc[ztype].acceleration) then 
				player.acceleration = zc[ztype].acceleration 
			else
				player.acceleration = 40
			end

			if ZE2.sourcemovement.value then
				player.thrustfactor = 0
			else
				if P_IsObjectOnGround(pmo) or
				(not P_IsObjectOnGround(pmo) and cmd.forwardmove < 0 and P_GetPlayerControlDirection(player) == 2) 
				or player.ze2.isSprung then
					player.thrustfactor = 8
				else
					player.thrustfactor = 4
				end
				
				if player.ze2.zombie_slowtics then
					player.thrustfactor = 1
				end
			end

			if (zc[ztype].charflags) then 
				player.charflags = $|zc[ztype].charflags 
			end
		else
			player.ze2.zombie_type = "normal"
		end
	end
end

ZE2.SetZChealth = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local cc = ZE2.CharacterConfig
	local ztype = player.ze2.zombie_type
	
	if pmo and pmo.valid then
		if zc[ztype] then
			local healthpersurvivor = zc[ztype].healthpersurvivor or 0
			
			if (zc[ztype].health) then
				pmo.health = zc[ztype].health + (ZE2.SurvivorCount()*healthpersurvivor)
				pmo.maxhealth = pmo.health
			else
				pmo.health = cc["default"].health + (ZE2.SurvivorCount()*healthpersurvivor) -- cc still isnt a typo
				pmo.maxhealth = pmo.health
			end
		else
			pmo.health = cc["default"].health

			pmo.maxhealth = pmo.health
		end
	end
end

ZE2.SetZCscale = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local ztype = player.ze2.zombie_type
	
	if pmo and pmo.valid then
		if ztype and zc[ztype] then
			pmo.scale = zc[ztype].scale or FRACUNIT
		end
	end
end

ZE2.SetZCinventory = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local ztype = player.ze2.zombie_type
	
	if pmo and pmo.valid then
		if ztype and zc[ztype] and player.ze2 then
			player.ze2.zombie_inventory = ZE2:Copy(zc[ztype].inventory) or {}
			player.ze2.zombie_inventory_limit = ZE2:Copy(zc[ztype].inventory_limit) or 2
		end
	end
end

function ZE2:AddCharacterConfig(skinname, input_table)
	local ZE2 = self;
	local speeds = {
		[1] = 15*FRACUNIT, -- slow
		[2] = 16*FRACUNIT, -- normal
		[3] = 17*FRACUNIT, -- fast
		
		["slow"] = 15*FRACUNIT,
		["normal"] = 16*FRACUNIT,
		["fast"] = 17*FRACUNIT,
	}
	
	if ZE2.CharacterConfig[skinname] then
		print("Failed to add character: "..skinname.." (Character already registered)")
		return 
	end
	
	if input_table.speed ~= nil then
		if type(input_table.speed) == ("string") then
			input_table.speed = $:lower()
		end
		
		if speeds[input_table.speed] then
			input_table.normalspeed = speeds[input_table.speed]
		else
			input_table.normalspeed = speeds["normal"]
		end
	else
		input_table.normalspeed = speeds["normal"]
	end
	
	input_table.charability = CA_NONE
	input_table.charability2 = CA2_NONE
	input_table.jumpfactor = ZE2.StandardJumpFactor
	
	ZE2.CharacterConfig[skinname] = input_table
	ZE2.CharacterConfig[skinname].sprintboost = $ or ZE2.CharacterConfig["default"].sprintboost
	table.insert(ZE2.registered_skins, skinname)
	
	print("Added chararacter config: ".. skinname)
end

ZE2:AddCharacterConfig("sonic", {
	health = 100,
	speed = "fast",
	desc1 = "Fast hedgehog born to speed.",
	desc2 = "Has Low HP, and High Speed",
	desc3 = "Are you up for the challenge?"
})

ZE2:AddCharacterConfig("tails", {
	health = 150,
	speed = "normal",
	desc1 = "Has the brains. Without the plane.",
	desc2 = "Flies slow. Slower than sonic."
})

ZE2:AddCharacterConfig("knuckles", {
	health = 200,
	speed = "slow",
	desc1 = "Very Strong feller",
	desc2 = "Glides slow. The slowest."
})

ZE2:AddCharacterConfig("amy", {
	health = 75,
	charflags = SF_FASTWAIT,
	speed = "fast",
	desc1 = "Pink Pink Pink.",
	desc2 = "WIP ABILITIES"
})

ZE2:AddCharacterConfig("fang", {
	health = 110,
	charflags = SF_FASTEDGE,
	speed = "normal",
	desc1 = "He shoots the shooty shoot.",
	desc2 = "Have less momentum to shoot."
})

ZE2:AddCharacterConfig("metalsonic", {
	health = 105,
	speed = "fast",
	charflags = SF_MACHINE,
	desc1 = "He might the the real sonic.",
	desc2 = "Just a fella with an identity crisis.",
})