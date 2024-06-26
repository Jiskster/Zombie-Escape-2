ZE2.charselect_waittime = TICRATE*5

addHook("MapLoad", function()
	for player in players.iterate do
		player["ze2_info"].charselect_choosing = true
	end
end)

ZE2.pickcharinselect = function(player, skinname)
	local pmo = player.mo

	player["ze2_info"].charselect_choosing = false
	
	if R_SkinUsable(player, skinname) then
		R_SetPlayerSkin(player, skinname)
	else
		R_SetPlayerSkin(player, "sonic")	
	end
	
	ZE2.ResetPlayer(player)
	--S_StartSound(nil, sfx_strpst, player)
	
	P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
	
	pmo.flags2 = $ & ~MF2_DONTDRAW
	player.pflags = $ & ~PF_INVIS
end

addHook("PreThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	for player in players.iterate do
		if ZE2.round_active then
			player["ze2_info"].charselect_choosing = false
		end

		if player.mo and player.mo.valid then
			player["ze2_info"].charselect_selection_anim = $ or 0
			if ZE2.round_active then return end 
			
			local cmd = player.cmd
			local buttons = cmd.buttons
			
			local left = cmd.sidemove < -40
			local right = cmd.sidemove > 40
			local skincount = #ZE2.getSkinNames(player, true) + 1
			local selection_name = ZE2.getSkinNames(player, true)[player["ze2_info"].charselect_selection] or "sonic"
			
			if (buttons & BT_JUMP) and player["ze2_info"].charselect_choosing then -- and leveltime > ZE2.charselect_waittime
				player["ze2_info"].charselect_hold = $ + 1
				
				if player["ze2_info"].charselect_hold >= TICRATE then
					ZE2.pickcharinselect(player,selection_name)
					player["ze2_info"].charselect_hold = 0
					buttons = 0 -- prevents random jumps when spawning
				end
			else
				player["ze2_info"].charselect_hold = 0
			end
			
			if not ZE2.round_active and player["ze2_info"].charselect_choosing then -- Stay Still while you're choosing and have not chosen
				player.pflags = $|PF_FULLSTASIS|PF_INVIS
				
				buttons = 0
				cmd.angleturn = 0
				cmd.aiming = 0
			end
			
			if player["ze2_info"].charselect_selection_anim < (TICRATE/2) + 1 then
				player["ze2_info"].charselect_selection_anim = $ + 1
			end


			if player["ze2_info"].charselect_selection == nil or player["ze2_info"].charselect_selection <= 0 then
				player["ze2_info"].charselect_selection = 1
			elseif player["ze2_info"].charselect_selection > skincount then
				player["ze2_info"].charselect_selection = skincount
			end
			
			if player["ze2_info"].charselect_choosing then
				if left then
					if not player["ze2_info"].charselect_leftpressed then
						player["ze2_info"].charselect_prevselection = player["ze2_info"].charselect_selection 
						if player["ze2_info"].charselect_selection - 1 > 0 then
							player["ze2_info"].charselect_selection = $ - 1
						else	
							player["ze2_info"].charselect_selection = skincount - 1			
						end
						S_StartSound(nil, sfx_s3kb7, player)
						player["ze2_info"].charselect_selection_anim = 0
					end
					player["ze2_info"].charselect_leftpressed = true
				else
					player["ze2_info"].charselect_leftpressed = false
				end
				
				
				if right then
					if not player["ze2_info"].charselect_rightpressed then
						player["ze2_info"].charselect_prevselection = player["ze2_info"].charselect_selection 
						if player["ze2_info"].charselect_selection + 1 < skincount then
							player["ze2_info"].charselect_selection = $ + 1
						else
							player["ze2_info"].charselect_selection = 1
						end
						S_StartSound(nil, sfx_s3kb7, player)
						player["ze2_info"].charselect_selection_anim = 0
					end
					player["ze2_info"].charselect_rightpressed = true
				else
					player["ze2_info"].charselect_rightpressed = false
				end
			end
		end
	end
end)


addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 return end
	
	player["ze2_info"].charselect_selection = 1

	if not ZE2.round_active then 
		player["ze2_info"].charselect_choosing = true
	end

	player["ze2_info"].charselect_prevselection = 1
	player["ze2_info"].charselect_selection_anim = (TICRATE/2) + 1 
	player["ze2_info"].charselect_hold = 0
end)	