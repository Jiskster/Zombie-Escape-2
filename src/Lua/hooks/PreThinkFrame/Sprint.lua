if (gametype ~= GT_ZE2) then return end

for player in players.iterate do 
	if not (player.mo and player.mo.valid) continue end
	
	local cmd = player.cmd

	local pmo = player.mo
	local cc = ZE2.CharacterConfig

	local increment = FRACUNIT/2
	local decrement = fixedfromstring("0.142")

	if player.ze2.team == 1 then
		if not player.climbing then
			if (player.speed/FU) > 12 then -- running
				if P_IsObjectOnGround(pmo) and not player.ze2.crouching then
					--P_SpawnSkidDust(player, 20*FRACUNIT)
				end
				
				player.ze2:ChangeStamina(increment/2)
				
				player.runspeed = 32000*FRACUNIT
			else
				if not (player.speed/FU) then -- not moving
					player.ze2:ChangeStamina(increment*3)
				else -- moving but slower than running speed
					player.ze2:ChangeStamina(increment)
				end
				
				player.runspeed = 32000*FRACUNIT
			end
		end
	end
end