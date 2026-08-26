local countdown_sfx = {
	[20] = sfx_z20s,
	[10] = sfx_cten,
	[9] = sfx_cnin,
	[8] = sfx_ceig,
	[7] = sfx_csev,
	[6] = sfx_csix,
	[5] = sfx_cfiv,
	[4] = sfx_cfou,
	[3] = sfx_cthr,
	[2] = sfx_ctwo,
	[1] = sfx_cone,
}

local function getNewZombie(wtable)
	local total = 0
	local found = false

	for i,tb in ipairs(wtable) do
		total = $ + tb.weight
	end

	local rng = P_RandomRange(0, total)

	-- While loop just in case.
	while not found do
		for i,tb in ipairs(wtable) do
			if rng < tb.weight then
				found = true
				return tb.player
			end

			rng = $ - tb.weight
		end
	end
end

local gamestatefuncs = {}

gamestatefuncs[ZE2.GS_PREGAME] = function()
	local game = ZE2.Game
	
	if game.active then
		return end;
	
	game.active = true
	S_StartSound(nil, sfx_rstart)
	local playercount = ZE2.CountPlayers("ingame")
	local denominator = 4*FU
	local amountchoosing = FixedDiv(playercount*FU, denominator) -- lmao
	local pickingtable = {}

	amountchoosing = FixedCeil($)/FU -- simpler than ze1's rng for sure.

	for player in players.iterate do
		if player.spectator then continue end

		-- Put player in zombie picking list.
		table.insert(pickingtable, {
			player = player;
			weight = player.ze2.karma;
		})
		
		-- Code to assign a character slot to players that have not selected a chracter yet.
		if (player.mo and player.mo.valid) then
			if not player.ze2.selected_character then
				-- NOTE: Indexing ZE2.CharacterSlots is the same as ZE2.registered_skins[i]

				local gotslot = false
				for i,slot in ipairs(ZE2.CharacterSlots) do
					if slot.count < slot.max then
						local skinname = ZE2.registered_skins[i]
						slot.count = $ + 1

						player.ze2.selected_character = skinname
						ZE2.switchCharacter(player, skinname)
						ZE2.setConfigInventory(player, skinname)
						ZE2.resetPlayerHealth(player, skinname)

						gotslot = true
						break
					end
				end

				-- If somehow all slots are full, give a random one space.
				if not gotslot then
					local charcount = #ZE2.CharacterSlots

					local rng = P_RandomRange(1, charcount)
					local skinname = ZE2.registered_skins[rng]
					local chosenslot = ZE2.CharacterSlots[rng]
					chosenslot.max = $ + 1 -- increase limit of the slot just for you :)

					player.ze2.selected_character = skinname
					ZE2.switchCharacter(player, skinname)
					ZE2.setConfigInventory(player, skinname)
					ZE2.resetPlayerHealth(player, skinname)

					chosenslot.count = $ + 1 -- then increase the count, like if you really got it
				end
			end
		end
	end

	-- Fisher-Yates shuffle algorithm
	for i = #pickingtable, 2, -1 do
		local j = P_RandomRange(1, i)
		pickingtable[i], pickingtable[j] = pickingtable[j], pickingtable[i]
	end

	if playercount > 1 and #pickingtable then
		local alphaspawned = false

		for i=1,amountchoosing do
			local newztype
			local player = getNewZombie(pickingtable)

			for n=1,#pickingtable do
				if pickingtable[n]
				and pickingtable[n].player == player then
					table.remove(pickingtable, n)
				end
			end

			if not alphaspawned then
				newztype = "alpha"
				alphaspawned = true
			elseif P_RandomChance(FU/8) then
				newztype = "alpha"
			end

			ZE2.ZombifyPlayer(player, newztype)
			ZE2.PlayZombieSound(player, true)

			player.ze2.karma = max(1, $ / 2)

			if ZE2.choosenotice.value then
				print(string.format("%s%s%s has risen from the dead!", "\x83", "\x83", player.name))
			end

			if player.mo and player.mo.valid then
				player.mo.team = 2
			end
		end
	end

	if mapheaderinfo[gamemap].ze2_zombiereleasetime then
		local input = tonumber(mapheaderinfo[gamemap].ze2_zombiereleasetime)

		if input ~= nil then
			game.releasetime = input*TICRATE
		else
			game.releasetime = 10*TICRATE -- TODO: Un magic-number this
		end
	else
		game.releasetime = 10*TICRATE
	end
	
	return game.time_limit
end

gamestatefuncs[ZE2.GS_GAME] = function()
	local game = ZE2.Game
	
	if game.ended then
		return end;
		
	ZE2:StartWin(2)
	
	return 0
end

addHook("ThinkFrame", function()
	if gamestate ~= GS_LEVEL then
		return end;
		
	local game = ZE2.Game

	if game.state_tics then
		game.state_tics = max(0, $ - 1)
		
		if not game.state_tics then
			local maxstates = #game.state_list
			
			if gamestatefuncs and gamestatefuncs[game.state] then
				local newtime = gamestatefuncs[game.state]()
				
				if newtime ~= nil then
					game.state_tics = newtime
				end
			end
			
			if game.state + 1 <= maxstates then
				game.state = $ + 1
			end
		end
	end
	
	if game.releasetime then
		game.releasetime = max(0, $ - 1)
		
		if not game.releasetime then
			S_StartSoundAtVolume(nil, sfx_zmrel, 128)
		end
	end
	
	if game.ended then
		game.win_tics = $ + 1
	end

	if game.state == ZE2.GS_PREGAME then
		local state_tics = game.state_tics
		local cd_tic = (state_tics-TICRATE)/TICRATE -- For the countdown not to be behind/ahead
		
		-- Countdown Voice
		if (state_tics % TICRATE) == 0 then
			if countdown_sfx[cd_tic] then
				S_StartSound(nil, countdown_sfx[cd_tic])
			end
		end
	end
end)