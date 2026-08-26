addHook("PlayerSpawn", function(player)
	local game = ZE2.Game
	if player.mo and player.mo.valid and player.mo.team == 2 and game.active and leveltime then
		ZE2.PlayZombieSound(player)
		player.powers[pw_flashing] = 0
	end
end)