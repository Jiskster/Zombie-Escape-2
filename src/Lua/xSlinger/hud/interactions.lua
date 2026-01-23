local function drawInteraction(v, player, data)
	if not type(data) == "table" then
		return end;
		
	if (data.x == nil or data.y == nil or data.progress == nil or data.text == nil) then
		return end;
		
	local ic = v.cachePatch("INTERACTCIRCLE")
	local icwidth = ic.width*FU
	local icscale = FU/4
	local posx = data.x
	local posy = data.y
	local pixelsize = FixedMul(icwidth, icscale)
	local pos_offset = pixelsize/2
	local text = data.text
	local textwidth = v.stringWidth(text, V_ALLOWLOWERCASE, "thin")
	local spacebeforetext = 2*FU
	local spaceaftertext = 4*FU
	
	-- circle
	local circle = v.cachePatch("INTERACTCIRCLE2")
	local circlesize = FU/20
	local circlediameter = FixedMul(circle.width*FU, circlesize)
	local cx = posx + (pixelsize/2) - (circlediameter/2)
	local cy = posy + (pixelsize/2) - (circlediameter/2)
	local dist = 6*FU + (FU*4)/5

	-- info bg
	v.drawFill(posx/FU, posy/FU, (pixelsize/FU) + (spacebeforetext/FU) + textwidth + (spaceaftertext/FU), 16, 31+V_50TRANS)
	
	if not data.disable_circle then
		for i = 0, min(360, data.progress), 2 do
			local angle = i
			local xd = FixedMul(cos(FixedAngle(angle*FU) - ANGLE_90), dist)
			local yd = FixedMul(sin(FixedAngle(angle*FU) - ANGLE_90), dist)
			
			-- circle
			v.drawScaled(cx + xd, cy + yd, circlesize, circle)
		end
	end
	
	-- info (more)
	v.drawScaled(posx, posy, icscale, ic)
	v.drawString(posx + pos_offset, posy + 5*FU, "C3", nil, "thin-fixed-center")
	v.drawString(posx + pixelsize + spacebeforetext, posy + 5*FU, text, V_ALLOWLOWERCASE, "thin-fixed")
end

addHook("HUD", function(v, player)
	local xS = player.xSlinger
	local i_obj = xS.selected_interaction
	
	if i_obj and i_obj.valid and i_obj.interaction then
		local result = K_GetScreenCoords(v,player,camera,{
			x = i_obj.x;
			y = i_obj.y;
			z = i_obj.z + (i_obj.height*3)/4;
			eflags = i_obj.eflags;
		})
			
		if result and result.onscreen then
			local interaction_text = i_obj.interaction.text or "ERROR!"
			local interaction_holdtime = i_obj.interaction.holdtime or 0
			local interaction_type = i_obj.interaction.type

			local div = FixedDiv(xS.interaction_hold*FU,interaction_holdtime*FU)
			local progress_num = FixedMul(div,360*FU)/FU
			
			if interaction_type == "generic" then
				drawInteraction(v, player, {
					x = FixedRound(result.x) + 8*FU;
					y = FixedRound(result.y);
					progress = progress_num;
					text = interaction_text;
					disable_circle = (xS.interaction_hold == 0);
				})
			end
		end
	end
end)