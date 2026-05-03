local p_mt = userdataMetatable("player_t")
local p_mt_oldindex = p_mt.__index -- save old __index
local ze2_players = {} -- the grand table!!
local default_player = ZE2.Require "ZE2/variables/default/player"
local showed_deprecated_warning = false

local ze2_funcs_path = "ZE2/variables/metatables/player_functions/"

local ze2_funcs = {
	["UpdateDamageNumbers"] = ZE2.Require(ze2_funcs_path + "UpdateDamageNumbers");
	["DamageFade"] = ZE2.Require(ze2_funcs_path + "DamageFade");
	["ChangeStamina"] = ZE2.Require(ze2_funcs_path + "ChangeStamina");
}

local ze2_mt = { -- Metatable for the player_t.ze2 table.
	__index = function(a,k)
		if ze2_funcs[k] then
			return ze2_funcs[k]
		end
	end
}

registerMetatable(ze2_mt) -- Dont lose metatable when synching.

addHook("NetVars", function(net)
    ze2_players = net($);
end)

p_mt.__index = function(player, key) -- Create player_t.ze2
	if key == "ze2" then
		if player and player.valid then
			if ze2_players[#player] then
				ze2_players[#player].player = player -- Keep reference
				return ze2_players[#player]
			else
				ze2_players[#player] = setmetatable(ZE2:Copy(default_player), ze2_mt)
				ze2_players[#player].player = player -- Save reference of player as player_t.ze2.player

				return ze2_players[#player]
			end
		end
	else
		return p_mt_oldindex(player, key)
	end
end

addHook("PlayerQuit", function(player)
    if ze2_players[#player] then
        ze2_players[#player] = nil

		if ZE2.cv_debug.value then
			print("Removed player_t.ze2 from " + player.name + " [" + #player + "] ")
		end
    end
end)

addHook("PlayerJoin", function(playernum)
	ze2_players[playernum] = setmetatable(ZE2:Copy(default_player), ze2_mt)
end)

addHook("GameQuit", function()
    ze2_players = {}

	if ZE2.cv_debug.value then
		print("Removed all player_t.ze2")
	end
end)