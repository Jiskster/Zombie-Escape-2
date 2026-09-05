local function giveRandomAlpha(ignoreplayer)
	local found = {}
	for player in players.iterate do
		if (player.spectator) or (player.mo.team == 1)
		or (player.ze2.zombie_type ~= "normal")
		or (player == ignoreplayer) then
			continue
		end
		found[#found + 1] = player
	end

	if #found then
		local player = found[P_RandomRange(1,#found)]
		player.ze2.zombie_type = "alpha"
		player.mo.infectionfx = TICRATE * 3 / 2 -- infection_fx.lua
		ZE2.ResetPlayer(player, 2, true)

		local upgrade_sound = (P_RandomChance(FU/2) and sfx_zupg1 or sfx_zupg2)
		S_StartSound(player.mo, upgrade_sound)
	end
end

-- Using this hook, I give a random normal zombie alpha status if an alpha leaves
addHook("PlayerQuit", function(player)
	player.ze2.zombie_type = "normal" -- So it doesn't include the quitting zombie in count
	if player.mo and player.mo.valid then
		if player.mo.team == 2 then
			local alphas = ZE2.CountPlayers(function(player)
				return (not player.spectator)
				and (player.mo.team == 2)
				and (player.ze2.zombie_type == "alpha")
			end)

			local zombies = ZE2.CountPlayers("zombies")
			if zombies > 0 and alphas == 0 then
				giveRandomAlpha(player)
			end
		end
	end
end)