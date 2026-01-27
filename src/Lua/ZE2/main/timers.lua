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

local function ForceEndAllCharacterSelection()
	for player in players.iterate do
		if player.spectator then continue end
		
		if player.ze2.pregamemenu_active == true then -- get tf out of character select
			local selection_name = ZE2.getSkinNames(player, true)[player.ze2.charselect_selection]
			ZE2.switchCharacter(player,selection_name) 
		end
	end
end

local function CheckGameForWinRing()
	local haswinring = false
	local winring_doomednum = mobjinfo[MT_CRRING].doomednum
	
	for thing in mapthings.iterate do 
		if thing.type == winring_doomednum then
			haswinring = true
			break
		end
	end
	
	if not haswinring then
		print("Mapnum " .. gamemap .. " doesn't have an exit. Forcing zombie win.")
		ForceEndAllCharacterSelection()
		ZE2:StartWin(2)
		return false
	end
	
	return true
end

function ZE2:StartWin(team, fromring)
	self.game_ended = true
	self.team_won = team
	
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
				
				if player.xSlinger.team ~= team then
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
	
	local cash_award = ZE2.PlayerCount()*cash_base_award
	
	for player in players.iterate do
		if player.spectator then continue end
		if player.xSlinger.team ~= team then continue end
		
		if team == 1 then
			player.ze2.karma = max(1, $ / 2)
		end
		
		ZE2:GivePlayerCash(player, cash_award)
		S_StartSound(player.mo, sfx_rbyhit)
		CONS_Printf(player, "\x83 + Awarded "..cash_award.." cash awarded for winning!")
	end
	
	P_StartQuake(24*FRACUNIT, 3*TICRATE)
end

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

addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if ZE2.pregame_timeleft then
		ZE2.pregame_timeleft = $ - 1
	end
	
	if ZE2.zombie_releasetime then
		ZE2.zombie_releasetime = $ - 1
		
		if not ZE2.zombie_releasetime then
			S_StartSoundAtVolume(nil, sfx_zmrel, 128)
		end
	end
	
	local count_timecalculate = (ZE2.pregame_timeleft-TICRATE)/TICRATE -- For the countdown not to be behind/ahead
	
	if not ZE2.pregame_timeleft and not ZE2.round_active and not ZE2.game_ended then
		if not CheckGameForWinRing() then return end
		
		ZE2.round_active = true
		S_StartSound(nil, sfx_rstart)
		local playercount = ZE2.PlayerCount()
		local denominator = FixedDiv(33*FU,10*FU) -- 3.3
		local amountchoosing = FixedDiv(playercount*FU, denominator) -- lmao
		local pickingtable = {}
		
		amountchoosing = FixedCeil($)/FU
		
		-- simpler than ze's rng for sure.
		for player in players.iterate do
			if player.spectator then continue end
			
			if player.ze2.pregamemenu_active == true then -- get tf out of character select
				local selection_name = ZE2.getSkinNames(player, true)[player.ze2.charselect_selection]
				ZE2.switchCharacter(player,selection_name,true) 
			end
			
			-- Put player in zombie picking list.
			table.insert(pickingtable, {
				player = player;
				weight = player.ze2.karma;
			})
		end

		if playercount > 1 and #pickingtable then
			for i=1,amountchoosing do
				local player = getNewZombie(pickingtable)
				
				for n=1,#pickingtable do
					if pickingtable[n] 
					and pickingtable[n].player == player then
						table.remove(pickingtable, n)
					end
				end
				
				ZE2.ZombifyPlayer(player)
				ZE2.PlayZombieSound(player, true)
				
				player.ze2.karma = max(1, $ / 2)
				
				if ZE2.choosenotice.value then
					print(string.format("\x83\%s\x83\ has risen from the dead!",player.name))
				end
				
				player.xSlinger.team = 2
			end
		end

		if mapheaderinfo[gamemap].ze2_zombiereleasetime then
			local input = tonumber(mapheaderinfo[gamemap].ze2_zombiereleasetime)
			
			if input ~= nil then
				ZE2.zombie_releasetime = input*TICRATE
			else
				ZE2.zombie_releasetime = 10*TICRATE -- TODO: Un magic-number this
			end
		else
			ZE2.zombie_releasetime = 10*TICRATE
		end
	end
	
	if ZE2.time_limit and ZE2.game_time >= ZE2.time_limit and not (ZE2.game_ended) then
		ZE2:StartWin(1)
	end
	
	-- Countdown Voice
	if (ZE2.pregame_timeleft % TICRATE) == 0 then
		if countdown_sfx[count_timecalculate] then
			S_StartSound(nil, countdown_sfx[count_timecalculate])
		end
	end
	
	for player in players.iterate do 
		if player.mo and player.mo.valid and (ZE2.game_ended or player.xSlinger.team == 2) then
			player.powers[pw_underwater] = 0
		end
	end
	
	if ZE2.game_ended then ZE2.win_tics = $ + 1 end
	if (ZE2.round_active) and not (ZE2.game_ended) then ZE2.game_time = $ + 1 end
end)

COM_AddCommand("z_forcewin", function(player, arg1)
	local teamtowin = 1
 	if not arg1 or not tonumber(arg1) then return end
 	arg1 = tonumber(arg1)
	
	if (arg1 > 0 and arg1 < 3) then 
		ZE2:StartWin(arg1) 
	end
end,COM_ADMIN)
