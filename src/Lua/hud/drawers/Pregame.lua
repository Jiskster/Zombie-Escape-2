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
		
		if player.ze2.team == 1 then
			if player.ze2.pregamemenu_active then
				if not player.ze2.pregamemenu_intopmenu then
					if player.ze2.pregamemenu_type == 1 then
						text = "Press SPIN to select a character."
					end
				end
			else
				text = "Press SPIN to open pregame menu."
			end
		elseif ZE2.zombie_releasetime then
			local rtext = tostring(G_TicsToSeconds(ZE2.zombie_releasetime).."."..G_TicsToCentiseconds(ZE2.zombie_releasetime))
			text = "You will be released in: "..rtext.." seconds."
		end
		
		if player.ze2.charselect_hold then
			local holdticoffset = (TICRATE - player.ze2.charselect_hold)
			text = tostring(G_TicsToSeconds(holdticoffset).."."..G_TicsToCentiseconds(holdticoffset))
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
	
	do -----------[Top menu drawing]-------------
		for i,tabledef in ipairs(ZE2.PregameTopMenuDef) do
			local color = SKINCOLOR_WHITE
			
			if (player.ze2.pregamemenu_intopmenu and pregamemenu_type == i) then
				color = SKINCOLOR_YELLOW
			end
			
			local ease_offset = player.ze2.pregamemenu_intopmenuanim_max - player.ze2.pregamemenu_intopmenuanim
			local ese_div 
			local ese = 0
			
			if player.ze2.pregamemenu_intopmenuanim and ease_offset then
				local anim_start = (pregamemenu_lasttype-1)*spacing*FU
				local anim_end = (pregamemenu_type-1)*spacing*FU
				ese_div = FixedDiv(ease_offset*FU, player.ze2.pregamemenu_intopmenuanim_max*FU)
				ese = ease.outexpo(ese_div, anim_start, anim_end)
			end
			
			local hscale = 60*FU
			local vscale = 20*FU
			
			local x = (160*FU) + ((i-1)*spacing*FU) - (pregamemenu_type-1)*spacing*FU
			
			if player.ze2.pregamemenu_intopmenuanim then
				x = (160*FU) + ((i-1)*spacing*FU) - ese -- pose as if you're in your last selection + easing offset
			end
			
			local y = 20*FU
			
			v.drawStretched(x-(hscale/2), y, hscale, vscale, blackbgpatch, V_SNAPTOTOP|V_50TRANS)
			
			if tabledef.name then
				customhud.CustomFontString(v, x, y+(vscale/3), tabledef.name, "TNYFC", (V_SNAPTOTOP), "center" , FU, color)
			end
		end
	end
end