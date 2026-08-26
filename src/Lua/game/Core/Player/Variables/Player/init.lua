local p_mt = userdataMetatable("player_t")
local p_mt_oldindex = p_mt.__index -- save old __index
local default_player = ZE2.Require "game/Core/Player/Variables/default_ze2"
local showed_deprecated_warning = false

local ze2_funcs_path = "game/Core/Player/Variables/Player/Functions/"

local ze2_funcs = {
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

function ZE2.initPlayer(player)
	if (player == nil) then
		return end;
		
	if not player.ze2 then
		player.ze2 = setmetatable(ZE2:Copy(default_player), ze2_mt)
	end
	
	player.ze2.player = player
end

addHook("PreThinkFrame", function(player)
	for player in players.iterate do
		ZE2.initPlayer(player)
	end
end)

addHook("PlayerSpawn", function(player)
	ZE2.initPlayer(player)
end)

addHook("MobjSpawn", function(mobj)
	if mobj and mobj.valid and mobj.player and mobj.player.valid then
		ZE2.initPlayer(mobj.player)
	end
end, MT_PLAYER)

local oldspawn = xSlinger.initPlayerSpawn

function xSlinger.initPlayerSpawn(player)
	ZE2.initPlayer(player)
	oldspawn(player)
end