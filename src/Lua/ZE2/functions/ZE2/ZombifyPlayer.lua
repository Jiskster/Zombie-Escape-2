local zc = ZE2.ZombieConfig

ZE2.ZombifyPlayer = function(player, ztype)
	player.ze2.team = 2
	
	if not ztype then
		player.ze2.zombie_type = "normal"
	elseif zc[ztype] then
		player.ze2.zombie_type = ztype
	else
		print("Attempted to switch to invalid ztype: "..ztype)
		player.ze2.zombie_type = "normal"
	end
	
	ZE2.ResetPlayer(player)
end