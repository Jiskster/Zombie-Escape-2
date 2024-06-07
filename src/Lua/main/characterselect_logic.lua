ZE2.charselect_waittime = TICRATE*5
ZE2.pickcharinselect = function(player, skinname)
	player.choosing = false
	player.chosecharacter = true
	
	if R_SkinUsable(player, skinname) then
		R_SetPlayerSkin(player, skinname)
	else
		R_SetPlayerSkin(player, "sonic")	
	end
	
	ZE2.ResetPlayer(player)
	S_StartSound(nil, sfx_strpst, player)
end

addHook("PreThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	for player in players.iterate do
		if player.mo and player.mo.valid then
			player.selection_anim = $ or 0
			if ZE2.round_active then return end 
			
			local cmd = player.cmd
			local buttons = cmd.buttons
			local left = cmd.sidemove < -40
			local right = cmd.sidemove > 40
			local skincount = #ZE2.getSkinNames(player, true) + 1
			local selection_name = ZE2.getSkinNames(player, true)[player.selection] or "sonic"
			
			
			if (cmd.forwardmove > 40) and player.choosing and not player.chosecharacter 
			and leveltime > ZE2.charselect_waittime then
				ZE2.pickcharinselect(player,selection_name)
			end
			
			if ZE2.round_active then
				player.choosing = false
				player.chosecharacter = true
			end
			
			if not ZE2.round_active and not player.choosing and not player.chosecharacter then -- Where's your stats?
				player.choosing = true
				player.chosecharacter = false
				player.selection = 1		
				player.prevselection = 1
				player.selection_anim = (TICRATE/2) + 1 
			elseif not ZE2.round_active and player.choosing and not player.chosecharacter then -- Stay Still while you're choosing and have not chosen
				player.pflags = $|PF_FULLSTASIS
			
				buttons = 0
			end
			
			if player.selection_anim < (TICRATE/2) + 1 then
				player.selection_anim = $ + 1
			end


			if player.selection == nil or player.selection <= 0 then
				player.selection = 1
			elseif player.selection > skincount then
				player.selection = skincount
			end
			
			if player.choosing and not player.chosecharacter then
				if left then
					if not player.pressedleft then
						player.prevselection = player.selection 
						if player.selection - 1 > 0 then
							player.selection = $ - 1
						else	
							player.selection = skincount - 1			
						end
						S_StartSound(nil, sfx_s3kb7, player)
						player.selection_anim = 0
					end
					player.pressedleft = true
				else
					player.pressedleft = false
				end
				
				
				if right then
					if not player.pressedright then
						player.prevselection = player.selection 
						if player.selection + 1 < skincount then
							player.selection = $ + 1
						else
							player.selection = 1
						end
						S_StartSound(nil, sfx_s3kb7, player)
						player.selection_anim = 0
					end
					player.pressedright = true
				else
					player.pressedright = false
				end
			end
			
		end
	end
end)


addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 return end
	
	player.selection = 1
	if not ZE2.round_active then 
		player.choosing = true
		player.chosecharacter = false
	end

	player.prevselection = 1
	player.selection_anim = (TICRATE/2) + 1 
end)	