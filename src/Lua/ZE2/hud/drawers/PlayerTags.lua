local function getPlayersByDist(targetplr)
	local output = {}
	local dists = {}
	
	for player in players.iterate do
		if not (player.mo and player.mo.valid) then
			continue end;

		if (player == targetplr) then
			continue end;
			
		output[#output + 1] = player
	end
	
	for i=1, #output do
		local player = output[i]
		dists[output[i]] = R_PointToDist2(targetplr.mo.x, targetplr.mo.y, player.mo.x, player.mo.y)
	end
	
	table.sort(output, function(a,b)
		return dists[a] > dists[b]
	end)
	
	return output
end

return "PlayerTags", function(v, player)
	if not (player.mo and player.mo.valid) then
		return end;

	if (ZE2.game_ended) then
		return end;
	
	local orderedPlayers = getPlayersByDist(player)

	local pointpatch = v.cachePatch("Z_POINTTEAM")
	for i=1, #orderedPlayers do
		local plr = orderedPlayers[i]
		
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
		local healthmap = V_GREENMAP

		local dist = R_PointToDist2(player.mo.x, player.mo.y, plr.mo.x, plr.mo.y)

		do -- half size
			ppsize = $/2 -- when no blaze
			fonttype = "small-thin-fixed-center"
			offset1 = $/2
			offset2 = $/2
		end
		
		if plr.mo.health <= (plr.mo.maxhealth/2) then
			healthmap = V_REDMAP
		end

		v.drawScaled(result.x + offset1, result.y, ppsize, pointpatch)
		v.drawString(result.x, result.y+offset2, plr.name, V_AQUAMAP, fonttype)
		v.drawString(result.x, result.y+(offset2*2), "+"..(plr.mo.health + plr.mo.shield_health), healthmap, fonttype)
	end
end, "game", 1