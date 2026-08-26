xSlinger.registerEffect("alphazombie.rage_regen", {
	max_duration = TICRATE,

	---@param effect table
	---@param mobj mobj_t
	---@param time_left tic_t
	tick = function(effect, mobj, time_left)
		local player = mobj.player

		if not (player and player.valid) then 
			return
		end

		if (player.ze2.special_cooldown <= 0) then 
			return 
		end

		player.ze2.special_cooldown = player.ze2.special_cooldown - 2

		if (player.ze2.special_cooldown < 0) then
			player.ze2.special_cooldown = 0
		end
	end;
})