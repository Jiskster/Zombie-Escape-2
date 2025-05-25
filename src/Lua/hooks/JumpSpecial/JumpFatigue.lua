local player = select(1, ...)

-- This hook handles:
-- Disabling jump when in a tight spot
-- Jump Fatigue (Decreasing stamina when jumping)

if gametype ~= GT_ZE2 then return end

if player.mo and player.mo.valid and not (player.pflags & PF_THOKKED) and P_IsObjectOnGround(player.mo) then
	if (player.mo.ceilingz - player.mo.floorz) < player.height + ZE2.playerheightoffset
	and player.ze2.crouching then
		return true
	end
	
	if not (player.pflags & PF_JUMPDOWN) then
		if player.ze2.team == 1 then
			player.ze2:ChangeStamina(-ZE2.JumpSprintFatigue)
		end
		
		if ZE2.landingfatigue.value then
			player.ze2.landfatigue = true
		end
	end
end