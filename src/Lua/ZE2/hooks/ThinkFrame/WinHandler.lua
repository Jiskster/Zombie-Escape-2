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
        local counted_player = false
        if (player.ze2.injoinqueue or player.ze2.outofgame) and not counted_player then
			if player.ze2.injoinqueue then
				playersjoining = $ + 1
			end

            player_count = $ + 1
            counted_player = true
        end

		if player.ze2.outofgame or not player.spectator then
			playing = $ + 1
		end

		if player.mo and player.mo.valid and not player.spectator then
            if not counted_player then
                player_count = $ + 1
                counted_player = true
            end

            if player.mo.health then
                if player.xSlinger.team == 1 then
                    survivors = $ + 1
                elseif player.xSlinger.team == 2 then
                    zombies = $ + 1
                end
            end
		end
	end

	if player_count > 1 and not ZE2.game_ended then
		if playersjoining and playing == 1 then
			ZE2:StartWin(1)
		end

		if survivors and not zombies then -- if all zombies are dead
			ZE2:StartWin(1)
		elseif zombies and not survivors then -- if all survivors are dead
			ZE2:StartWin(2)
		end
	end
end