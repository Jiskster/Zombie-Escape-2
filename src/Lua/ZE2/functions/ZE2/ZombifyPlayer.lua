local zc = ZE2.ZombieConfig

ZE2.ZombifyPlayer = function(player, ztype)
	local xS = player.xSlinger
	local zc = ZE2.ZombieConfig

	if not ztype then
		player.ze2.zombie_type = "normal"
	elseif zc[ztype] then
		player.ze2.zombie_type = ztype
	else
		print("Attempted to switch to invalid ztype: "..ztype)
		player.ze2.zombie_type = "normal"
	end

	ZE2.ResetPlayer(player, 2, true)
end