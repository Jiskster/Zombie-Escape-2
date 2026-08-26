addHook("PlayerThink", function(player)
	if (player and not player.mo) then 
		return 
	end
	
	if player.ze2.respawntics then
		local game = ZE2.Game
		
		if player.spectator then
			player.ze2.respawntics = 0
		else
			if player.playerstate == PST_REBORN then
				player.playerstate = PST_DEAD
			end

			if not game.ended then
				player.ze2.respawntics = max(0, $ - 1)

				if not player.ze2.respawntics then
					if player.mo.team == 1 then
						player.ze2.outofgame = true
						player.ze2.injoinqueue = false
						player.spectator = true
						player.playerstate = PST_REBORN
					elseif player.mo.team == 2 then
						player.playerstate = PST_REBORN
						ZE2.ResetPlayer(player, 2, true) -- Mainly to reset inventory
					end
				end
			end
		end
	end
end)