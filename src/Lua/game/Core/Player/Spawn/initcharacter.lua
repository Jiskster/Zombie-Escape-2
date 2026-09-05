addHook("PlayerSpawn", function(player)
	local game = ZE2.Game
	
	player.ze2.lower_hud_offset = 0
	player.ze2.special_cooldown = 0
	
	if not ZE2.isGametype() then 
		if not multiplayer then
			if player.mo and player.mo.valid then
				player.mo.team = 1
			end

			player.lives = 3 -- mainly for singleplayer
		end
		
		return 
	end
	
	if not leveltime then return end

	local pmo = player.mo

	if player and pmo and pmo.valid then
		local player_count = ZE2.CountPlayers("ingame")

		-- Spawn as zombie if you join midgame
		if (game.active and player_count > 1) then 
			pmo.team = 2
			
			local chance = FU/8

			if player_count < 8 then
				chance = FU/4
			end

			if game.active and player_count > 1 then
				if player.ze2.zombie_type == "normal" then
					if P_RandomChance(chance) then
						player.ze2.zombie_type = "alpha"
					end
				end
			end

			player.ze2.was_spectating = false

			P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
		else -- join before game = survivor
			pmo.team = 1
		end

		ZE2.ResetPlayer(player, nil, pmo.team == 2)

		if pmo.team == 2 then
			R_SetPlayerSkin(player, "zsonic")
		end

		player.ze2.sprintmeter = 100*FRACUNIT
	end
end)