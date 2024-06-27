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
	
	customhud.CustomFontString(v, 280*FU, 30*FU, "Rubies: "..player["ze2_info"].rubies, "STCFC", (V_SNAPTOTOP|V_SNAPTORIGHT|topmenuflag), "right" , FU, SKINCOLOR_RED)
	
	for i,b in ipairs(ZE2.Survivor_ShopList) do
		local shopdefid = b.shopdefid
		local soldflag = (b.sold and not topmenuflag) and V_50TRANS or 0
		local shop_def = ZE2.NumToShopDef(shopdefid)
		local change = (i-1)*yc
		
		v.drawScaled(x, y+change, FU, infobarpatch, V_SNAPTOTOP|topmenuflag|soldflag)
		
		if shop_def then
			if shop_def.itemdef and shop_def.itemdef.icon then
				local icon_patch = v.cachePatch(shop_def.itemdef.icon)
				
				if icon_patch then
					local iconscale = shop_def.itemdef.iconscale or FU
					
					v.drawScaled(x+item_icon_xoffset, y+item_icon_yoffset+change, FixedMul(iconscale, FU), icon_patch, V_SNAPTOTOP|topmenuflag|soldflag)
				end
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
				
				v.drawScaled(rubyicon_x,rubyicon_y,FU,minirubypatch,V_SNAPTOTOP|topmenuflag)
				customhud.CustomFontString(v,price_x,price_y,price_text,"TNYFC",(V_SNAPTOTOP|topmenuflag|soldflag),nil,FU,SKINCOLOR_RED)
			end
		
			if shop_def.name then
				local color = SKINCOLOR_WHITE
				if shop_def.itemdef and shop_def.itemdef.color then
					color = shop_def.itemdef.color
				end
				
				customhud.CustomFontString(v, x + item_name_xoffset, y+item_name_yoffset+change, shop_def.name, "STCFC", (V_SNAPTOTOP|topmenuflag|soldflag), "center" , FU, color)
			end
			
			if not player["ze2_info"].pregamemenu_intopmenu then
				-- if selection is render index
				if shop_selection == i then
					v.drawScaled(x+selection_xoffset+selectionanim, y+selection_yoffset+change, FU, selectionpatch, V_SNAPTOTOP|topmenuflag|soldflag)
				end
			end
		end
	end
end

