ZE2.PregameTopMenuDef = {
	[1] = {
		name = "Character"
	},
	[2] = {
		name = "Shop"
	}
}

ZE2.pregamehud = function(v, player, c)
	if ZE2.round_active then return end 
	if gametype ~= GT_ZE2 then return end
	local blackbgpatch
	local pregamemenu_type
    local pmo = player.mo 
    if not pmo then 
        return
    end
	
	if not player["ze2_info"].pregamemenu_active then
		return
	end
	
	blackbgpatch = v.cachePatch("Z_BG_BLACK")
	pregamemenu_type = player["ze2_info"].pregamemenu_type
	
	do -----------[Top menu drawing]-------------
		for i,tabledef in ipairs(ZE2.PregameTopMenuDef) do
			local color = SKINCOLOR_WHITE
			
			if (player["ze2_info"].pregamemenu_intopmenu and pregamemenu_type == i) then
				color = SKINCOLOR_YELLOW
			end
			
			local hscale = 60*FU
			local vscale = 20*FU
			local index_offset = (i-1)
			local menutype_offset = (pregamemenu_type-1)
			local x = 160*FU + (index_offset*80*FU) - (menutype_offset*80*FU)
			local y = 20*FU
			
			v.drawStretched(x-(hscale/2), y, hscale, vscale, blackbgpatch, V_SNAPTOTOP|V_50TRANS)
			
			if tabledef.name then
				customhud.CustomFontString(v, x, y+(vscale/3), tabledef.name, "TNYFC", (V_SNAPTOTOP), "center" , FU, color)
			end
		end
	end
end