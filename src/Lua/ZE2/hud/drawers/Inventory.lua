local invpos_y = 185*FU
local empty_patch_name = "BLANKIND"
local slot_gap = 20*FU
	
local function PositionSlot(index, slot, slot_count, slot_gap)
	-- Center Slot Position
	slot.x = $ - FixedMul(slot.patch.width*FU, slot.scale)/2
	slot.y = $ - FixedMul(slot.patch.height*FU, slot.scale)/2
	
	-- Add from the right
	slot.x = $ + (slot_gap) * (index-1)

	-- Center whole inventory
	slot.x = $ - (slot_gap/2) * (slot_count-1)
end

return "Inventory", function(v, player)
	if ZE2.game_ended then 
		return 
	end

	if player.ze2.ghostmode then 
		return
	end
	
	-- if in pregame, dont display
	if player.ze2.pregamemenu_type ~= 3 then -- Show inventory in 
		if player.ze2.pregamemenu_active and ZE2.pregame_timeleft then 
			return 
		end
	end

	-- if player is zombie and hasn't been released, dont display inventory!
	if ZE2.zombie_releasetime and player.ze2.team == 2 then 
		return 
	end 

	if player and not player.mo then 
		return 
	end
	
	local slot_count = ZE2:FetchInventoryLimit(player)
	
	local selected_slot = {
		x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
		y = invpos_y,
		scale = FRACUNIT,
		patch = v.cachePatch("CURWEAP"),
		flags = V_SNAPTOBOTTOM,
	}
	
	for i=1, slot_count do
		local selection = player.ze2.inventory_selection
		local empty_patch = v.cachePatch(empty_patch_name)
		
		local slot = {
			x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
			y = invpos_y,
			scale = FRACUNIT,
			patch = empty_patch,
			flags = V_SNAPTOBOTTOM,
		}
		
		local slot_bg = {
			x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
			y = invpos_y,
			scale = FRACUNIT,
			patch = empty_patch,
			flags = V_SNAPTOBOTTOM,
		}
		
		local reload_square = ZE2:Copy(slot)
		local firerate_square = ZE2:Copy(slot)
		
		local iteminfo = ZE2:FetchInventorySlot(player, i)
		local item_icon = ZE2:GetItemInfoIndex(iteminfo, "icon", player.mo.skin)
		local item_ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", player.mo.skin)
		local item_count = ZE2:GetItemInfoIndex(iteminfo, "count", player.mo.skin)
		local item_iconscale = ZE2:GetItemInfoIndex(iteminfo, "iconscale", player.mo.skin)
		local item_reload_time = ZE2:GetItemInfoIndex(iteminfo, "reload_time", player.mo.skin)
		local item_firerate = ZE2:GetItemInfoIndex(iteminfo, "firerate", player.mo.skin)
		local item_firerate_left = ZE2:GetItemInfoIndex(iteminfo, "firerate_left", player.mo.skin)
		
		if item_iconscale then
			slot.scale = item_iconscale
		end
		
		if item_icon then
			slot.patch = v.cachePatch(item_icon)
		end
		
		if selection == i then
			PositionSlot(i, selected_slot, slot_count, slot_gap)
			
			v.drawScaled(
				selected_slot.x,
				selected_slot.y,
				selected_slot.scale,
				selected_slot.patch,
				selected_slot.flags
			)
		end
		
		PositionSlot(i, slot, slot_count, slot_gap)
		PositionSlot(i, slot_bg, slot_count, slot_gap)
		
		if slot.patch ~= empty_patch then
			v.drawScaled(
				slot_bg.x,
				slot_bg.y,
				slot_bg.scale,
				slot_bg.patch,
				slot_bg.flags
			)
		end
		
		v.drawScaled(
			slot.x,
			slot.y,
			slot.scale,
			slot.patch,
			slot.flags
		)
		
		-- [Reload Animation] -- 
		if selection == i and player.ze2.reload > 0 then
			reload_square.scale = FU
			reload_square.patch = v.cachePatch("Z_GREENSQUARE")
			
			if item_reload_time then
				reload_square.scale = FU - FixedDiv(player.ze2.reload*FU, item_reload_time*FU)
			end
			
			PositionSlot(i, reload_square, slot_count, slot_gap)
			
			v.drawScaled(
				reload_square.x,
				reload_square.y,
				reload_square.scale,
				reload_square.patch,
				reload_square.flags|V_50TRANS,
				v.getColormap(nil, SKINCOLOR_WHITE)
			)
		end
		
		-- [Firing Animation] --
		if item_firerate_left and item_firerate then
			firerate_square.scale = FixedDiv(item_firerate_left*FU, item_firerate*FU)
			firerate_square.patch = v.cachePatch("Z_GREENSQUARE")
			
			PositionSlot(i, firerate_square, slot_count, slot_gap)
			
			v.drawScaled(
				firerate_square.x,
				firerate_square.y,
				firerate_square.scale,
				firerate_square.patch,
				firerate_square.flags|V_50TRANS,
				v.getColormap(nil, SKINCOLOR_YELLOW)
			)
		end
		
		do -- [Draw Ammo/Item Count] -- 
			local xoffset = 16*FU + 1*FU
			local yoffset = 8*FU + 2*FU
			local extraflags = 0
			local reloading = player.ze2.reload > 0
			local text

			if item_ammo ~= nil then
				text = item_ammo
				extraflags = V_SKYMAP
				
				if item_ammo <= 0 then
					-- Flicker color.
					if ((leveltime/4) % 2) == 0 then
						extraflags = V_REDMAP
					end
				end
					
				if selection == i then
					if reloading then
						extraflags = V_50TRANS
						
						-- Flicker color but not transparency.
						if ((leveltime/4) % 2) == 0 then
							extraflags = V_50TRANS|V_REDMAP
						end
					end
				end
			elseif item_count ~= nil then
				text = item_count
			end
			
			if text ~= nil then
				v.drawString(slot.x + xoffset, slot.y + yoffset, text, slot.flags|extraflags, "thin-fixed-right")
			end
		end
	end
	
	-- Item info.
	
	local item = ZE2:FetchInventorySlot(player)
	local item_color = ZE2:GetItemInfoIndex(item, "color", player.mo.skin) or SKINCOLOR_WHITE
	local item_name = ZE2:GetItemInfoIndex(item, "displayname", player.mo.skin) or "EMPTY"
	
	customhud.CustomFontString(v, 160*FU, invpos_y-20*FU, item_name, "TNYFC", 
	(V_SNAPTOBOTTOM), "center" , FRACUNIT, item_color)	
end