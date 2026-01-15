return function()
	for player in players.iterate do 
		if not (player.mo and player.mo.valid) continue end
		
		local cmd = player.cmd

		local pmo = player.mo
		local cc = ZE2.SurvivorConfig
		local grounded = P_IsObjectOnGround(pmo)

		local increment = FRACUNIT/2
		local decrement = fixedfromstring("0.5") --tofixed?

		if player.xSlinger.team ~= 1 then continue end
		if player.climbing then continue end

		if (player.speed/FU) > 12 then -- running
			local run = false
			if grounded and not player.ze2.crouching and player.ze2.isRunning then
				player.ze2:ChangeStamina(-decrement)
				P_SpawnSkidDust(player, 20*FRACUNIT)
				player.runspeed = 1
				run = true
			end
			
			if not (player.pflags & PF_SPINNING) then
				if not run then
					player.ze2:ChangeStamina(increment/2)
					player.runspeed = 32000*FRACUNIT
				end
			else
				player.ze2:ChangeStamina(-decrement)
				P_SpawnSkidDust(player, 20*FRACUNIT)
			end
		else
			if player.ze2.isRunning then
				player.pflags = $ & ~PF_SPINNING
			end

			if (player.speed/FU == 0) and grounded then -- not moving
				player.ze2:ChangeStamina(increment*3)
			else -- moving but slower than running speed
				player.ze2:ChangeStamina(increment)
			end
			player.runspeed = 32000*FRACUNIT
		end
	end
end