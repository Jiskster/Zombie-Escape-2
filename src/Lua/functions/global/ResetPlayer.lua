ZE2.ResetPlayer = function(player, choosenewztype)
	if player.ze2.team == 1 then
		ZE2.SetCCtoplayer(player)
		ZE2.SetCChealth(player)
		player.ze2.zombie_type = "normal"
	elseif player.ze2.team == 2 then
		ZE2.SetZCtoplayer(player)
		ZE2.SetZChealth(player)
		ZE2.SetZCscale(player)
		ZE2.SetZCinventory(player)
	end
end