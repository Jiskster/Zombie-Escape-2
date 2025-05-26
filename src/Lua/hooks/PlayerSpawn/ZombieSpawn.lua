return function(player)
	if ZE2.instantinfection.value then return end

	if player.mo and player.mo.valid and player.ze2.team == 2 and ZE2.round_active and leveltime then
		ZE2.PlayZombieSound(player)
	end
end