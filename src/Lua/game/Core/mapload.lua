local function MapLoad(map)
	local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
	
	ZE2.GameReset(map)
	ZE2.VoteReset()

	game.state_tics = settings.default_pregame_time

	xSlinger.visible_huds.health = false;
	xSlinger.visible_huds.inventory = true;

	if map then
		-- reset everyone
		for player in players.iterate do
			local xS = player.xSlinger
			
			if player.mo and player.mo.valid then
				player.mo.team = 1
			end
			
			ZE2.lockPlayer(player) -- To make sure the player is the right skin for the team!
			
			player.ze2.selected_character = nil
			ZE2.ResetPlayer(player, 1, true, true)
			xS:inv_clear("survivor")
			
			local pvote = player.ze2.vote
			
			pvote.selection = 1
			pvote.lasthit = nil
			pvote.lastside = 0
			pvote.lastforward = 0
			pvote.lastbuttons = 0
		end
		
		if game.queueround then
			game.round = $ + 1
		end
		
		game.queueround = false
		
		if not titlemapinaction then
			chatprint("\x84* [ROUND " .. game.round .. "] *")
		end
		
		if mapheaderinfo[map].ze2_timelimit then
			local input = tonumber(mapheaderinfo[map].ze2_timelimit)
			game.time_limit = input*60*TICRATE
		else
			game.time_limit = settings.default_round_time
		end
	end

	for player in players.iterate do
		if player.ze2 then
			player.ze2.ghostmode = false
			player.ze2.checkpoint_number = 0
			player.ze2.checkpoint_number_next = 0
			player.ze2.checkpoint_timer = 0
			if player.ze2.outofgame or player.ze2.injoinqueue then
				player.spectator = false
				player.playerstate = PST_REBORN
			end
			player.ze2.injoinqueue = false
			player.ze2.outofgame = false
			player.ze2.respawntics = 0
			player.ze2.zombie_type = "normal"
			player.ze2.next_zombie_type = nil
			player.ze2.damagefromplayer = 0

			for i, v in ipairs(player.ze2.recent_attackers) do
				player.ze2.recent_attackers[i] = nil
			end

			for i, v in ipairs(player.ze2.purchased) do
				player.ze2.purchased[i] = nil
			end
		end
	end
end

addHook("MapLoad", MapLoad)