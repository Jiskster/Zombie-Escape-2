return function(player, team, fromspectators, autobalance, scramble)
	if fromspectators then
		local player_count = 0

		for _ in players.iterate do
			player_count = $ + 1
		end

		player.ze2.was_spectating = true -- Disable special zombie types when unspectating

		if ZE2.round_active and not ZE2_game_ended and player_count > 1 then
			player.ze2.pregamemenu_active = false
			
			if player.ze2.outofgame then
				if not player.ze2.injoinqueue_delay then -- using this variable because why not
					chatprintf(player, "\x82* You are dead! Wait until the game is over!", true)
					player.ze2.injoinqueue_delay = 1*TICRATE
				end
			else
				if not player.ze2.injoinqueue_delay then
					
					player.ze2.injoinqueue = not $

					if player.ze2.injoinqueue then
						chatprintf(player, "\x82* Game is currently ongoing. \x83\Added to join queue.", true)
					else
						chatprintf(player, "\x82* Game is currently ongoing. \x85\Removed from join queue.", true) 
					end

					player.ze2.injoinqueue_delay = 5*TICRATE
				end
			end
			
			return false
		end
	end

	-- NEVER have pregamemenu_active on as spectator
	if team == 0 then
		if ZE2.round_active and not ZE2_game_ended then
			if player.xSlinger.team == 1 then
				player.ze2.karma = min($ + 70, ZE2.MaxKarma)
			elseif player.xSlinger.team == 2 then
				player.ze2.karma = min($ + 120, ZE2.MaxKarma)
			end
		end
		
		player.ze2.injoinqueue = false
		player.ze2.pregamemenu_active = false
	end
end