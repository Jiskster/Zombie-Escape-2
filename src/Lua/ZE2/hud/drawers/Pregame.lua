return "Pregame", function(v, player)
    local pmo = player.mo
	local spacing = 80
    if not pmo then
        return
    end

	if ZE2.pregame_timeleft
	or (ZE2.zombie_releasetime and player.xSlinger.team == 2) then
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

	if ZE2.round_active then
		return
	end
end