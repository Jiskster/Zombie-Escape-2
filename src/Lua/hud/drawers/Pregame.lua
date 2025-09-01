ZE2.PregameTopMenuDef = {
	[1] = {
		name = "Character"
	},
	[2] = {
		name = "Shop"
	}
}

local function drawPG(v, hud_name, x, y, patch, scale, colormap, selected)
	hud_name = $ or "Character"
	scale = $ or FU

	local hud_len = v.stringWidth(hud_name, V_SNAPTOBOTTOM|V_ALLOWLOWERCASE) -- string length to determine how long the bg should be

	if selected then
		v.drawFill((x/FU)-2, (y/FU)-2, 16 + hud_len + 10, 20, 73 + V_SNAPTOBOTTOM) -- selected bg
	end

	v.drawFill((x/FU)-1, (y/FU)-1, 16 + hud_len + 8, 18, 159 + V_SNAPTOBOTTOM) -- bg

	v.drawScaled(x, y, scale, patch, V_SNAPTOBOTTOM|V_YELLOWMAP, colormap) -- icon
	v.drawString(x + 20*FU, y + 4*FU, hud_name, V_SNAPTOBOTTOM|V_ALLOWLOWERCASE, "fixed") -- text
end

return "Pregame", function(v, player)
    local pmo = player.mo
	local spacing = 80
    if not pmo then 
        return
    end
	
	if ZE2.pregame_timeleft 
	or (ZE2.zombie_releasetime and player.ze2.team == 2) then
		local offset = sin(ANG1*(leveltime*3))*3 
		local offset2 = cos(ANG1*(leveltime*3))*3
		local x = (160*FU) + offset
		local y = (170*FU) + offset2
		local text
		
		if ZE2.zombie_releasetime then
			local rtext = tostring(G_TicsToSeconds(ZE2.zombie_releasetime).."."..G_TicsToCentiseconds(ZE2.zombie_releasetime))
			text = "You will be released in: "..rtext.." seconds."
		end
		
		if text then
			customhud.CustomFontString(v,x,y,text, "TNYFC", (V_SNAPTOBOTTOM|V_TRANSLUCENT), "center" , FRACUNIT, SKINCOLOR_GREY)
		end
	end
	
	if not player.ze2.pregamemenu_active then
		return
	end
	
	if ZE2.round_active then 
		return
	end 

	if player.ze2.pregamemenu_type == 1 then
		local hud_icon_scale = FU
		local selected_skin = pmo.skin
		local skin_patch = v.getSprite2Patch(selected_skin, SPR2_XTRA)
		local hires = skins[selected_skin].highresscale or FU
		local scale = FixedDiv(FixedMul(hud_icon_scale,hires), 2*FU)
		local colormap = v.getColormap(selected_skin, player.skincolor)
		local shop_patch = v.cachePatch("Z_SHOP_ICON")

		local x = 64*FU
		local y = 200*FU - 28*FU
		drawPG(v, "Character", x, y, skin_patch, scale, colormap, player.ze2.pregamemenu_selection == 1)
		x = $ + 128*FU
		drawPG(v, "Shop", x, y, shop_patch, nil, nil, player.ze2.pregamemenu_selection == 2)
	end
end