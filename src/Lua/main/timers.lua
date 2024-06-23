ZE2.killwhenchosen = CV_RegisterVar({
	name = "z_killwhenchosen",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.choosenotice = CV_RegisterVar({
	name = "z_choosenotice",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killenemiesonwin = CV_RegisterVar({
	name = "z_killenemiessonwin",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killzombiesonwin = CV_RegisterVar({
	name = "z_killzombiesonwin",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

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
		ZE2:StartWin(2)
		return false
	end
	
	return true
end

function ZE2:StartWin(team)
	self.game_ended = true
	self.team_won = team
	
	if team == 1 then
		S_ChangeMusic("SWIN", false)
		mapmusname = "SWIN"
	else
		S_ChangeMusic("ZWIN", false)
		mapmusname = "ZWIN"
	end
	
	for mobj in mobjs.iterate() do
		if mobj.valid then
			if (mobj.player and mobj.player.valid and mobj.player["ze2_info"].team and 
			mobj.player["ze2_info"].team == 2 and ZE2.killzombiesonwin.value and team == 1) then
				P_KillMobj(mobj)
				continue
			end
			if (mobj.flags & MF_ENEMY) and (ZE2.killenemiesonwin.value) then
				P_KillMobj(mobj)
				continue
			end
		end
	end
	
	P_StartQuake(24*FRACUNIT, 3*TICRATE)
end

addHook("PlayerThink", function(player)
	player["ze2_info"].was_zombie = $ or false -- waszombie is to prevent repeating players
end)

addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if ZE2.pregame_timeleft then
		ZE2.pregame_timeleft = $ - 1
	end
	
	local count_timecalculate = (ZE2.pregame_timeleft-TICRATE)/TICRATE -- For the countdown not to be behind/ahead
	
	if not ZE2.pregame_timeleft and not ZE2.round_active and not ZE2.game_ended then
		if not CheckGameForWinRing() then return end
		
		ZE2.round_active = true
		S_StartSound(nil, sfx_rstart)
		local choosingnums = {}
		local amountchoosing = FixedCeil(FixedDiv(ZE2.PlayerCount()*FU,4*FU))/FU -- lmao
		
		-- simpler than ze's rng for sure.
		for player in players.iterate do
			if player.spectator then continue end
			
			if player["ze2_info"].charselect_choosing == true then -- get tf out of character select
				local selection_name = ZE2.getSkinNames(player, true)[player["ze2_info"].charselect_selection]
				ZE2.pickcharinselect(player,selection_name) 
			end
			
			if not player["ze2_info"].was_zombie then
				table.insert(choosingnums, #player)
			end
		end
		-- At this point, every player's playernum is sorted in choosingnums
		-- except for the players that were zombies last game.

		if ZE2.PlayerCount() > 1 then
			for _I_=1,amountchoosing do
				local playernumindex = P_RandomRange(1,#choosingnums)
				local playernum = choosingnums[playernumindex]
				local player = players[playernum]
				
				if ZE2.killwhenchosen.value then
					P_KillMobj(player.mo,nil,nil,DMG_INSTAKILL)
				else
					ZE2.ResetPlayer(player)
				end
				
				if ZE2.choosenotice.value then
					print(string.format("\x83\%s\x83\ has risen from the dead!",player.name))
				end
				
				player["ze2_info"].team = 2
				player["ze2_info"].was_zombie = true
				table.remove(choosingnums,playernumindex)
			end
		end

		for player in players.iterate do
			if player["ze2_info"].was_zombie and player["ze2_info"].team == 1 then
				player["ze2_info"].was_zombie = false
			end
		end
		
		choosingnums = nil -- release memory idk wtf
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
		if player.mo and player.mo.valid and (ZE2.game_ended or player["ze2_info"].team == 2) then
			player.powers[pw_underwater] = 0
		end
	end
	
	if ZE2.game_ended then ZE2.win_tics = $ + 1 end
	if (ZE2.round_active) and not (ZE2.game_ended) then ZE2.game_time = $ + 1 end
end)

addHook("MobjThinker", function(mobj)
	if ZE2.game_ended and leveltime and ZE2.win_tics >= ZE2.MapVoteStartFrame then

		mobj.flags = $ | MF_NOTHINK
		return true
	end
end)

COM_AddCommand("z_forcewin", function(player, arg1)
	local teamtowin = 1
 	if not arg1 or not tonumber(arg1) then return end
 	arg1 = tonumber(arg1)
	
	if (arg1>0 and arg1<3) then 
		ZE2:StartWin(arg1) 
	end
	
end,COM_ADMIN)
