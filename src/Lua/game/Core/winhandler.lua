function ZE2:StartWin(team, fromring)
	local game = ZE2.Game
	game.ended = true
	game.team_won = team

	if team == 1 then
		S_ChangeMusic("SWIN", false)
		mapmusname = "SWIN"
	else
		S_ChangeMusic("ZWIN", false)
		mapmusname = "ZWIN"
	end

	-- TODO: stop using mobj iterate and remove killenemiesonwin functionality

	for mobj in mobjs.iterate() do
		if mobj.valid then
			local player = mobj.player
			if (player and player.valid and not player.spectator) then
				local pv = player.ze2

				if mobj.team ~= team then
					if team == 2 then
						player.ze2.karma = min($ + 200, ZE2.MaxKarma)
					end

					P_KillMobj(mobj)
				end

				continue
			end

			if (mobj.flags & MF_ENEMY) and (ZE2.killenemiesonwin.value) then
				P_KillMobj(mobj)
				continue
			end
		end
	end

	local cash_base_award = 15

	if fromring then
		cash_base_award = $ * 2
	end

	local cash_award = ZE2.CountPlayers("ingame")*cash_base_award

	for player in players.iterate do
		if player.spectator then continue end
		if not (player.mo and player.mo.valid) then continue end
		if player.mo.team ~= team then continue end

		if team == 1 then
			player.ze2.karma = max(1, $ / 2)
		end

		ZE2:GivePlayerCash(player, cash_award)
		S_StartSound(player.mo, sfx_rbyhit)
		CONS_Printf(player, "\x83 + $"..cash_award.." cash gained for winning!")
	end

	P_StartQuake(24*FRACUNIT, 3*TICRATE)

	xSlinger.visible_huds.inventory = false
end

addHook("ThinkFrame", function()
	local game = ZE2.Game
	
	if gamestate ~= GS_LEVEL then --stop the trolling
        return
    end

    if not game.active then
        return
    end

    if not leveltime then
        return
    end

	local player_count = 0
    local playing = 0
	local playersjoining = 0
	local zombies = 0
	local survivors = 0

	for player in players.iterate do
		if player.ze2.outofgame or not player.spectator then
			playing = $ + 1
		end

		if player.mo and player.mo.valid and not player.spectator then
			player_count = $ + 1
			
            if player.mo.health then
                if player.mo.team == 1 then
                    survivors = $ + 1
                elseif player.mo.team == 2 then
                    zombies = $ + 1
                end
            end
		end
	end

	if player_count > 1 and not game.ended then
		if zombies and not survivors then -- if all survivors are dead
			ZE2:StartWin(2)
		end
	end
end)