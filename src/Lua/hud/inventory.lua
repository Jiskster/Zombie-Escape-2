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
			
			if player["ze2_info"].shop_open then 
				y = 146*FU
				sel_y = y
			end
			local patch
			
			if i > 1 then
				x = $ + overone_xpos
			end
			
			if ZE2:FetchInventory(player)[i] then
				if ZE2:FetchInventory(player)[i].icon then
					patch = v.cachePatch(ZE2:FetchInventory(player)[i].icon)
				else
					patch = v.cachePatch("BLANKIND")
				end
				if ZE2:FetchInventory(player)[i].iconscale then
					iconscale = ZE2:FetchInventory(player)[i].iconscale
				end
			else
				patch = v.cachePatch("BLANKIND")
			end
			
			-- weapon icons
			if ZE2:FetchInventory(player)[i] then
				v.drawStretched(x, y, iconscale, iconscale, patch, V_SNAPTOBOTTOM)
			else
				v.drawStretched(x, y, iconscale, iconscale, patch, V_SNAPTOBOTTOM|V_TRANSLUCENT)
			end

			if ZE2:FetchInventory(player)[i] then
				-- item count
				if ZE2:FetchInventory(player)[i].count and ZE2:FetchInventory(player)[i].limited then
					local count = tostring(ZE2:FetchInventory(player)[i].count)
					customhud.CustomFontString(v,x,y,count, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CLOUDY)
					--v.drawString(x, y, tostring(ZE2:FetchInventory(player)[i].count), V_SNAPTOBOTTOM, "thin-fixed")
				elseif ZE2:FetchInventory(player)[i].ammo ~= nil then -- ammo count
					local ammo = tostring(ZE2:FetchInventory(player)[i].ammo)
					
					if ZE2:FetchInventory(player)[i].ammo then
						v.drawString(x, y, ammo, V_SNAPTOBOTTOM, "thin-fixed")
						customhud.CustomFontString(v,x,y,ammo, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_AQUAMARINE)
					else
						if (leveltime/4)%2 == 0 then
							customhud.CustomFontString(v,x,y,ammo, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CRIMSON)
						else
							customhud.CustomFontString(v,x,y,ammo, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_AQUAMARINE)
						end
					end
				end
			end
		end
	end
	
	if ZE2:FetchInventorySlot(player) and ZE2:FetchInventorySlot(player).displayname then
		local iteminfo = ""
		local itemname = ZE2:FetchInventorySlot(player).displayname
		local itemcolor = ZE2:FetchInventorySlot(player).color or SKINCOLOR_CLOUDY
		
		if ZE2:FetchInventorySlot(player).damage then
			iteminfo = $ + "Damage: "..ZE2:FetchInventorySlot(player).damage.." "
		end
		
		customhud.CustomFontString(v,115*FU,sel_y-(10*FU),itemname, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, itemcolor)
		customhud.CustomFontString(v,115*FU,sel_y-(18*FU),iteminfo, "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CRIMSON)
	else
		customhud.CustomFontString(v,115*FU,sel_y-(10*FU),"EMPTY", "TNYFC", V_SNAPTOBOTTOM, nil, FRACUNIT, SKINCOLOR_CLOUDY)
	end
	
	-- weapon selection 
	v.drawStretched(sel_x-(2*FU), sel_y-(2*FU), FU, FU, s_patch, V_SNAPTOBOTTOM)
	if ZE2:FetchInventorySlot(player) then
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