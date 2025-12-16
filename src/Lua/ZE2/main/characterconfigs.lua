ZE2.StandardJumpFactor = FixedDiv(90*FU, 100*FU)

-- TODO(?): Maybe each new entry added through modding could have a metatable applied to it
--			so we can be sure there are no "holes" in them? Maybe `newentry.__index = ZE2.SurvivorConfig["default"]`
ZE2.ZombieConfig = {
	["normal"] = {
		skin = "zsonic",
		skincolor = SKINCOLOR_ZOMBIE,
		normalspeed = 25 * FRACUNIT,
		health = 2500,
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
	["alpha"] = {
		skin = "zsonic",
		skincolor = SKINCOLOR_ALPHAZOMBIE,
		normalspeed = 27 * FRACUNIT,
		health = 5000,
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

ZE2.SurvivorConfig = {}

ZE2.MobjTouchingPolyObj = function(mobj)
	for polyobj in polyobjects.iterate do
		if polyobj:mobjTouching(mobj) or polyobj:pointInside(mobj.x, mobj.y) then
			return true
		end
	end
	return false
end

function ZE2.resetPlayerHealth(player)
	local mo = player.mo
	local ze2 = player.ze2
	local team = ze2.team
	local ztype = ze2.zombie_type
	local skin = mo.skin
	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig
	local config = (team == 1) and cc[skin] or zc[ztype]

	if not (mo and mo.valid) then
		return end;

	if config.health then
		mo.health = config.health
		mo.maxhealth = config.health
	else
		mo.health = 1
		mo.maxhealth = 1
	end
end

local health_lookup = {
	[1] = 55;
	[2] = 65;
	[3] = 75;
	[4] = 90;
	[5] = 100;
	[6] = 110;
	[7] = 120;
	[8] = 180;
	[9] = 190;
	[10] = 200;
}

-- [example] = {27, 6}; -- 27.6 fracunits
local speed_lookup = {
	[1] = {24, 5};
	[2] = {23, 0};
	[3] = {22, 0};
	[4] = {20, 0};
	[5] = {19, 0};
	[6] = {18, 5};
	[7] = {18, 0};
	[8] = {16, 5};
	[9] = {16, 0};
	[10]= {15, 5};
}

local acceleration_lookup = {
	[1] = 13;
	[2] = 14;
	[3] = 15;
	[4] = 19;
	[5] = 20;
	[6] = 21;
	[7] = 22;
	[8] = 32;
	[9] = 34;
	[10] = 36;
}

local function weightToHealth(weight)
	weight = max(1, min($, 10))

	return health_lookup[weight]
end

local function weightToSpeed(weight)
	weight = max(1, min($, 10))

	return (speed_lookup[weight][1]*FU + FixedDiv(speed_lookup[weight][2]*FU, 10*FU))
end

local function weightToAcceleration(weight)
	weight = max(1, min($, 10))

	return acceleration_lookup[weight]
end

function ZE2.applyPlayerConfig(player)
	local mo = player.mo
	
	if not (mo and mo.valid) then
		return end;

	local ze2 = player.ze2
	local cmd = player.cmd
	local team = ze2.team
	local zc = ZE2.ZombieConfig
	local cc = ZE2.SurvivorConfig
	local ztype = ze2.zombie_type
	local skin = mo.skin
	local TEAM_SURVIVOR = 1
	local TEAM_ZOMBIE = 2
	
	local config = (team == TEAM_SURVIVOR) and cc[skin] or zc[ztype]

	-- Set zombie type to "normal" if the zombie type doesn't exist.
	if team == TEAM_ZOMBIE 
	and not zc[ztype] then
		ze2.zombie_type = "normal"
		config = zc["normal"]
	end
	
	if config.normalspeed then
		player.normalspeed = config.normalspeed
		
		if ze2.crouching and P_IsObjectOnGround(mo) then
			player.normalspeed = $ / 2
		end
	end

	player.jumpfactor = config.jumpfactor or ZE2.StandardJumpFactor

	if config.actionspd then
		player.actionspd = config.actionspd 
	end

	player.accelstart = config.accelstart or 128 -- survivors and zombies should have the same accelstart
	player.acceleration = config.acceleration or 20

	player.charability = config.charability or CA_NONE
	player.charability2 = config.charability2 or CA2_NONE

	-- thrustfactor doesn't need to be a config option by the way.
	if ZE2.sourcemovement.value then
		player.thrustfactor = 0
	else
		if P_IsObjectOnGround(mo) or
		(not P_IsObjectOnGround(mo) and cmd.forwardmove < 0 and P_GetPlayerControlDirection(player) == 2) 
		or ze2.isSprung then
			player.thrustfactor = 8
		else
			player.thrustfactor = 4
		end
		
		if ze2.zombie_slowtics then
			player.thrustfactor = 1
		end
	end

	if (config.charflags) then 
		player.charflags = $|(config.charflags)
	end

	if mo.shield_def and mo.shield_def.jumpfactor_multiplier then
		local multi = mo.shield_def.jumpfactor_multiplier
		
		player.jumpfactor = FixedMul($, multi)
	end
	
	if ze2.sprintdelay then
		if ZE2.sourcemovement.value then 
			player.jumpfactor = 3*$/4 
		else 
			player.jumpfactor = $ / 2 
		end

		player.actionspd = $ / 2
		player.normalspeed = $ / 2
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

function ZE2.AddSurvivor(skinname, input_table)
	local weight = input_table.weight
	
	if ZE2.SurvivorConfig[skinname] then
		print("Failed to add character: "..skinname.." (Character already registered)")
		return 
	end	

	if type(weight) ~= "number" then
		print("Failed to add character: "..skinname.." (weight is "..type(weight)..")")
		return
	end

	input_table.health = weightToHealth(weight)
	input_table.normalspeed = weightToSpeed(weight)
	input_table.acceleration = weightToAcceleration(weight)
	input_table.charability = CA_NONE
	input_table.charability2 = CA2_NONE
	input_table.jumpfactor = ZE2.StandardJumpFactor
	
	ZE2.SurvivorConfig[skinname] = input_table
	table.insert(ZE2.registered_skins, skinname)
	
	print("Added survivor config: ".. skinname)
end

ZE2.AddSurvivor("sonic", {
	weight = 3;
	description = {
		"Fast hedgehog, born to speed.";
		"Has Low HP, and High Speed";
		"A character for players who want a challenge.";
	};
})

ZE2.AddSurvivor("tails", {
	weight = 5;
	description = {
		"Has the brains. Without the plane.";
		"Has Average HP, and Average Speed.";
		"A character for beginners.";
	};
})

ZE2.AddSurvivor("knuckles", {
	weight = 8;
	description = {
		"No time to chuckle.";
		"Has High HP, and Low Speed.";
		"A character for good defenders.";
	};
})

ZE2.AddSurvivor("amy", {
	weight = 1;
	description = {
		"Don't be fooled, she's fierce.";
		"Has Low HP, and High Speed.";
		"A character for good healers.";
	};
})

ZE2.AddSurvivor("metalsonic", {
	weight = 7;
	description = {
		"The real sonic.";
		"Has Above Average HP, and Average Speed.";
		"A good fragging character.";
	};
})

ZE2.AddSurvivor("fang", {
	weight = 6;
	description = {
		"Pesky bounty hunter.";
		"Has Above Average HP, and Average Speed.";
		"A character with unique weapon combat.";
	};
})