local function getTeam(player)
	if player.mo and player.mo.valid then
		return player.mo.team
	end
	
	return 0
end

local type_table = {
	["ingame"] = function(player)
		return (not player.spectator)
	end,
	["survivors"] = function(player)
		return (not player.spectator) 
		and (getTeam(player) == 1)
	end,
	["zombies"] = function(player)
		return (not player.spectator) 
		and (getTeam(player) == 2)
	end,
}

function ZE2.CountPlayers(ptype)
	local count = 0
	
	for player in players.iterate do
		if ptype and type(ptype) == "function" then
			if ptype(player) then
				count = $ + 1
			end
			continue
		elseif ptype and type_table[ptype] and not type_table[ptype](player) then
			continue
		end
		
		count = $ + 1
	end
	
	return count
end

function ZE2.ListPlayers(ptype)
	local list = {}
	
	for player in players.iterate do
		if ptype and type_table[ptype] and not type_table[ptype](player) then
			continue
		end
		
		table.insert(list, player)
	end
	
	return list
end