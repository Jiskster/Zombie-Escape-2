return function(player)
	-- Special Ability
	if player.ze2.special_cooldown then
		player.ze2.special_cooldown = $ - 1
	end

	if player and not player.mo then return end

	-- Remove player's friction if > 0
	if player.ze2.nofrictiontics then
		player.mo.friction = FRACUNIT
		
		player.ze2.nofrictiontics = max(0, $ - 1)
	end

	-- When this hits zero, catch up to your teammates!
	if player.ze2.checkpoint_catchuptics then
		player.ze2.checkpoint_catchuptics = $ - 1
		
		if not player.ze2.checkpoint_catchuptics then
			ZE2.LatestCheckpointTeleport(player, true)
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
