return function(player)
	if gametype ~= GT_ZE2 and leveltime then return end

	local pmo = player.mo
	
	if player and pmo and pmo.valid then
		local player_count = ZE2.PlayerCount()
		
		if (ZE2.round_active and player_count > 1) then
			player.ze2.team = 2
			player.ze2.zombie_type = "normal"
			
			local chance = FU/8
			
			if player_count < 8 then
				chance = FU/4
			end
			
			if P_RandomChance(chance) then
				player.ze2.zombie_next_type = "alpha"
			end
			
			if ZE2.round_active and player_count > 1 and leveltime then
				-- killedbysomething variable is to prevent players from suiciding to get a special zombie
				-- same goes for was_spectating
				if player.ze2.zombie_next_type then
					player.ze2.zombie_type = player.ze2.zombie_next_type
					player.ze2.zombie_next_type = nil
				else
					player.ze2.zombie_type = "normal"
				end
				
				player.ze2.killedbysomething = false
			end
			
			player.ze2.zombie_shop_open = false
			
			player.ze2.was_spectating = false
			
			P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
		else
			player.ze2.team = 1
		end
		
		ZE2.ResetPlayer(player, true)

		if player.ze2.team == 2 then 
			R_SetPlayerSkin(player, "zsonic") 
		end

		player.ze2.sprintmeter = 100*FRACUNIT
	end
end