function ZE2:StartWin(team, fromring)
	local game = ZE2.Game
	game.ended = true
	game.team_won = team
	if (team == 1) then
		S_ChangeMusic("SWIN", false)
		mapmusname = "SWIN"
	elseif (team == 2) then
		S_ChangeMusic("ZWIN", false)
		mapmusname = "ZWIN"
	end

	local cash_base_award = 15
	if fromring then
		cash_base_award = cash_base_award * 2
	end

	local cash_award = ZE2.CountPlayers("ingame") * cash_base_award
	for player in players.iterate do
		if player.spectator then continue end
		if not (player.mo and player.mo.valid) then continue end

		local ze2 = player.ze2
		if (player.mo.team ~= team) then
			if (team == 2) then
				ze2.karma = min(ze2.karma + 200, ZE2.MaxKarma)
			end
			P_KillMobj(player.mo)
			continue
		end

		if (team == 1) then
			ze2.karma = max(1, ze2.karma / 2)
		end

		ZE2:GivePlayerCash(player, cash_award)
		S_StartSound(player.mo, sfx_rbyhit)
		CONS_Printf(player, "\x83 + $" .. cash_award.." cash gained for winning!")
	end
	P_StartQuake(24 * FRACUNIT, 3 * TICRATE)
	xSlinger.visible_huds.inventory = false
end

addHook("ThinkFrame", function()
	local game = ZE2.Game
	if (gamestate ~= GS_LEVEL) then return end -- stop the trolling
    if not game.active then return end
    if (leveltime <= 0) then return end

	local player_count = 0
    local playing = 0
	local playersjoining = 0
	local zombies = 0
	local survivors = 0
	for player in players.iterate do
		if player.ze2.outofgame or not player.spectator then
			playing = playing + 1
		end
		if not player.mo or not player.mo.valid or player.spectator then continue end

		player_count = player_count + 1
		if (player.mo.health <= 0) then continue end
		if (player.mo.team == 1) then
			survivors = survivors + 1
		elseif (player.mo.team == 2) then
			zombies = zombies + 1
		end
	end

	if (player_count > 1) and not game.ended then
		if (zombies > 0) and (survivors <= 0) then -- if all survivors are dead
			ZE2:StartWin(2)
		end
	end
end)