ZE2.inventoryhud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	if player["ze2_info"].charselect_choosing then return end
	if ZE2.game_ended then return end
	
	if player["ze2_info"].ghostmode then return end
	
	if player and not player.mo then return end
	
	local s_patch = v.cachePatch("CURWEAP")
	local cyan_patch = v.cachePatch("Z_CYANSQUARE")
	local sel = player["ze2_info"].inventory_selection
	local sel_x = 116*FU
	if sel > 1 then
		sel_x = $ + ((sel-1)*20*FU)
	end
	local sel_y = 176*FU
	
	if ZE2:FetchInventoryLimit(player) and type(ZE2:FetchInventoryLimit(player)) == "number" then
		for i=1,ZE2:FetchInventoryLimit(player) do
			local x = 116*FU
			local y = 176*FU
			local overone_xpos = ((i-1)*20)*FU
			local iconscale = FU
			local slot = ZE2:CopyInventorySlot(player, i)
			local slot_real = ZE2:FetchInventorySlot(player, i)
			
			if player["ze2_info"].shop_open then 
				y = 146*FU
				sel_y = y
			end
			local patch
			
			if i > 1 then
				x = $ + overone_xpos
			end
			
			if slot then
				if slot.icon then
					patch = v.cachePatch(slot.icon)
				else
					patch = v.cachePatch("BLANKIND")
				end
				if slot.iconscale then
					iconscale = slot.iconscale
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
				-- item count
				if slot_real.count and slot_real.limited then
					local count = tostring(slot_real.count)
					customhud.CustomFontString(v,x,y,count, "DTNYF", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CLOUDY)
					--v.drawString(x, y, tostring(slot.count), V_SNAPTOBOTTOM, "thin-fixed")
				elseif slot.ammo ~= nil then -- ammo count
					local ammo = tostring(slot_real.ammo)
					
					if slot_real.ammo then
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
		local slot = ZE2:CopyInventorySlot(player)
		local itemname = slot.displayname
		local itemcolor = slot.color or SKINCOLOR_CLOUDY
		
		customhud.CustomFontString(v,sel_x+(8*FU),sel_y-(10*FU),itemname, "TNYFC", V_SNAPTOBOTTOM, "center", FRACUNIT, itemcolor)
	else
		customhud.CustomFontString(v,sel_x+(8*FU),sel_y-(10*FU),"EMPTY", "TNYFC", V_SNAPTOBOTTOM, "center", FRACUNIT, SKINCOLOR_CLOUDY)
	end
	
	-- weapon selection 
	v.drawStretched(sel_x-(2*FU), sel_y-(2*FU), FU, FU, s_patch, V_SNAPTOBOTTOM)
	if ZE2:FetchInventorySlot(player) then
		local slot = ZE2:CopyInventorySlot(player)
		
		if player["ze2_info"].reload then
			local slotreload = ZE2:FetchInventorySlot(player).reload_time or 10
			local reload_div = FU - min(FixedDiv(player["ze2_info"].reload, slotreload),FU)
			v.drawStretched(sel_x, sel_y, reload_div, FU, cyan_patch, V_SNAPTOBOTTOM|V_50TRANS)
		elseif player["ze2_info"].weapondelay then
			local slotdelay = ZE2:FetchInventorySlot(player).firerate
			local delay_div = min(FixedDiv(player["ze2_info"].weapondelay, slotdelay),FU)
			v.drawStretched(sel_x, sel_y, delay_div, FU, cyan_patch, V_SNAPTOBOTTOM|V_50TRANS)
		end
	end
end