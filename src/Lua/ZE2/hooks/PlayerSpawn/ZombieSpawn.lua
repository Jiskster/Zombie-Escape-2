return function(player)
	if player.mo and player.mo.valid and player.xSlinger.team == 2 and ZE2.round_active and leveltime then
		ZE2.PlayZombieSound(player)
	end
end