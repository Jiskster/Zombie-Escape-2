ZE2.debughud = function(v, player, camera)
	if true then return end
	
	if gametype ~= GT_ZE2 then return end
	if not player.mo then return end
	
	for target_player in players.iterate do
		local result = SG_ObjectTracking(v, player, camera, {x = target_player.realmo.x, y = target_player.realmo.y, z = target_player.realmo.z}, false)
		if not result.onScreen then 
			continue
		end
		if target_player == player then
			continue
		end
		
		print("X: ".. result.x)
		print("Y: ".. result.y)
		
		v.drawString(result.x-(24*FU), result.y, "Player", 0, "fixed")
	end
end