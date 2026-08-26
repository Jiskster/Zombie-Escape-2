addHook("JumpSpecial", function(player)
	if player.mo and player.mo.valid and not (player.pflags & PF_THOKKED) and P_IsObjectOnGround(player.mo) then
		if (player.mo.ceilingz - player.mo.floorz) < player.height + ZE2.playerheightoffset
		and player.ze2.crouching then
			return true
		end
		
		local sprintloss = ZE2.JumpSprintFatigue
		local speed = abs(R_PointToDist2(0, 0, player.rmomx, player.rmomy))
		
		if speed > (player.normalspeed - FU) or player.ze2.isRunning then
			sprintloss = ($ * 8)/5
		end
		
		if not (player.pflags & PF_JUMPDOWN) then
			if player.mo.team == 1 then
				player.ze2:ChangeStamina(-sprintloss)
			end
		end
	end
end)