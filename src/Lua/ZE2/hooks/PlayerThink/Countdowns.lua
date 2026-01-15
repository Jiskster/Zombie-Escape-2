return function(player)
	if player.ze2.injoinqueue_delay then
		player.ze2.injoinqueue_delay = max(0, $ - 1)
	end

	if player and not player.mo then return end

	-- Special Ability
	if player.ze2.special_cooldown then
		player.ze2.special_cooldown = $ - 1
	end

	-- Make zombies slow after hit
	if player.ze2.zombie_slowtics then
		player.ze2.zombie_slowtics = max(0, $ - 1)
	end

	-- When this hits zero, catch up to your teammates!
	if player.ze2.checkpoint_catchuptics then
		player.ze2.checkpoint_catchuptics = $ - 1
		
		if not player.ze2.checkpoint_catchuptics then
			ZE2.LatestCheckpointTeleport(player, true)
		end
	end
	
	if player.ze2.respawntics then
		if player.spectator then
			player.ze2.respawntics = 0
		else
			if player.playerstate == PST_REBORN then
				player.playerstate = PST_DEAD
			end
		
			if not ZE2.game_ended then
				player.ze2.respawntics = max(0, $ - 1)
				
				if not player.ze2.respawntics then
					if player.xSlinger.team == 1 then
						player.ze2.outofgame = true
						player.ze2.injoinqueue = false
						player.spectator = true
						player.playerstate = PST_REBORN
						G_DoReborn(#player)
					elseif player.xSlinger.team == 2 then
						player.playerstate = PST_REBORN
						G_DoReborn(#player)
						ZE2.ResetPlayer(player, 2, true) -- Mainly to reset inventory
					end
				end
			end
		end
	end

	-- Sprint Delay is where the sprint meter doesnt increase if .sprintdelay > 0
	-- The player is noticably slower when .sprintdelay > 0
	if player.ze2.sprintdelay then
		if player.ze2.sprintmeter then
			player.ze2.sprintdelay = 0
		else
			player.ze2.sprintdelay = $ - 1
		end
	elseif player.ze2.sprintdelay < 0 then
		player.ze2.sprintdelay = 0
	end
end
