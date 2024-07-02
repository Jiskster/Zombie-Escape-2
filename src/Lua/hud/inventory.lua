ZE2.inventoryhud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	if player["ze2_info"].pregamemenu_active then return end
	if ZE2.game_ended then return end
	
	if player["ze2_info"].ghostmode then return end
	
	if player and not player.mo then return end
	
	local lower_hud_offset = player["ze2_info"].lower_hud_offset or 0
	
	local skin = player.mo.skin
	local s_patch = v.cachePatch("CURWEAP")
	local cyan_patch = v.cachePatch("Z_CYANSQUARE")
	local sel = player["ze2_info"].inventory_selection
	local sel_x = 116*FU
	if sel > 1 then
		sel_x = $ + ((sel-1)*20*FU)
	end
	local sel_y = (176-lower_hud_offset)*FU
	
	if ZE2:FetchInventoryLimit(player) and type(ZE2:FetchInventoryLimit(player)) == "number" then
		for i=1,ZE2:FetchInventoryLimit(player) do
			local x = 116*FU
			local y = sel_y
			local overone_xpos = ((i-1)*20)*FU
			local iconscale = FU
			local slot = ZE2:FetchInventorySlot(player, i)
			local slot_icon -- = ZE2:GetItemInfoIndex(slot, "icon", skin)
			local slot_iconscale --  = ZE2:GetItemInfoIndex(slot, "iconscale", skin)
			
			if player["ze2_info"].shop_open then 
				y = min(146, 176-lower_hud_offset)*FU
				sel_y = y
			end
			local patch
			
			if i > 1 then
				x = $ + overone_xpos
			end
			
			if slot then
				slot_icon = ZE2:GetItemInfoIndex(slot, "icon", skin)
				slot_iconscale = ZE2:GetItemInfoIndex(slot, "iconscale", skin)
				
				if slot_icon then
					patch = v.cachePatch(slot_icon)
				else
					patch = v.cachePatch("BLANKIND")
				end
				if slot_iconscale then
					iconscale = slot_iconscale
				end
			else
				patch = v.cachePatch("BLANKIND")
			end
			
			-- weapon icons
			if slot then
				v.drawStretched(x, y, iconscale, iconscale, patch, V_SNAPTOBOTTOM)
			else
				v.drawStretched(x, y, iconscale, iconscale, patch, V_SNAPTOBOTTOM|V_TRANSLUCENT)
			end

			if slot then
				local slot_count = ZE2:GetItemInfoIndex(slot, "count", skin)
				local slot_limited = ZE2:GetItemInfoIndex(slot, "limited", skin)
				local slot_ammo = ZE2:GetItemInfoIndex(slot, "ammo", skin)
				local slot_firerate = ZE2:GetItemInfoIndex(slot, "firerate", skin)
				
				if slot_firerate and slot.firerate_left then
					local div = min(FixedDiv(slot.firerate_left, slot_firerate), FU)
					v.drawStretched(x, y, div, FU, cyan_patch, V_SNAPTOBOTTOM|V_50TRANS)
				end
				
				
				
				-- item count
				if slot_count and slot_limited then
					local count = tostring(slot_count)
					customhud.CustomFontString(v,x,y,count, "DTNYF", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CLOUDY)
					--v.drawString(x, y, tostring(slot_count), V_SNAPTOBOTTOM, "thin-fixed")
				elseif slot_ammo ~= nil then -- ammo count
					local ammo = tostring(slot_ammo)
					
					if slot_ammo then
						v.drawString(x, y, ammo, V_SNAPTOBOTTOM, "thin-fixed")
						customhud.CustomFontString(v,x,y,ammo, "DTNYF", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_AQUAMARINE)
					else -- flash if no ammo
						if (leveltime/4)%2 == 0 then
							customhud.CustomFontString(v,x,y,ammo, "DTNYF", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CRIMSON)
						else
							customhud.CustomFontString(v,x,y,ammo, "DTNYF", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_AQUAMARINE)
						end
					end
				end
			end
		end
	end
	
	-- item info
	if ZE2:FetchInventorySlot(player) and ZE2:FetchInventorySlot(player).displayname then
		local slot = ZE2:FetchInventorySlot(player)
		local slot_itemname = ZE2:GetItemInfoIndex(slot, "displayname", skin)
		local slot_itemcolor = ZE2:GetItemInfoIndex(slot, "color", skin) or SKINCOLOR_CLOUDY
		
		customhud.CustomFontString(v,sel_x+(8*FU),sel_y-(10*FU),slot_itemname, "TNYFC", V_SNAPTOBOTTOM, "center", FRACUNIT, slot_itemcolor)
	else
		customhud.CustomFontString(v,sel_x+(8*FU),sel_y-(10*FU),"EMPTY", "TNYFC", V_SNAPTOBOTTOM, "center", FRACUNIT, SKINCOLOR_CLOUDY)
	end
	
	-- weapon selection 
	v.drawStretched(sel_x-(2*FU), sel_y-(2*FU), FU, FU, s_patch, V_SNAPTOBOTTOM)
	if ZE2:FetchInventorySlot(player) then
		local slot = ZE2:FetchInventorySlot(player)
		
		if player["ze2_info"].reload then
			local slotreload = ZE2:GetItemInfoIndex(slot, "reload_time", skin) or 10
			local reload_div = FU - min(FixedDiv(player["ze2_info"].reload, slotreload),FU)
			v.drawStretched(sel_x, sel_y, reload_div, FU, cyan_patch, V_SNAPTOBOTTOM|V_50TRANS)
		end
		
		if player["ze2_info"].weapondelay then
			local slotdelay = ZE2:GetItemInfoIndex(slot, "firerate", skin)
			local text = G_TicsToSeconds(player["ze2_info"].weapondelay).."."..G_TicsToCentiseconds(player["ze2_info"].weapondelay)
			customhud.CustomFontString(v,160*FU,sel_y-(16*FU),text,"TNYFC",V_SNAPTOBOTTOM|V_50TRANS,"center",FRACUNIT,SKINCOLOR_WHITE)
			
			--local delay_div = min(FixedDiv(player["ze2_info"].weapondelay, slotdelay),FU)
			--v.drawStretched(sel_x, sel_y, delay_div, FU, cyan_patch, V_SNAPTOBOTTOM|V_50TRANS)
		end
	end
end