ZE2.SurvivorCount = function()
	local c = 0
	for player in players.iterate do 
		if player.xSlinger.team ~= nil and player.xSlinger.team == 1 and not player.spectator then 
			c = $ + 1 
		end 
	end
	return c
end

ZE2.SurvivorList = function()
	local c = {}
	for player in players.iterate do 
		if player.xSlinger.team ~= nil and player.xSlinger.team == 1 and not player.spectator then 
			table.insert(c,player)
		end 
	end
	return c
end

ZE2.ZombieCount = function()
	local c = 0
	for player in players.iterate do 
		if player.xSlinger.team ~= nil and player.xSlinger.team == 2 and not player.spectator then 
			c = $ + 1 
		end
	end
	return c
end

ZE2.ZombieList = function()
	local c = {}
	for player in players.iterate do 
		if player.xSlinger.team ~= nil and player.xSlinger.team == 2 and not player.spectator then 
			table.insert(c,player)
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