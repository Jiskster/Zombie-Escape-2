local cmd = player.cmd
		
if not player.ze2.zombie_inventory or not player.ze2.zombie_inventory_limit then
	ZE2.SetZCinventory(player)
end

if player.playerstate ~= PST_DEAD then
	if #ZE2:FetchInventory(player) > ZE2:FetchInventoryLimit(player) then
		table.remove(ZE2:FetchInventory(player),#ZE2:FetchInventory(player))
	end

	if player.ze2.inventory_selection > ZE2:FetchInventoryLimit(player) then
		player.ze2.inventory_selection = ZE2:FetchInventoryLimit(player)
	end
end

if player and not player.mo then return end -- to proceed... BE REAL!!!

-- decrement
if player.ze2.weapondelay then
	player.ze2.weapondelay = $ - 1
end

if player.ze2.reload and ZE2:FetchInventorySlot(player) then
	local skin = player.mo.skin
	local iteminfo = ZE2:FetchInventorySlot(player)
	local ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin)
	local max_ammo = ZE2:GetItemInfoIndex(iteminfo, "max_ammo", skin)
	
	player.ze2.reload = $ - 1
	
	if player.ze2.reload <= 0 then
		ZE2:SetItemInfoIndex(iteminfo, "ammo", max_ammo, skin)
		S_StartSound(player.mo, sfx_z_rel2)
	end
end

if not ZE2.game_ended and not player.ze2.ghostmode and not ZE2.pregame_timeleft then 
	if not player.ze2.pregamemenu_active then
		-- Next Weapon
		ZE2:TryBooleanAction(player, {
			condition = cmd.buttons & BT_WEAPONPREV,
			var = "weaponprev_pressed",
			action = function()
				if player.ze2.inventory_selection - 1 <= 0 then
					player.ze2.inventory_selection = ZE2:FetchInventoryLimit(player)
				else
					player.ze2.inventory_selection = $ - 1
				end
				
				S_StartSound(nil,sfx_mnu1a,player)
				
				player.ze2.reload = 0
			end
		}, true)

		-- Previous Weapon
		ZE2:TryBooleanAction(player, {
			condition = cmd.buttons & BT_WEAPONNEXT,
			var = "weaponnext_pressed",
			action = function()
				if player.ze2.inventory_selection + 1 > ZE2:FetchInventoryLimit(player) then
					player.ze2.inventory_selection = 1
				else
					player.ze2.inventory_selection = $ + 1
				end

				S_StartSound(nil,sfx_mnu1a,player)
				
				player.ze2.reload = 0
			end
		}, true)
		
		-- Number Key Weapon Swap (Pro Controls)
		if cmd.buttons & BT_WEAPONMASK then
			-- Dont do if on same slot as selected.
			if not ((cmd.buttons & BT_WEAPONMASK) == (player.ze2.inventory_selection)) then 
				if cmd.buttons & BT_WEAPONMASK <= ZE2:FetchInventoryLimit(player) then
					player.ze2.inventory_selection = cmd.buttons & BT_WEAPONMASK
					
					S_StartSound(nil,sfx_mnu1a,player)
					
					player.ze2.reload = 0
				end
			end
		end
		
		-- Reload
		ZE2:TryBooleanAction(player, {
			condition = cmd.buttons & BT_FIRENORMAL,
			var = "reload_pressed",
			action = function()
				ZE2.DoPlayerReload(player)
			end
		}, true)
		
		-- Fire
		ZE2:TryBooleanAction(player, {
			condition = cmd.buttons & BT_ATTACK,
			var = "fire_pressed",
			action = function()
				player.ze2.await_fire = true
			end
		}, true)
	end
	
	-- try shoot
	local iteminfo = ZE2:FetchInventorySlot(player)
	local skin = player.mo.skin
	
	if (cmd.buttons & BT_ATTACK) and not player.ze2.weapondelay and not player.ze2.reload
	and iteminfo and player.playerstate ~= PST_DEAD and not player.ze2.shop_open 
	and (player.ze2.await_fire or ZE2:GetItemInfoIndex(iteminfo, "autouse", skin))
	and not iteminfo.firerate_left and not (ZE2.zombie_releasetime and player.ze2.team == 2) then
		local ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin)
		local max_ammo = ZE2:GetItemInfoIndex(iteminfo, "max_ammo", skin)
		local count = ZE2:GetItemInfoIndex(iteminfo, "count", skin)
		local limited = ZE2:GetItemInfoIndex(iteminfo, "limited", skin)
		local firerate = ZE2:GetItemInfoIndex(iteminfo, "firerate", skin)
		local itemdelay = ZE2:GetItemInfoIndex(iteminfo, "itemdelay", skin)
		
		-- If theres no ammo, dont fire. 
		-- (Items with no ammo property can pass this check 100%)
		if ammo ~= nil and ammo <= 0 and not player.ze2.reload then
			ZE2.DoPlayerReload(player)
		else
			if ammo ~= nil and max_ammo and ammo > 0 then
				ZE2:SetItemInfoIndex(iteminfo, "ammo", ammo - 1, skin)
				ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin) -- get updated ammo
				
				-- Auto Reload
				if ammo <= 0 then
					ZE2.DoPlayerReload(player)
				end
			end
		
			ZE2.DoPlayerFire(player, iteminfo)

			player.ze2.weapondelay = itemdelay
			
			if firerate then
				ZE2:SetItemInfoIndex(iteminfo, "firerate_left", firerate, skin)
			end
			
			player.ze2.await_fire = false
			
			if count ~= nil and limited == true then
				if count > 0  then
					ZE2:SetItemInfoIndex(iteminfo, "count", count - 1, skin)
				end
			end
		end
	end	
	
	-- clear items below 0 count
	if ZE2:FetchInventoryLimit(player) and type(ZE2:FetchInventoryLimit(player)) == "number" then
		for i=1,ZE2:FetchInventoryLimit(player) do
			local slot = ZE2:FetchInventorySlot(player, i)
			
			if slot then
				if slot.limited and slot.count <= 0 then
					table.remove(ZE2:FetchInventory(player), i)
				end
				
				if slot.firerate_left then
					slot.firerate_left = $ - 1
				end
			end
		end
	end
end	

player.ze2.lower_hud_offset = 0