ZE2.StandardJumpFactor = FixedDiv(90*FU, 100*FU)

-- TODO(?): Maybe each new entry added through modding could have a metatable applied to it
--			so we can be sure there are no "holes" in them? Maybe `newentry.__index = ZE2.SurvivorConfig["default"]`
ZE2.ZombieConfig = {
	["normal"] = {
		name = "Normal",
		skin = "zsonic",
		skincolor = SKINCOLOR_ZOMBIE,
		normalspeed = 21 * FRACUNIT,
		acceleration = 15,
		health = 2500,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 9*FRACUNIT,
		killaward = 10,
		inventory_limit = 1,
		items = {
			"insta_burst";
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
		normalspeed = 24 * FRACUNIT,
		acceleration = 14,
		health = 5000,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		actionspd = 26*FRACUNIT,
		scale = 11*FRACUNIT/10,
		killaward = 30,
		inventory_limit = 1,
		items = {
			"insta_burst";
			--ZE2:CopyItemFromID(ITEM_INSTA_BURST);
		},
		special = {
			button = BT_CUSTOM2,
			effect = "alphazombie.rage",
			effect_table = {
				normalspeed_multiplier = 2*FU,
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

function ZE2.resetPlayerHealth(player, newskin)
	local mo = player.mo
	local ze2 = player.ze2
	local xS = player.xSlinger
	local team = xS.team
	local ztype = ze2.zombie_type

	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig

	if not (mo and mo.valid) then
		return end;

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
	[1] = 36;
	[2] = 34;
	[3] = 32;
	[4] = 22;
	[5] = 21;
	[6] = 20;
	[7] = 19;
	[8] = 15;
	[9] = 12;
	[10] = 10;
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
	local team = xS.team
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

		if (player.speed/FU) > 12 and player.ze2.isRunning then
			player.normalspeed = ($*5)/4
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

	-- Remove player movement when game has not started.
	-- Also remove player movement when player is zombie when zombies has not been released.
	if (ZE2.zombie_releasetime and team == TEAM_ZOMBIE)
	or (ZE2.pregame_timeleft) then
		player.normalspeed = 0
		player.thrustfactor = 0
		player.jumpfactor = 0
		player.powers[pw_nocontrol] = 1
	end
end

ZE2.SetZCinventory = function(player)
	local pmo = player.mo
	local zc = ZE2.ZombieConfig
	local ztype = player.ze2.zombie_type

	/*
	if pmo and pmo.valid then
		if ztype and zc[ztype] and player.ze2 then
			player.ze2.zombie_inventory = ZE2:Copy(zc[ztype].inventory) or {}
			player.ze2.zombie_inventory_limit = ZE2:Copy(zc[ztype].inventory_limit) or 2
		end
	end
	*/
end

-- WARNING: This clears the inventory.
function ZE2.setConfigInventory(player, newskin, noitems)
	local xS = player.xSlinger
	local sc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig
	local ztype = player.ze2.zombie_type
	local mo = player.mo
	local team = xS.team

	if mo and mo.valid then
		local skin = newskin or mo.skin

		if team == 1 and sc[skin] then
			xS:inv_add("survivor", 5)

			if (not noitems) and (sc[skin].items) then
				for i,item in ipairs(sc[skin].items) do
					xS:give_item(item, nil, nil, nil, false, "survivor") -- being strict with the inventory
				end
			end
		elseif team == 2 and zc[ztype] then
			xS:inv_add("zombie", 3)

			if (not noitems) and (zc[ztype].items) then
				for i,item in ipairs(zc[ztype].items) do
					xS:give_item(item, nil, nil, nil, false, "zombie")
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
		"wood_fence";
		"wood_fence";
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
		"red_ring";
		"apple";
		"apple";
		"apple";
		"apple";
		"apple";
		"milk";
		"milk";
		"milk";
		"milk";
		"milk";
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
		"grenade_ring";
		"grenade_ring";
		"blue_spring";
		"blue_spring";
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
		"red_ring";
		"explosion_ring";
	};
})

function xSlinger.initPlayerSpawn(player)
	local xS = player.xSlinger

	if not xS:inv_get("survivor") then
		xS:inv_add("survivor", 5)
	end

	if not xS:inv_get("zombie") then
		xS:inv_add("zombie", 3)
	end

	xS:inv_set("survivor")

	player.ze2.lower_hud_offset = 0
	player.ze2.special_cooldown = 0
end

-- Health Fallback
function xSlinger.initPlayerHealth(player)
	ZE2.resetPlayerHealth(player)
end