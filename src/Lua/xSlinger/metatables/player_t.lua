local mt = userdataMetatable("player_t")
local old_index = mt.__index

local xS_players = {}

local function initPlayerNum(playernum, noinit, noteam)
	if not noinit then
		xS_players[playernum] = xSlinger.init()
	end
	
	if players[playernum] then
		xS_players[playernum].player = players[playernum]
		
		if players[playernum].mo then
			xS_players[playernum].mo = players[playernum].mo
		end
	end
	
	if not noteam then
		xS_players[playernum].team = 1
	end
	
	return xS_players[playernum]
end

addHook("NetVars", function(net)
	xS_players = net($)
end)

addHook("PlayerJoin", function(playernum)
	initPlayerNum(playernum, false, false)
end)

addHook("PlayerQuit", function(player)
	xS_players[#player] = nil
end)

addHook("GameQuit", function()
	xS_players = {}
end)

mt.__index = function(player, key)
	if key == "xSlinger" then
		if not xS_players[#player] then
			return initPlayerNum(#player, false, false)
		else
			-- Update references just in case.
			
			return initPlayerNum(#player, true, true)
		end
	else
		return old_index(player, key)
	end 
end


