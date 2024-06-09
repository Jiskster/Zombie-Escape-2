ZE2.SurvivorCount = function()
	local c = 0
	for player in players.iterate do 
		if player["ze2_info"].team ~= nil and player["ze2_info"].team == 1 and not player.spectator then 
			c = $ + 1 
		end 
	end
	return c
end

ZE2.ZombieCount = function()
	local c = 0
	for player in players.iterate do 
		if player["ze2_info"].team ~= nil and player["ze2_info"].team == 2 and not player.spectator then 
			c = $ + 1 
		end
	end
	return c
end

ZE2.PlayerCount = function()
	local c = 0
	for player in players.iterate do 
		if not player.spectator then
			c = $ + 1
		end
	end
	return c
end