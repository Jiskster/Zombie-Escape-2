local mt = userdataMetatable("player_t")
local old_index = mt.__index

local xS_players = {}

addHook("NetVars", function(net)
	xS_players = net($)
end)

addHook("PlayerQuit", function(player)
	xS_players[player] = nil
end)

addHook("GameQuit", function()
	xS_players = {}
end)

mt.__index = function(player, key)
	if key == "xSlinger" then
		if not xS_players[player] then
			xS_players[player] = xSlinger.init()
			xS_players[player].player = player
			xS_players[player].mo = player.mo
			
			return xS_players[player]
		else
			-- Update references just in case.
			xS_players[player].player = player
			xS_players[player].mo = player.mo
			xS_players[player].team = 1
			
			return xS_players[player]
		end
	else
		return old_index(player, key)
	end 
end


