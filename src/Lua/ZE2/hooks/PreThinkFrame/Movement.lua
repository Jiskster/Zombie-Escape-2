return function()
	for player in players.iterate do 
		if not (player.mo and player.mo.valid) 
			continue end;
		
		local cmd = player.cmd

		local pmo = player.mo
		local cc = ZE2.SurvivorConfig
		local grounded = P_IsObjectOnGround(pmo)
		
		local ze2 = player.ze2

		local increment = FRACUNIT/2
		local decrement = FRACUNIT/2
		local boostdecrement = 25*FU

		if player.xSlinger.team ~= 1 then continue end
		if player.climbing then continue end

		if (player.speed/FU) > 17 then -- running
			local run = false
			if grounded and not ze2.crouching and ze2.isRunning then
				ze2:ChangeStamina(-decrement)
				P_SpawnSkidDust(player, 20*FRACUNIT)
				player.runspeed = 1
				run = true
			end
			
			if not (player.pflags & PF_SPINNING) then
				if not run then
					ze2:ChangeStamina(increment/2)
					player.runspeed = 32000*FRACUNIT
				end
			else
				ze2:ChangeStamina(-decrement)
				P_SpawnSkidDust(player, 20*FRACUNIT)
			end
		else
			if ze2.isRunning then
				player.pflags = $ & ~PF_SPINNING
				
				if not ze2.runstart then
					ze2.rundelay = 6
					ze2.isRunning = false
				end
			end

			if (player.speed/FU == 0) and grounded then -- not moving
				ze2:ChangeStamina(increment*3)
			else -- moving but slower than running speed
				ze2:ChangeStamina(increment)
			end
			
			player.runspeed = 32000*FRACUNIT
		end

		-- Stop running if you meet these requirements:
		if (not cmd.forwardmove) or (not ze2.sprintmeter) 
		or (ze2.sprintdelay) or (cmd.sidemove) then
			if ze2.isRunning then
				player.pflags = $ & ~PF_SPINNING
			end

			ze2.runstart = 0
			ze2.isRunning = false
		end

		-- "Acceleration" boost when starting to run.
		if ze2.runstart then
			P_Thrust(pmo, pmo.angle, 2*FU)
			
			if grounded then
				ze2.runstart = max(0, $ - 1)
			else
				ze2.runstart = max(0, $ - 2)
			end
		end

		if not grounded then
			continue
		end

		if ze2.crouching and ze2.isRunning then-- Rollin Time
			if (player.speed/FU) > 12 then
				player.pflags = $|PF_SPINNING
			else
				player.pflags = $ & ~(PF_SPINNING)
			end
		end

		-- Initial Running code
		if ze2.rundelay then
			ze2.rundelay = max(0, $ - 1)
		elseif ze2.sprintmeter then
			if (cmd.forwardmove > 0 and (cmd.buttons & BT_CUSTOM1) and not ze2.runstart) 
			and not (cmd.sidemove) and (player.speed/FU) > 8 then
				if (not ze2.isRunning) and (not ze2.crouching) then -- Start sprint
					ze2:ChangeStamina(-boostdecrement) 
					S_StartSound(pmo, sfx_s3ka2)
					ze2.runstart = 9
				end

				player.drawangle = pmo.angle
				ze2.isRunning = true
			elseif not (cmd.buttons & BT_CUSTOM1) then
				if ze2.isRunning then
					ze2.rundelay = 6 -- delay when letting go
				end
				
				ze2.isRunning = false
			end
		end
	end
end