ZE2.shophud = function(v, player)
	if (ZE2.game_ended) or (not player.shop_anim) or (not player.shop_person) then return end

	local sp = player.shop_person
	local theshop = sp.shop
	
	local animlength = 1*TICRATE + TICRATE/2
	
	local bg = { -- background
		start = 9,
		stop = 6
	}	
	local shop = { -- background
		start = 9,
		stop = 1
	}	
	local bl = { -- bang lower's y
		start = 168+40,
		stop = 168
	}
	local bu = { -- bang upper's y
		start = -40,
		stop = 0
	}

	local z_bu = v.cachePatch("Z_BANG_UPPER_GRAY")
	local z_bl = v.cachePatch("Z_BANG_LOWER_GRAY")
	local z_bg = v.cachePatch("Z_BG_GRAY")
	local item_bg_patch = v.cachePatch("BLACK160X100")
	local ruby_patch = v.cachePatch("Z_MINI_RUBY")
	local cursor_patch = v.cachePatch("SLCT1LVL")
		
	local scroll = (leveltime%128)
	
	bg.ese = bg.start-(FixedDiv(player.shop_anim*FU, animlength*FU/2)*9/FU)
	shop.ese = ease.inoutsine(FixedDiv(player.shop_anim*FU, animlength*FU),shop.start,shop.stop)
	bl.ese = ease.inoutsine(FixedDiv(player.shop_anim*FU, animlength*FU),bl.start*FU,bl.stop*FU)
	bu.ese = ease.inoutsine(FixedDiv(player.shop_anim*FU, animlength*FU),bu.start*FU,bu.stop*FU)
	
	local item_y = 75*FU

	if bg.ese > 5 then
		v.drawScaled(-500*FU,-500*FU, FU*1000, z_bg, bg.ese<<V_ALPHASHIFT)
	else
		v.drawScaled(-500*FU,-500*FU, FU*1000, z_bg, 5<<V_ALPHASHIFT)
	end
	
	for i=-5,5
		v.drawScaled((i*128*FU)+(scroll*FU),max(bl.ese,bl.stop*FU),FU,z_bl,V_SNAPTOBOTTOM)
	end
	for i=-5,5
		v.drawScaled((i*128*FU)-(scroll*FU),min(bu.ese,bu.stop*FU),FU,z_bu,V_SNAPTOTOP)
	end
	local trans
	if player.shop_anim ~= animlength then
		trans = shop.ese<<V_ALPHASHIFT
	end
	if player.rubies ~= nil then
		customhud.CustomFontString(v, 120, 0, "Rubies: "..player.rubies, "STCFC", 
		(V_SNAPTOTOP), nil , nil, SKINCOLOR_RED)
	end
	if not player["ze2_info"].shop_confirmscreen then
		v.drawString(160*FU,42*FU,"\x82".."BUY:\x80 JUMP     \x82LEAVE:\x80 SPIN", trans, "thin-fixed-center")
		--draw the shopkeeper's phrase
		if player.shop_person.phrases then
			local shopkeeper = player.shop_person
			--idk if I should use customhud's string drawer to apply mobj's color
			customhud.CustomFontString(v,160*FU,24*FU, shopkeeper.phrases[shopkeeper.phrase], "STCFC", trans, "center", FU, shopkeeper.color)
		end
		--draw shop items
		for i=1,#theshop do
			local item 
			local item_x = (i*100*FU)+(120*FU)-((player["ze2_info"].shop_selection-1) * (100*FU)) - 100*FU -- (player["ze2_info"].shop_selection-1 * (120*FU))
			if theshop[i] and theshop[i][2] then
				item = theshop[i][2]
				local item_scale = item.iconscale or FU
				
				-- Background to the shop item.
				v.drawScaled(item_x,item_y,FU>>1,item_bg_patch,trans)
				-- Ruby Icon
				v.drawScaled(item_x+(FU),item_y-(FU*13),FU,ruby_patch,trans)
				-- Ruby Price
				if theshop[i] and theshop[i][1] then
					v.drawString(item_x+(16*FU),item_y-(9*FU),"\x85"..theshop[i][1],trans, "fixed")
				end
				-- Weapon Icon
				v.drawScaled(item_x,item_y+(9*FU),item_scale,v.cachePatch(item.icon),trans)
				-- Name
				v.drawString(item_x,item_y+(FU),item.displayname:upper(),trans, "thin-fixed")
				-- Delay
				local secondsrate = G_TicsToSeconds(item.firerate).."."..G_TicsToCentiseconds(item.firerate)
				v.drawString(item_x+(16*FU),item_y+(13*FU),"\x84".."RATE: "..secondsrate,trans, "thin-fixed")
				-- Damage
				if item.damage then
					v.drawString(item_x,item_y+(25*FU),"\x85".."DAMAGE: "..item.damage,trans, "thin-fixed")
				end
				-- Knockback
				if item.knockback then
					v.drawString(item_x,item_y+(33*FU),"\x83".."KNOCKBACK: "..item.knockback>>16,trans, "thin-fixed")
				end
			else
				v.drawScaled(item_x,item_y,FU>>1,item_bg_patch,trans)
				v.drawString(item_x,item_y+(FU),"EMPTY!",trans, "thin-fixed")
			end
		end
		v.drawScaled(120*FU,item_y,FU>>1,cursor_patch,trans)
	else
		local itemchoosing = player.shop_person.shop[player["ze2_info"].shop_selection][2]
		if itemchoosing then
			v.drawString(160*FU,34*FU,"\x82".."REPLACE HOLDING ITEM:\x80 CUSTOM 1", (V_SNAPTOTOP), "thin-fixed-center")
			v.drawString(160*FU,42*FU,"\x82".."BUY:\x80 JUMP    \x82 CANCEL:\x80 SPIN", (V_SNAPTOTOP), "thin-fixed-center")
			v.drawString(160*FU,50*FU,"\x82".."Are you sure you want to buy "..itemchoosing.displayname.."?", (V_SNAPTOTOP), "thin-fixed-center")
			if not (leveltime % 3) then
				if (ZE2:FetchInventorySlot(player) and ZE2:IsInventoryFull(player)) then
					v.drawString(160*FU,58*FU,"\x84".."WARNING! YOUR HELD ITEM WILL BE REPLACED!", (V_SNAPTOTOP), "thin-fixed-center")
				end
			end
		end
	end
end

