local round_active = false
local hud_icon_scale = FU+(FU/4)

ZE2.getCharacterSelection = function(player)
	return player.ze2.charselect_selection or 1
end

ZE2.getSkinFromCharSelect = function(player)
	return skins[ZE2.getSkinNames(player, true)[player.ze2.charselect_selection]] or skins["sonic"]
end

return "CharacterSelect", function(v, player)
	if ZE2.round_active then return end 
	
    local pmo = player.mo 
    if not pmo then 
        return
    end

    local cursorpatch = v.cachePatch("CURWEAP")
	local barpatch = v.cachePatch("DABARR")
	
    local skincount = #ZE2.getSkinNums(player,true)

	local cc = ZE2.SurvivorConfig
	
	if not player.ze2.pregamemenu_active then
		return
	end
	
	if player.ze2.pregamemenu_type ~= 2 then return end
	
	--Blue Bar
	v.drawStretched(0, 67*FRACUNIT, 1500*FRACUNIT, FRACUNIT*3, barpatch, V_SNAPTOTOP|V_SNAPTOLEFT)
	
	--Character Icons
    for i,skinname in ipairs(ZE2.getSkinNames(player,true)) do
        local sel = ZE2.getCharacterSelection(player)

		local x = (157+(i*25))*FRACUNIT - (sel*25)*FRACUNIT
		local y = 86*FRACUNIT

		-- If animation is playing.
		if player.ze2.charselect_anim ~= nil and player.ze2.charselect_prevselection then
			local div = FixedDiv(player.ze2.charselect_anim*FRACUNIT, ((TICRATE/2)*FRACUNIT))
			local anim_start = (player.ze2.charselect_prevselection*25)*FRACUNIT
			local anim_end = (player.ze2.charselect_selection*25)*FRACUNIT
			local ese = ease.outexpo(div, anim_start, anim_end)

			x = (157+(i*25))*FRACUNIT - (ese)
		end
		
		local hires = skins[ZE2.getSkinNums(player,true)[i]].highresscale or FU
        local scale = FixedMul(hud_icon_scale,hires)
        local skinpatch = v.getSprite2Patch(skinname, SPR2_LIFE)
        
        local flags = V_SNAPTOTOP
		local colormap = v.getColormap(skinname, skins[ZE2.getSkinNums(player,true)[i]].prefcolor)
        v.drawScaled(x, y, scale, skinpatch, flags, colormap)
    end

	--Selection Square
    do
        local skincount = #ZE2.getSkinNums(player,true)
		
        local x = 145*FU
        local y = 70*FU

        local scale = hud_icon_scale
        
        local flags = V_SNAPTOTOP
        
        v.drawScaled(x, y, scale, cursorpatch, flags)
    end
	
	local the_color = ZE2.getSkinFromCharSelect(player).prefcolor
	local the_name = ZE2.getSkinFromCharSelect(player).realname
	customhud.CustomFontString(v, 160*FU, 50*FU, the_name, "STCFC", (V_SNAPTOTOP), "center" , 2*FRACUNIT, the_color)

	local charinfo_text = {
		[1] = {
			textcolor = ZE2.getSkinFromCharSelect(player).prefcolor,
			text = ZE2.getSkinFromCharSelect(player).realname
		},
		[2] = {
			textcolor = SKINCOLOR_GREEN,
			text = "Spawn HP: ".. (
				(cc[ZE2.getSkinFromCharSelect(player).name] and cc[ZE2.getSkinFromCharSelect(player).name].health) 
				
				and cc[ZE2.getSkinFromCharSelect(player).name].health 
				
				or "[UNREGISTERED HP]"
			)
		},
		[3] = {
			textcolor = SKINCOLOR_TEAL,
			text = "Speed: ".. (
				(cc[ZE2.getSkinFromCharSelect(player).name] and cc[ZE2.getSkinFromCharSelect(player).name].speed) 
				
				and cc[ZE2.getSkinFromCharSelect(player).name].speed:upper()
				
				or "[UNREGISTERED SPEED]"
			)
		},
		[4] = {
			textcolor = SKINCOLOR_YELLOW,
			text = (
				(cc[ZE2.getSkinFromCharSelect(player).name] and cc[ZE2.getSkinFromCharSelect(player).name].description) 
				
				and cc[ZE2.getSkinFromCharSelect(player).name].description[1]
				
				or ""
			)
		},
		[5] = {
			textcolor = SKINCOLOR_LIME,
			text = (
				(cc[ZE2.getSkinFromCharSelect(player).name] and cc[ZE2.getSkinFromCharSelect(player).name].description) 
				
				and cc[ZE2.getSkinFromCharSelect(player).name].description[2]
				
				or ""
			)
		},
		[6] = {
			textcolor = SKINCOLOR_PERIDOT,
			text = (
				(cc[ZE2.getSkinFromCharSelect(player).name] and cc[ZE2.getSkinFromCharSelect(player).name].description) 
				
				and cc[ZE2.getSkinFromCharSelect(player).name].description[3]
				
				or ""
			)
		}
	}

	for i=1,#charinfo_text do
		local t_ese_div = FixedDiv(player.ze2.charselect_anim*FRACUNIT, ((TICRATE/2)*FRACUNIT))
		local t_ese = ease.outexpo(t_ese_div, 640*FRACUNIT, 320*FRACUNIT)
		local output_color = charinfo_text[i].textcolor or SKINCOLOR_GREY
		local output_text = charinfo_text[i].text or "????", "STCFC"
		customhud.CustomFontString(v, t_ese, 100*FU + (i*(8*FU)), output_text, "TNYFC", (V_SNAPTORIGHT|V_SNAPTOTOP), "right", FU, output_color)
	end
end