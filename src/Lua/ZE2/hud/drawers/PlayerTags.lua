return "PlayerTags", function(v, player)
	if not (player.mo and player.mo.valid) then
		return end;
		
	if (ZE2.game_ended) then
		return end;
		
	local pointpatch = v.cachePatch("Z_POINTTEAM")
	for plr in players.iterate do
		if not (plr.mo and plr.mo.valid) then
			continue end;
			
		if (plr == player) then
			continue end;
			
		if (plr.mo.team ~= player.mo.team) then
			continue end;
			
		local result = K_GetScreenCoords(v,player,camera, {
			x = plr.mo.x;
			y = plr.mo.y;
			z = plr.mo.z + plr.mo.height;
			eflags = plr.mo.eflags;
		})

		if not (result and result.onscreen) then
			continue end;
		
		local ppwidth = pointpatch.width*FU
		local ppheight = pointpatch.height*FU
		local ppsize = FU
		local fonttype = "thin-fixed-center"
		local offset1 = -ppwidth/2
		local offset2 = -(ppheight*2)
		
		local dist = R_PointToDist2(player.mo.x, player.mo.y, plr.mo.x, plr.mo.y)
		
		if dist > 512*FU then
			ppsize = $/2 -- when no blaze
			fonttype = "small-thin-fixed-center"
			offset1 = $/2
			offset2 = $/2
		end
		
		v.drawScaled(result.x + offset1, result.y, ppsize, pointpatch)
		v.drawString(result.x, result.y+offset2, player.name, V_AQUAMAP, fonttype)
	end
end, "game", 1