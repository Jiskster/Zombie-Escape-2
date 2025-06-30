return function(player)
	if not (player.mo and player.mo.valid) then return end
	if not (player.ze2.team == 2 and player.ze2.zombie_type == "alpha") then return end
	if player.playerstate ~= PST_LIVE then return end

	ZE2:TryBooleanAction(player, {
		condition = player.cmd.buttons & BT_CUSTOM2,
		var = "special_pressed",
		action = function()
			if not player.ze2.special_cooldown then
				player.ze2.special_cooldown = 40*TICRATE
				
				S_StartSound(player.mo, sfx_bstup)
				
				player.ze2:GiveEffect("alphazombie.rage", {
					normalspeed_multiplier = 2*FU,
					actionspd_multiplier = tofixed("1.17"),
					damage_multiplier = 3*FU/2,
					charability = CA_JUMPTHOK,
				}, 3*TICRATE)
			end
		end
	}, true)
end