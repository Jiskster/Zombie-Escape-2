local roundresetting = false

addHook("NetVars", function(net)
	roundresetting = net($)
end)

addHook("MapChange", function()
	roundresetting = false
end)

local function showOutOfGameText(player)
	if not player.ze2.injoinqueue_delay then -- using this variable because why not
		chatprintf(player, "\x82" .. "* You are dead! Wait until the game is over!", true)
		player.ze2.injoinqueue_delay = 1*TICRATE
	end
end

local function toggleQueue(player)
	if player.ze2.outofgame then
		showOutOfGameText(player)
	else
		if not player.ze2.injoinqueue_delay then
			player.ze2.injoinqueue = not $

			if player.ze2.injoinqueue then
				chatprintf(player, "\x82" .. "* Game is currently ongoing. " .. "\x83" .. "Added to join queue.", true)
			else
				chatprintf(player, "\x82" .. "* Game is currently ongoing. " .. "\x85" .. "Removed from join queue.", true)
			end

			player.ze2.injoinqueue_delay = 1*TICRATE
		end
	end
end

return function(player, team, fromspectators, autobalance, scramble)
	if fromspectators then
		local player_count = 0

		for p in players.iterate do
			if p.mo and p.mo.valid and p.mo.health and not p.spectator then
				player_count = $ + 1
			end
		end

		player.ze2.was_spectating = true -- Disable special zombie types when unspectating

		if ZE2.round_active then
			if player_count == 1 then
				if not ZE2_game_ended then
					if player.ze2.outofgame then
						showOutOfGameText(player)
						return false
					end
					
					return true
				else
					toggleQueue(player)
					return false
				end
			elseif player_count > 0 then
				toggleQueue(player)
				
				return false
			elseif not roundresetting then -- reset whole match
				roundresetting = true
				player.ze2.injoinqueue = true
				G_SetCustomExitVars(gamemap, 2)
				G_ExitLevel()
				return false
			end
		end
	end

	-- NEVER have pregamemenu_active on as spectator
	if team == 0 then
		if ZE2.round_active and not ZE2_game_ended then
			if player.mo and player.mo.valid then
				if player.mo.team == 1 then
					player.ze2.karma = min($ + 70, ZE2.MaxKarma)
				elseif player.mo.team == 2 then
					player.ze2.karma = min($ + 120, ZE2.MaxKarma)
				end
			end
		end
		
		player.ze2.injoinqueue = false
	end
end