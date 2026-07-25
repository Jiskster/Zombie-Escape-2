ZE2.init_gamevars = function(map) -- Variables vary per game.
	ZE2.round_active = false;
	ZE2.game_ended = false;
	ZE2.win_tics = 0; -- How many tics after a win screen. Resets on mapload.
	ZE2.game_time = 0;
	ZE2.time_limit = 0;
	ZE2.team_won = 0;

	ZE2.mapladdertag = nil;

	ZE2.pregame_timeleft = ZE2.wait_time;
	ZE2.zombie_releasetime = 0;

	ZE2.MapVoteList = {};
	ZE2.MapVotes = {0,0,0};
	ZE2.MapsOnVote = {
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1}
	}; -- votes, mapnumber

	ZE2.NextMapVoted = nil;

	-- This is local
	ZE2.charsel_selection = 1
	ZE2.charsel_prevselection = 1
	ZE2.pregame_menu = 1

	xSlinger.visible_huds.health = false;
	xSlinger.visible_huds.inventory = true;

	-- reset everyone
	for player in players.iterate do
		player.xSlinger.team = 1
		ZE2.lockPlayer(player) -- To make sure the player is the right skin for the team!
		
		player.ze2.selected_character = nil
		ZE2.ResetPlayer(player, 1, true, true)
	end
	
	ZE2.CharacterSlots = {}

	for i,v in ipairs(ZE2.registered_skins) do
		ZE2.CharacterSlots[i] = {
			count = 0;
			max = 1;
		}
	end

	if map then
		if ZE2.queuing_round then
			ZE2.rounds_left = $ - 1
			ZE2.queuing_round = false

			/*
			-- force reload everyone's weapon
			for player in players.iterate do
				for i,v in pairs(player.ze2.survivor_inventory) do
					v.ammo = v.max_ammo

					if v.skin_overwrite then
						for a,b in pairs(v.skin_overwrite) do
							if b.ammo ~= nil then
								if b.max_ammo ~= nil then
									b.ammo = b.max_ammo
								elseif v.max_ammo ~= nil then
									b.ammo = v.max_ammo
								end
							end
						end
					end
				end
			end
			*/
		else
			ZE2.rounds_left = tonumber(mapheaderinfo[map].ze2_rounds) or 3

			for i,v in pairs(ZE2.PreviousMaps) do
				v.matches_ago = $ + 1

				if v.matches_ago >= 8 then
					ZE2.PreviousMaps[i] = nil
				end
			end

			ZE2.PreviousMaps[map] = {
				mapnum = map;
				matches_ago = 0;
			}

			ZE2.queuing_round = false
		end

		chatprint("\x84* [ROUND " .. ZE2.getCurrentRound() .. "] *")

		if mapheaderinfo[map].ze2_timelimit then
			local input = tonumber(mapheaderinfo[map].ze2_timelimit)
			ZE2.time_limit = input*60*TICRATE
		end

		if mapheaderinfo[map].ze2_laddertag then
			local input = tonumber(mapheaderinfo[map].ze2_laddertag)
			ZE2.mapladdertag = input
		end
	end

	for player in players.iterate do
		if player.ze2 then
			player.ze2.ghostmode = false
			player.ze2.checkpoint_number = 0
			if player.ze2.outofgame or player.ze2.injoinqueue then
				player.spectator = false
				player.playerstate = PST_REBORN

				G_DoReborn(#player)
			end
			player.ze2.injoinqueue = false
			player.ze2.outofgame = false
			player.ze2.respawntics = 0
		end
	end
end; ZE2.init_gamevars();