ZE2.shophud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	if not player["ze2_info"].pregamemenu_active then
		return
	end
	
	if player["ze2_info"].pregamemenu_type ~= 2 then return end
	if not #ZE2.Survivor_ShopList then return end
	
	local topmenuflag = player["ze2_info"].pregamemenu_intopmenu and V_80TRANS or 0
	
	local x = 100*FU
	local y = 50*FU
	local yc = 25*FU
	
	local item_name_xoffset = 85*FU
	local item_name_yoffset = 10*FU
	
	local item_icon_xoffset = 5*FU
	local item_icon_yoffset = 3*FU
	
	local ruby_icon_xoffset = 35*FU
	local ruby_icon_yoffset = 2*FU
	
	-- offset from icon offset
	local ruby_price_xoffset = ruby_icon_xoffset + 8*FU
	local ruby_price_yoffset = ruby_icon_yoffset
	
	local selection_xoffset = -8*FU
	local selection_yoffset = 4*FU
	
	local selectionanim = (((leveltime/4)%2) == 0) and 2*FU or 0*FU
	
	local shop_selection = player["ze2_info"].shop_selection
	
	local infobarpatch = v.cachePatch("Z_SHOPINFOBAR")
	local minirubypatch = v.cachePatch("Z_MINI_RUBY")
	local selectionpatch = v.cachePatch("Z_SHOPSELECTION")
	
	customhud.CustomFontString(v, 280*FU, 30*FU, "Rubies: "..player["ze2_info"].cash, "STCFC", (V_SNAPTOTOP|V_SNAPTORIGHT|topmenuflag), "right" , FU, SKINCOLOR_RED)
	
	for i,b in ipairs(ZE2.Survivor_ShopList) do
		local shopdefid = b.shopdefid
		local soldflag = (b.sold and not topmenuflag) and V_50TRANS or 0
		local shop_def = ZE2.NumToShopDef(shopdefid)
		local iteminfo = shop_def.iteminfo
		local change = (i-1)*yc
		
		v.drawScaled(x, y+change, FU, infobarpatch, V_SNAPTOTOP|topmenuflag|soldflag)
		
		if shop_def then
			if iteminfo and iteminfo.icon then
				local icon_patch = v.cachePatch(iteminfo.icon)
				
				if icon_patch then
					local iconscale = iteminfo.iconscale or FU
					
					v.drawScaled(x+item_icon_xoffset, y+item_icon_yoffset+change, FixedMul(iconscale, FU), icon_patch, V_SNAPTOTOP|topmenuflag|soldflag)
				end
			elseif shop_def.icon then
				local iconscale = shop_def.iconscale or FU
				local icon_patch = v.cachePatch(shop_def.icon)
				
				v.drawScaled(x+item_icon_xoffset, y+item_icon_yoffset+change, FixedMul(iconscale, FU), icon_patch, V_SNAPTOTOP|topmenuflag|soldflag)
			end
			
			if shop_def.price then
				local rubyicon_x = x+ruby_icon_xoffset
				local rubyicon_y = y+ruby_icon_yoffset+change
				local price_x = x+ruby_price_xoffset
				local price_y = y+ruby_price_yoffset+change
				local price_text = tostring(shop_def.price)
				if b.sold then
					price_text = $ + " (SOLD)"
				end
				
				v.drawScaled(rubyicon_x,rubyicon_y,FU,minirubypatch,V_SNAPTOTOP|topmenuflag|soldflag)
				customhud.CustomFontString(v,price_x,price_y,price_text,"TNYFC",(V_SNAPTOTOP|topmenuflag|soldflag),nil,FU,SKINCOLOR_RED)
			end
			
			local color = SKINCOLOR_WHITE
			if shop_def.name then
				
				if iteminfo and iteminfo.color then
					color = iteminfo.color
				end
				
				customhud.CustomFontString(v, x + item_name_xoffset, y+item_name_yoffset+change, shop_def.name, "STCFC", (V_SNAPTOTOP|topmenuflag|soldflag), "center" , FU, color)
			end
			
			if not player["ze2_info"].pregamemenu_intopmenu then
				-- if selection is render index
				if shop_selection == i then
					local draw_info_table = {
						[1] = {
							color = color,
							text = shop_def.name,		
						},
						[2] = {
							color = SKINCOLOR_RED,
							text = "Price: "..shop_def.price,
						}
					}
					
					-- Selection Arrow
					v.drawScaled(x+selection_xoffset+selectionanim, y+selection_yoffset+change, FU, selectionpatch, V_SNAPTOTOP|topmenuflag)
					
					if iteminfo then
						if iteminfo.damage then
							table.insert(draw_info_table, {
								color = SKINCOLOR_CRIMSON,
								text = "Damage: ".. iteminfo.damage,
							})
						end
						
						if iteminfo.knockback then
							table.insert(draw_info_table, {
								color = SKINCOLOR_GREEN,
								text = string.format("Knockback: %.2fFU", iteminfo.knockback),
							})
						end
						
						if iteminfo.firerate then
							table.insert(draw_info_table, {
								color = SKINCOLOR_MOSS,
								text = "ItemDelay: ".. G_TicsToSeconds(iteminfo.firerate).."."..G_TicsToCentiseconds(iteminfo.firerate).." secs",
							})
						end
						
						if iteminfo.count and iteminfo.max_count then
							table.insert(draw_info_table, {
								color = SKINCOLOR_VAPOR,
								text = "Count: ".. iteminfo.count.."/"..iteminfo.max_count,
							})
						end
						
						if iteminfo.ammo and iteminfo.max_ammo then
							table.insert(draw_info_table, {
								color = SKINCOLOR_NOBLE,
								text = "Ammo: ".. iteminfo.ammo.."/"..iteminfo.max_ammo,
							})
						end
						
						if iteminfo.reload_time then
							table.insert(draw_info_table, {
								color = SKINCOLOR_PEAR,
								text = "Reload Time: ".. G_TicsToSeconds(iteminfo.reload_time).."."..G_TicsToCentiseconds(iteminfo.reload_time).." secs",
							})
						end
					end
					
					-- Draw Item Info
					for ii,bb in ipairs(draw_info_table) do
						customhud.CustomFontString(v,0,60+((ii-1)*8),bb.text,"TNYFC",(V_SNAPTOTOP|V_SNAPTOLEFT|topmenuflag|soldflag),nil,nil,bb.color)
					end
				end
			end
		end
	end
end

