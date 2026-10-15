addHook("PlayerThink", function(player)
	local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()

	if (player and not player.mo) then 
		return 
	end

	if player.playerstate == PST_DEAD then
		if not game.ended and not player.ze2.respawntics then
			if player.mo.team == 1 then
				player.ze2.respawntics = settings.respawn_time[1]
				if not (settings.zombie_after_death) then
					player.ze2.outofgame = true
				elseif game.active then -- only give zombie if game is active
					player.mo.team = 2
				end
			elseif player.mo.team == 2 then
				player.ze2.respawntics = settings.respawn_time[2]
			end
		end
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
						if not (settings.zombie_after_death) then
							player.ze2.outofgame = true
							player.ze2.injoinqueue = false
							player.spectator = true
						else
							player.mo.team = 2
							ZE2.ResetPlayer(player, 2, true) -- Mainly to reset inventory
						end
						
						player.playerstate = PST_REBORN
					elseif player.mo.team == 2 then
						player.playerstate = PST_REBORN
						ZE2.ResetPlayer(player, 2, true) -- Mainly to reset inventory
					end
				end
			end
		end
	end
	
	if game.ended then
		if player.playerstate == PST_REBORN then
			player.playerstate = PST_DEAD
		end
	end
end)