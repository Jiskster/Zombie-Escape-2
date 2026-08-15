return function(player)
	if not (player.mo and player.mo.valid) then return end
	if not (player.mo.team == 2) then return end
	if player.playerstate ~= PST_LIVE then return end

	local special = ZE2.ZombieConfig[player.ze2.zombie_type].special
	if not (special and special.button) then return end

	ZE2:TryBooleanAction(player, {
		condition = player.cmd.buttons & (special.button),
		var = "special_pressed",
		action = function()
			if not player.ze2.special_cooldown then
				player.ze2.special_cooldown = special.cooldown

				if special.sound ~= nil then
					S_StartSound(player.mo, special.sound)
				end

				if special.effect ~= nil then
					local effect_table = {}
					if special.effect_table ~= nil then
						effect_table = special.effect_table
					end

					player.mo:give_effect(special.effect, effect_table, special.effect_duration)
				end
			end
		end
	}, true)
end