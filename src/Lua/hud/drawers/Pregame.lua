ZE2.PregameTopMenuDef = {
	[1] = {
		name = "Character"
	},
	[2] = {
		name = "Shop"
	}
}

return "Pregame", function(v, player)
	local blackbgpatch
	local pregamemenu_type
	local pregamemenu_lasttype
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
	
	blackbgpatch = v.cachePatch("Z_BG_BLACK")
	pregamemenu_type = player.ze2.pregamemenu_type
	pregamemenu_lasttype = player.ze2.pregamemenu_lasttype
end