return function()
    if gamestate ~= GS_LEVEL then --stop the trolling
        return
    end

    if not ZE2.round_active then
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

	if player_count > 1 and not ZE2.game_ended then
		if zombies and not survivors then -- if all survivors are dead
			ZE2:StartWin(2)
		end
	end
end