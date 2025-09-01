ZE2.PregameMenuDef = {
	[1] = function(player, cmd)
		local buttons = cmd.buttons
		
		local left = cmd.sidemove < -40
		local right = cmd.sidemove > 40
		local skincount = #ZE2.getSkinNames(player, true) + 1
		local selection_name = ZE2.getSkinNames(player, true)[player.ze2.charselect_selection] or "sonic"
		local pregamemenu_type = player.ze2.pregamemenu_type
		
		-- Pressed forward to go to main menu
		ZE2:TryBooleanAction(player, {
			condition = cmd.forwardmove > 40,
			var = "pregamemenu_forwardpressed",
			action = function()
				player.ze2.pregamemenu_intopmenu = true
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
				player.ze2.charselect_prevselection = player.ze2.charselect_selection 
				if player.ze2.charselect_selection - 1 > 0 then
					player.ze2.charselect_selection = $ - 1
				else	
					player.ze2.charselect_selection = skincount - 1			
				end
				S_StartSound(nil, sfx_s3kb7, player)
				player.ze2.charselect_selection_anim = 0
			end
		}, true)
		
		-- Pressed right in character select
		ZE2:TryBooleanAction(player, {
			condition = right,
			var = "pregamemenu_rightpressed",
			action = function()
				player.ze2.charselect_prevselection = player.ze2.charselect_selection 
				if player.ze2.charselect_selection + 1 < skincount then
					player.ze2.charselect_selection = $ + 1
				else
					player.ze2.charselect_selection = 1
				end
				S_StartSound(nil, sfx_s3kb7, player)
				player.ze2.charselect_selection_anim = 0
			end
		}, true)
	end,
	[2] = function(player, cmd)
		if player.ze2.team ~= 1 then return end -- not risking it
	
		local buttons = cmd.buttons
		
		-- Forward Press
		ZE2:TryBooleanAction(player, {
			condition = (cmd.forwardmove > 40),
			var = "pregamemenu_forwardpressed",
			action = function()
				if (player.ze2.shop_selection - 1 <= 0) then 
					player.ze2.pregamemenu_intopmenu = true -- Return to top menu
				else 
					player.ze2.shop_selection = $ - 1 
					S_StartSound(nil, sfx_menu1, player)
				end
			end,
		}, true)
		
		-- Backwards Press
		ZE2:TryBooleanAction(player, {
			condition = (cmd.forwardmove < -40),
			var = "pregamemenu_backwardspressed",
			action = function()			
				S_StartSound(nil, sfx_menu1, player)
				
				if player.ze2.shop_selection + 1 > #ZE2.Survivor_ShopList
					player.ze2.shop_selection = #ZE2.Survivor_ShopList
				else
				   player.ze2.shop_selection = $ + 1
				end
			end,
		}, true)
		
		-- Jump Press (Buy Item)
		ZE2:TryBooleanAction(player, {
			condition = (buttons & BT_JUMP),
			var = "pregamemenu_jumppressed",
			action = function()		
				local shoplistindex = ZE2.Survivor_ShopList[player.ze2.shop_selection]
				if shoplistindex then
					local shopdef = ZE2.NumToShopDef(shoplistindex.shopdefid)
					local price = shopdef.price
					local enoughrubies = (player.ze2.cash - price) >= 0

					if not shoplistindex.sold then
						if enoughrubies then
							if shopdef.buyfunc and shopdef.buyfunc(player) == false then
								return
							end
							
							if shopdef.iteminfo then
								if ZE2:GiveItem(player, shopdef.iteminfo, nil) then
									player.ze2.cash = $ - price
									S_StartSound(nil, sfx_strpst, player)
									shoplistindex.sold = true
								end
							else
								player.ze2.cash = $ - price
								S_StartSound(nil, sfx_strpst, player)
								shoplistindex.sold = true
							end
						else
							S_StartSound(nil, sfx_lose, player)
						end
					else
						S_StartSound(nil, sfx_lose, player)
					end			
				end
			end,
		}, true)
		
		-- Spin Press (Exit Shop Menu)
		ZE2:TryBooleanAction(player, {
			condition = (buttons & BT_SPIN),
			var = "pregamemenu_spinpressed",
			action = function()
				player.ze2.pregamemenu_intopmenu = true -- Return to top menu
				player.ze2.shop_selection = 1
			end
		}, true)
	end
}

addHook("MapLoad", function()
	for player in players.iterate do
		if not player.spectator then
			player.ze2.pregamemenu_active = true
		end
	end
end)

ZE2.pickcharinselect = function(player, skinname)
	local pmo = player.mo

	player.ze2.pregamemenu_active = false
	
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
			player.ze2.pregamemenu_active = false
			player.pflags = $ &~PF_INVIS
		end
		
		player.ze2.charselect_selection_anim = $ or 0
		--if ZE2.round_active then return end 
		
		local cmd = player.cmd
		local buttons = cmd.buttons
		
		local left = cmd.sidemove < -40
		local right = cmd.sidemove > 40
		local skincount = #ZE2.getSkinNames(player, true) + 1
		local selection_name = ZE2.getSkinNames(player, true)[player.ze2.charselect_selection] or "sonic"
		local pregamemenu_type = player.ze2.pregamemenu_type

		if player.ze2.pregamemenu_active then
			if not ZE2.round_active then
				--player.pflags = $|PF_FULLSTASIS|PF_INVIS
				
				--buttons = 0
				cmd.angleturn = 0
				cmd.aiming = 0
			end
			
			if not player.ze2.pregamemenu_intopmenu then
				if ZE2.PregameMenuDef[pregamemenu_type] then
					ZE2.PregameMenuDef[pregamemenu_type](player, cmd)
				end
			else
				ZE2:TryBooleanAction(player, {
					condition = cmd.forwardmove < -40,
					var = "pregamemenu_backwardspressed",
					action = function()
						player.ze2.pregamemenu_intopmenu = false
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = left,
					var = "pregamemenu_leftpressed",
					action = function()
						if player.ze2.pregamemenu_type ~= 1 then
							player.ze2.pregamemenu_lasttype = player.ze2.pregamemenu_type
							player.ze2.pregamemenu_type = 1
							player.ze2.pregamemenu_intopmenuanim = player.ze2.pregamemenu_intopmenuanim_max
						end
						
						--print("Character Select Menu")
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = right,
					var = "pregamemenu_rightpressed",
					action = function()
						if player.ze2.pregamemenu_type ~= 2 then
							player.ze2.pregamemenu_lasttype = player.ze2.pregamemenu_type
							player.ze2.pregamemenu_type = 2
							player.ze2.pregamemenu_intopmenuanim = player.ze2.pregamemenu_intopmenuanim_max
						end
						
						--print("Shop Menu")
					end
				}, true)
			end
		elseif ZE2.pregame_timeleft then
			ZE2:TryBooleanAction(player, {
				condition = buttons & BT_SPIN,
				var = "pregamemenu_spinpressed",
				action = function()
					player.ze2.pregamemenu_lasttype = 1
					player.ze2.pregamemenu_type = 1
					player.ze2.pregamemenu_active = true
					player.ze2.pregamemenu_intopmenu = false
				end
			}, true)
		end
		
		if ZE2.pregame_timeleft 
		or (ZE2.zombie_releasetime and player.ze2.team == 2) then
			player.pflags = $|PF_FULLSTASIS|PF_INVIS
			
			buttons = 0
			--cmd.angleturn = 0
			--cmd.aiming = 0
		end
		
		if player.ze2.pregamemenu_intopmenuanim then
			player.ze2.pregamemenu_intopmenuanim = $ - 1
		end
		
		if player.ze2.charselect_selection_anim < (TICRATE/2) + 1 then
			player.ze2.charselect_selection_anim = $ + 1
		end

		if player.ze2.charselect_selection == nil or player.ze2.charselect_selection <= 0 then
			player.ze2.charselect_selection = 1
		elseif player.ze2.charselect_selection > skincount then
			player.ze2.charselect_selection = skincount
		end
	end
end)


addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 return end
	
	player.ze2.charselect_selection = 1

	if not ZE2.round_active then 
		-- ermm... dont pregame menu when spectating!!
		if not player.spectator then
			player.ze2.pregamemenu_active = true
		end
	end
	
	player.ze2.pregamemenu_intopmenu = false
	player.ze2.pregamemenu_type = 1	
		
	player.ze2.charselect_prevselection = 1
	player.ze2.charselect_selection_anim = (TICRATE/2) + 1 
end)	