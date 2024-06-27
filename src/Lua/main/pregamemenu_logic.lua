ZE2.PregameMenuDef = {
	[1] = function(player)
		local cmd = player.cmd
		local buttons = cmd.buttons
		
		local left = cmd.sidemove < -40
		local right = cmd.sidemove > 40
		local skincount = #ZE2.getSkinNames(player, true) + 1
		local selection_name = ZE2.getSkinNames(player, true)[player["ze2_info"].charselect_selection] or "sonic"
		local pregamemenu_type = player["ze2_info"].pregamemenu_type
		
		
		/*
		if (buttons & BT_SPIN) then -- hold button to choose character
			player["ze2_info"].charselect_hold = $ + 1
			
			if player["ze2_info"].charselect_hold >= TICRATE then
				ZE2.pickcharinselect(player,selection_name)
				player["ze2_info"].charselect_hold = 0
			end
		else
			player["ze2_info"].charselect_hold = 0
		end
		*/
		
		-- Pressed forward to go to main menu
		ZE2:TryBooleanAction(player, {
			condition = cmd.forwardmove > 40,
			var = "pregamemenu_forwardpressed",
			action = function()
				player["ze2_info"].pregamemenu_intopmenu = true
				--print("Going to top menu")
			end
		}, true)
		
		-- Pressed spin to pick character
		
		ZE2:TryBooleanAction(player, {
			condition = (buttons & BT_SPIN),
			var = "pregamemenu_spinpressed",
			action = function()
				ZE2.pickcharinselect(player,selection_name)
			end
		}, true)
		
		-- Pressed left in character select
		ZE2:TryBooleanAction(player, {
			condition = left,
			var = "pregamemenu_leftpressed",
			action = function()
				player["ze2_info"].charselect_prevselection = player["ze2_info"].charselect_selection 
				if player["ze2_info"].charselect_selection - 1 > 0 then
					player["ze2_info"].charselect_selection = $ - 1
				else	
					player["ze2_info"].charselect_selection = skincount - 1			
				end
				S_StartSound(nil, sfx_s3kb7, player)
				player["ze2_info"].charselect_selection_anim = 0
			end
		}, true)
		
		-- Pressed right in character select
		ZE2:TryBooleanAction(player, {
			condition = right,
			var = "pregamemenu_rightpressed",
			action = function()
				player["ze2_info"].charselect_prevselection = player["ze2_info"].charselect_selection 
				if player["ze2_info"].charselect_selection + 1 < skincount then
					player["ze2_info"].charselect_selection = $ + 1
				else
					player["ze2_info"].charselect_selection = 1
				end
				S_StartSound(nil, sfx_s3kb7, player)
				player["ze2_info"].charselect_selection_anim = 0
			end
		}, true)
	end,
	[2] = function(player)
	
	end
}

addHook("MapLoad", function()
	for player in players.iterate do
		player["ze2_info"].pregamemenu_active = true
	end
end)

ZE2.pickcharinselect = function(player, skinname)
	local pmo = player.mo

	player["ze2_info"].pregamemenu_active = false
	
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
		if not (player.mo and player.mo.valid) then continue end
		
		if ZE2.round_active then
			player["ze2_info"].pregamemenu_active = false
		end
		
		player["ze2_info"].charselect_selection_anim = $ or 0
		if ZE2.round_active then return end 
		
		local cmd = player.cmd
		local buttons = cmd.buttons
		
		local left = cmd.sidemove < -40
		local right = cmd.sidemove > 40
		local skincount = #ZE2.getSkinNames(player, true) + 1
		local selection_name = ZE2.getSkinNames(player, true)[player["ze2_info"].charselect_selection] or "sonic"
		local pregamemenu_type = player["ze2_info"].pregamemenu_type
		
		if player["ze2_info"].pregamemenu_active then
			if not player["ze2_info"].pregamemenu_intopmenu then
				if ZE2.PregameMenuDef[pregamemenu_type] then
					ZE2.PregameMenuDef[pregamemenu_type](player)
				end
			else
				ZE2:TryBooleanAction(player, {
					condition = cmd.forwardmove < -40,
					var = "pregamemenu_backwardspressed",
					action = function()
						player["ze2_info"].pregamemenu_intopmenu = false
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = left,
					var = "pregamemenu_leftpressed",
					action = function()
						if player["ze2_info"].pregamemenu_type ~= 1 then
							player["ze2_info"].pregamemenu_lasttype = player["ze2_info"].pregamemenu_type
							player["ze2_info"].pregamemenu_type = 1
							player["ze2_info"].pregamemenu_intopmenuanim = player["ze2_info"].pregamemenu_intopmenuanim_max
						end
						
						--print("Character Select Menu")
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = right,
					var = "pregamemenu_rightpressed",
					action = function()
						if player["ze2_info"].pregamemenu_type ~= 2 then
							player["ze2_info"].pregamemenu_lasttype = player["ze2_info"].pregamemenu_type
							player["ze2_info"].pregamemenu_type = 2
							player["ze2_info"].pregamemenu_intopmenuanim = player["ze2_info"].pregamemenu_intopmenuanim_max
						end
						
						--print("Shop Menu")
					end
				}, true)
			end
			
			if not ZE2.round_active then -- Stay Still while you're choosing and have not chosen
				player.pflags = $|PF_FULLSTASIS|PF_INVIS
				
				buttons = 0
				cmd.angleturn = 0
				cmd.aiming = 0
			end
		end
		
		if player["ze2_info"].pregamemenu_intopmenuanim then
			player["ze2_info"].pregamemenu_intopmenuanim = $ - 1
		end
		
		if player["ze2_info"].charselect_selection_anim < (TICRATE/2) + 1 then
			player["ze2_info"].charselect_selection_anim = $ + 1
		end

		if player["ze2_info"].charselect_selection == nil or player["ze2_info"].charselect_selection <= 0 then
			player["ze2_info"].charselect_selection = 1
		elseif player["ze2_info"].charselect_selection > skincount then
			player["ze2_info"].charselect_selection = skincount
		end
	end
end)


addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 return end
	
	player["ze2_info"].charselect_selection = 1

	if not ZE2.round_active then 
		player["ze2_info"].pregamemenu_active = true
	end
	
	player["ze2_info"].pregamemenu_intopmenu = false
	player["ze2_info"].pregamemenu_type = 1	
		
	player["ze2_info"].charselect_prevselection = 1
	player["ze2_info"].charselect_selection_anim = (TICRATE/2) + 1 
	player["ze2_info"].charselect_hold = 0
end)	