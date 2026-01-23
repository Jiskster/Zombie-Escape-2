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
	
	-- Circle Stuff
	v.drawScaled(posx, posy, icscale, ic)
	
	-- Interaction Button Key Text
	v.drawString(posx + pos_offset, posy + 5*FU, "C3", nil, "thin-fixed-center")
	
	-- Interaction Text
	v.drawString(posx + pixelsize + spacebeforetext, posy + 5*FU, text, V_ALLOWLOWERCASE, "thin-fixed")
end

-- Held together with glue
local function drawItemInteraction(v, player, data)
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
	local text2 = "Take"
	local textwidth = v.stringWidth(text, V_ALLOWLOWERCASE, "thin")
	local textwidth2 = v.stringWidth(text2, V_ALLOWLOWERCASE, "thin")
	local spacebeforetext = 2*FU
	local spaceaftertext = 4*FU
	local leftbarwidth = (textwidth2 + 2) -- int
	
	-- circle
	local circle = v.cachePatch("INTERACTCIRCLE2")
	local circlesize = FU/20
	local circlediameter = FixedMul(circle.width*FU, circlesize)
	local cx = posx + (pixelsize/2) - (circlediameter/2)
	local cy = posy + (pixelsize/2) - (circlediameter/2)
	local dist = 6*FU + (FU*4)/5
	local c3buttonoffset = (leftbarwidth*FU)/8
	
	local buttonbgheight = 16 -- int
	local takebgheight = 9 -- int
	local iteminfobgheight = buttonbgheight + takebgheight
	
	local bgcolor1 = data.bgcolor1 or 22
	local bgcolor2 = data.bgcolor2 or 18

	-- button bg
	v.drawFill(posx/FU, posy/FU, leftbarwidth, buttonbgheight, 31+V_30TRANS)
	
	-- "Take" background (Below button bg)
	v.drawFill(posx/FU, posy/FU + 16, leftbarwidth, takebgheight, 30+V_30TRANS)
	
	-- Item Info BG
	v.drawFill(posx/FU + leftbarwidth, posy/FU, textwidth + 2, buttonbgheight, (bgcolor1)+V_10TRANS)
	
	-- Item Info BG (bottom)
	v.drawFill(posx/FU + leftbarwidth, posy/FU + buttonbgheight, textwidth + 2, takebgheight, (bgcolor2)+V_10TRANS)
	
	if not data.disable_circle then
		for i = 0, min(360, data.progress), 2 do
			local angle = i
			local xd = FixedMul(cos(FixedAngle(angle*FU) - ANGLE_90), dist)
			local yd = FixedMul(sin(FixedAngle(angle*FU) - ANGLE_90), dist)
			
			-- circle
			v.drawScaled(cx + xd + c3buttonoffset, cy + yd, circlesize, circle)
		end
	end
	
	-- Circle Stuff
	v.drawScaled(posx + c3buttonoffset, posy, icscale, ic)
	v.drawString(posx + pos_offset + c3buttonoffset, posy + 5*FU, "C3", nil, "thin-fixed-center")
	
	-- Item Name
	v.drawString(posx + (leftbarwidth)*FU + FU, posy + 5*FU, text, V_ALLOWLOWERCASE, "thin-fixed")
	
	-- "Take" text
	v.drawString(posx + 1*FU, posy + 17*FU, text2, V_ALLOWLOWERCASE, "thin-fixed")
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
			local interaction = i_obj.interaction
			local interaction_text = interaction.text or "ERROR!"
			local interaction_holdtime = interaction.holdtime or 0
			local interaction_type = interaction.type

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
			elseif interaction_type == "item" then
				local droppeditem = interaction.droppeditem -- MT_XS_DROPPEDITEM (mobj_t)
				local iteminfo = droppeditem.iteminfo
				
				drawItemInteraction(v, player, {
					x = FixedRound(result.x) + 8*FU;
					y = FixedRound(result.y);
					progress = progress_num;
					text = iteminfo.name or interaction_text;
					disable_circle = (xS.interaction_hold == 0);
				})
			end
		end
	end
end)