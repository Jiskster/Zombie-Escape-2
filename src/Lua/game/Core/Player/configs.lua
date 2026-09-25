ZE2.StandardJumpFactor = FixedDiv(90*FU, 100*FU)
ZE2.DefaultSurvivorInvSlots = 5
ZE2.DefaultZombieInvSlots = 2

local item_blacklist = {
	["apple"] = true,
	["energy_drink"] = true,
	["grenade_ring"] = true,
}

-- TODO(?): Maybe each new entry added through modding could have a metatable applied to it
--			so we can be sure there are no "holes" in them? Maybe `newentry.__index = ZE2.SurvivorConfig["default"]`
ZE2.ZombieConfig = {
	["normal"] = {
		name = "Beta",
		skin = "zsonic",
		skincolor = SKINCOLOR_ZOMBIE,
		normalspeed = 20 * FRACUNIT,
		acceleration = 15,
		health = 2500,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 9*FRACUNIT,
		killaward = 10,
		inventory_limit = 1,
		items = {
			"insta_burst";
			"fist";
		},
		special = {
			button = 0, -- no button to disable
			/*
			effect = string_t,
			effect_table = table, (just whatever you plug into player.mo:give_effect(...)'s  2nd arg)
			effect_duration = tic_t,
			cooldown = tic_t,
			sound = sfx, (maybe make an ontrigger func?)
			*/
		}
	},
	["alpha"] = {
		name = "Alpha",
		skin = "zsonic",
		skincolor = SKINCOLOR_ALPHAZOMBIE,
		normalspeed = 21 * FRACUNIT,
		acceleration = 14,
		health = 5000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 30*FRACUNIT,
		scale = 11*FRACUNIT/10,
		killaward = 30,
		inventory_limit = 1,
		items = {
			"insta_burst";
			"fist";
		},
		special = {
			button = BT_CUSTOM2,
			effect = "alphazombie.rage",
			effect_table = {
				normalspeed_multiplier = 2*FU,
				damage_multiplier = (7*FU)/4,
				charability = CA_JUMPTHOK,
			},
			effect_duration = 2*TICRATE,
			cooldown = 40*TICRATE,
			sound = sfx_bstup,
		}
	},
}

ZE2.SurvivorConfig = {}

function ZE2.resetPlayerHealth(player, newskin)
	local mo = player.mo
	local ze2 = player.ze2
	local xS = player.xSlinger
	local ztype = ze2.zombie_type

	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig

	if not (mo and mo.valid) then
		return end;

	local team = mo.team

	local skin = newskin or mo.skin

	local config = cc[skin]

	if (team == 2) then
		config = zc[ztype]
	end

	if config and config.health then
		mo.health = config.health
		mo.maxhealth = config.health
	else
		mo.health = 1
		mo.maxhealth = 1
	end
end

local health_lookup = {
	[1] = 60;
	[2] = 75;
	[3] = 80;
	[4] = 95;
	[5] = 100;
	[6] = 105;
	[7] = 110;
	[8] = 130;
	[9] = 140;
	[10] = 150;
}

-- [example] = {27, 6}; -- 27.6 fracunits
local speed_lookup = {
	[1] = {19, 0};
	[2] = {18, 6};
	[3] = {18, 5};
	[4] = {18, 3};
	[5] = {18, 2};
	[6] = {18, 1};
	[7] = {18, 0};
	[8] = {17, 6};
	[9] = {17, 2};
	[10]= {17, 0};
}

local acceleration_lookup = {
	[1] = 30;
	[2] = 28;
	[3] = 26;
	[4] = 25;
	[5] = 23;
	[6] = 22;
	[7] = 20;
	[8] = 17;
	[9] = 16;
	[10] = 15;
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
	local xS = player.xSlinger
	local team = mo.team
	local zc = ZE2.ZombieConfig
	local cc = ZE2.SurvivorConfig
	local ztype = ze2.zombie_type
	local skin = mo.skin
	local TEAM_SURVIVOR = 1
	local TEAM_ZOMBIE = 2
	local game = ZE2.Game

	local config = (team == TEAM_SURVIVOR) and cc[skin] or zc[ztype]

	-- Set zombie type to "normal" if the zombie type doesn't exist.
	if team == TEAM_ZOMBIE
	and not zc[ztype] then
		ze2.zombie_type = "normal"
		config = zc["normal"]
	end

	if config.normalspeed then
		player.normalspeed = config.normalspeed

		if (player.speed/FU) > 12 and player.ze2.isRunning
		and team == TEAM_SURVIVOR then
			player.normalspeed = ($*4)/3
		elseif ze2.crouching and P_IsObjectOnGround(mo) then
			player.normalspeed = $ / 2
		end
	end

	player.jumpfactor = config.jumpfactor or ZE2.StandardJumpFactor

	if config.actionspd then
		player.actionspd = config.actionspd
	end

	player.accelstart = config.accelstart or 128 -- survivors and zombies should have the same accelstart
	player.acceleration = config.acceleration or 17

	player.charability = config.charability or CA_NONE
	player.charability2 = config.charability2 or CA2_NONE

	-- thrustfactor doesn't need to be a config option by the way.
	if ZE2.cv_sourcemovement.value then
		player.thrustfactor = 0
	else
		if P_IsObjectOnGround(mo) or
		(not P_IsObjectOnGround(mo) and cmd.forwardmove < 0 and P_GetPlayerControlDirection(player) == 2)
		or ze2.isSprung then
			player.thrustfactor = 8
		else
			player.thrustfactor = 4
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
		if ZE2.cv_sourcemovement.value then
			player.jumpfactor = 3*$/4
		else
			player.jumpfactor = $ / 2
		end

		player.actionspd = $ / 2
		player.normalspeed = $ / 2
	end

	if mo.effects then
		for i,effect in ipairs(mo.effects) do
			if effect.normalspeed then
				player.normalspeed = effect.normalspeed
			end

			if effect.actionspd then
				player.actionspd = effect.actionspd
			end

			if effect.charability then
				player.charability = effect.charability
			end

			if effect.normalspeed_multiplier then
				player.normalspeed = FixedMul($, effect.normalspeed_multiplier)
			end

			if effect.actionspd_multiplier then
				player.actionspd = FixedMul($, effect.actionspd_multiplier)
			end
		end
	end

	if multiplayer then
		-- Remove player movement when game has not started.
		-- Also remove player movement when player is zombie when zombies has not been released.
		if (game.releasetime > 0 and team == TEAM_ZOMBIE)
		or (not game.active) then
			player.normalspeed = 0
			player.thrustfactor = 0
			player.jumpfactor = 0
			player.powers[pw_nocontrol] = 1
		end
	end
end

-- WARNING: This clears the inventory.
function ZE2.setConfigInventory(player, newskin, noitems)
	local xS = player.xSlinger
	local sc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig
	local ztype = player.ze2.zombie_type
	local mo = player.mo
	if not mo or not mo.valid then return end

	local team = mo.team
	local skin = newskin or mo.skin
	if (team == 1) and sc[skin] then
		xS:inv_add("survivor", ZE2.DefaultSurvivorInvSlots)
		if (not noitems) and (sc[skin].items) then
			for i,item in ipairs(sc[skin].items) do
				if (type(item) == "table") then
					if item[1] and item_blacklist[item[1]] then
						continue
					end
					
					xS:give_item(item[1], item[2], nil, "survivor") -- being strict with the inventory
				else
					if item and item_blacklist[item] then
						continue
					end
					
					xS:give_item(item, nil, nil, "survivor")
				end
			end
		end
	elseif (team == 2) and zc[ztype] then
		xS:inv_add("zombie", ZE2.DefaultZombieInvSlots)
		if (not noitems) and (zc[ztype].items) then
			for i,item in ipairs(zc[ztype].items) do
				if (type(item) == "table") then
					xS:give_item(item[1], item[2], nil, "zombie")
				else
					xS:give_item(item, nil, nil, "zombie")
				end
			end
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

	if input_table.health_penalty then
		input_table.health = max(1, $ - abs(input_table.health_penalty))
	end

	ZE2.SurvivorConfig[skinname] = input_table
	table.insert(ZE2.registered_skins, skinname)

	ZE2.CharacterSlots[#ZE2.registered_skins] = {
		count = 0;
		max = 1;
	}

	print("Added survivor config: ".. skinname)
end

ZE2.AddSurvivor("sonic", {
	weight = 2;
	description = {
		"Fast hedgehog, born to speed.";
		"Has Low HP, and High Speed";
		"A character for players who want a challenge.";
	};
	items = {
		"red_ring";
		"scatter_ring";
	};
})

ZE2.AddSurvivor("tails", {
	weight = 5;
	description = {
		"Has the brains. Without the plane.";
		"Has Average HP, and Average Speed.";
		"A character for beginners.";
	};
	items = {
		"flame_ring";
		"scatter_ring";
		{"wood_fence", 10};
	};
})

ZE2.AddSurvivor("knuckles", {
	weight = 8;
	description = {
		"No time to chuckle.";
		"Has High HP, and Low Speed.";
		"A character for good defenders.";
	};
	items = {
		"auto_ring";
		"bounce_ring";
	};
})

ZE2.AddSurvivor("amy", {
	weight = 4;
	description = {
		"Don't be fooled, she's fierce.";
		"Has Low HP, and Average Speed.";
		"A character for good healers.";
	};
	health_penalty = 40;
	items = {
		"accel_ring";
		"amys_heart";
	};
})

ZE2.AddSurvivor("fang", {
	weight = 6;
	description = {
		"Pesky bounty hunter.";
		"Has Above Average HP, and Average Speed.";
		"A character with unique weapon combat.";
	};
	items = {
		"red_ring";
		"rail_ring";
	};
})

ZE2.AddSurvivor("metalsonic", {
	weight = 7;
	description = {
		"The real sonic.";
		"Has Above Average HP, and Average Speed.";
		"A good fragging character.";
	};
	items = {
		"explosion_ring";
		{"auto_turret", 12};
	};
})

-- do not access player.ze2 here or it will error
function xSlinger.initPlayerSpawn(player)
	xSlinger.initPlayer(player)

	local xS = player.xSlinger

	if not xS:inv_get("survivor") then
		xS:inv_add("survivor", ZE2.DefaultSurvivorInvSlots)
	end

	if not xS:inv_get("zombie") then
		xS:inv_add("zombie", ZE2.DefaultZombieInvSlots)
	end

	xS:inv_set("survivor")
end

-- Health Fallback
function xSlinger.initPlayerHealth(player)
	ZE2.resetPlayerHealth(player)
end

addHook("PlayerThink", ZE2.lockPlayer)