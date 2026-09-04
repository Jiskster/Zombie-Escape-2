
return "Shop", function(v, player)
	local game = ZE2.Game
	
	if not multiplayer then
		return end;
	
	if not (player.mo and player.mo.valid) then
		return end;

    if not P_IsLocalPlayer(player) then
        return end;

    if not (ZE2.pregame_menu == 2 or ZE2.shop_enter_anim) then
        return end;

    if (game.active) then
        return end;
		
	local stock = ZE2.Shop.stock
	
	local yoffset = 0
	if ZE2.shop_enter_anim then
		local div = FU - FixedDiv(abs(ZE2.shop_enter_anim), ZE2.shop_set_enter_anim)
		local ese = ease.outquint(div, -150*FU, 0)
		
		if ZE2.shop_enter_anim < 0 then
			ese = ease.outquint(div, 0, -150*FU)
		end
		
		yoffset = $ + ese/FU
	end
	
	local y = 80*FU + yoffset*FU
	
	local toptext = "Shop"
	local topwidth = v.levelTitleWidth(toptext)
	v.drawLevelTitle(160-(topwidth/2), y/FU - 55, toptext)
	
	for i=1,#stock do
		local stockitem = stock[i]
		local id = stockitem.id
		local item = xSlinger.registered_items[id]
		if not item then
			continue
		end
		
		local icon = item:get("icon", player.mo.skin)
		local patch = v.cachePatch(icon)
		
		local colormap = v.getColormap(nil, nil, "AllBlack")
		local x = 160*FU + (48*FU*(i-2))-(8*FU)
		
		local scale = FU
		
		if patch.width ~= 16 or patch.height ~= 16 then
			scale = FixedDiv(16, patch.width)
		end
		
		local anim = 0
		
		if ZE2.shop_selection == i and not ZE2.shop_oncontinue then
			colormap = v.getColormap(nil, nil, "AllWhite")
			anim = ZE2.shop_anim
			v.drawString(x + 8*FU, y + 24*FU + anim*FU, item:get("displayname", player.mo.skin) or "???", V_YELLOWMAP|V_ALLOWLOWERCASE, "thin-fixed-center") -- price
		end
		
		local cashmap = V_GREENMAP
		
		if player.ze2.cash < stockitem.price then
			cashmap = V_REDMAP
		end
		
		v.drawString(x + 8*FU, y - 8*FU, "$" .. stockitem.price, cashmap, "thin-fixed-center") -- price

		v.drawScaled(x + 4*FU + anim*FU, y + 4*FU + anim*FU, scale, patch, nil, colormap) -- shadow
		
		v.drawScaled(x - anim*FU, y - anim*FU, scale, patch) -- item icon
	end
	
	local finishmap = 0 -- finish your maps
	local anim = 0
	
	if ZE2.shop_oncontinue then
		finishmap = V_BLUEMAP
		anim = ZE2.shop_anim
		v.drawScaled(110*FU + anim*FU, y + 48*FU, FU, v.cachePatch("M_CURSOR"))
	end
	
	v.drawString(160*FU - anim*FU, y + 48*FU, "DONE", finishmap, "fixed-center") -- price
end, "game"