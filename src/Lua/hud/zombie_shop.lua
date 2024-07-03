-- Lazily Coded Shop For Now

ZE2.zombie_shophud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	
	
	
	if player["ze2_info"].team ~= 2 then
		return
	end
	
	if player.playerstate ~= PST_DEAD then
		return
	end
	
	local selection = player["ze2_info"].zombie_shop_selection
	
	if not player["ze2_info"].zombie_shop_open then
		v.drawString(160, 152, "Press C1 To Open Zombie Shop", V_SNAPTOBOTTOM, "center")
		v.drawString(160, 144, "Press Jump To Respawn", V_SNAPTOBOTTOM, "center")
	else
		v.fadeScreen(0xFF00, 15)
	
		v.drawString(160, 50, "Zombie Shop", V_SNAPTOTOP, "center")
		
		
		for i=1,#ZE2.Zombie_ShopList do
			local text = ZE2.NumToShopDef(i).realname.." \x85"..ZE2.NumToShopDef(i).price.."BLD"
			v.drawString(100, 66+((i-1)*8),text,V_SNAPTOTOP)
		end
		
		v.drawString(92, 66+((selection-1)*8), "\x82\>", V_SNAPTOTOP)
		
		v.drawString(160, 152, "Press C1 To Buy", V_SNAPTOBOTTOM, "center")
		v.drawString(160, 144, "Press Jump To Respawn", V_SNAPTOBOTTOM, "center")
		
		v.drawString(16, 184, "\x85\Blood: "..player["ze2_info"].blood_currency, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	end
end