local function getPlayersByDist(targetplr)
	local output, dists = {}, {}
	for player in players.iterate do
		if not player.mo or not player.mo.valid then continue end
		if (player == targetplr) then continue end
		output[#output + 1] = player
	end

	for i = 1, #output do
		local player = output[i]
		dists[output[i]] = R_PointToDist2(targetplr.mo.x, targetplr.mo.y, player.mo.x, player.mo.y)
	end

	table.sort(output, function(a, b)
		return (dists[a] > dists[b])
	end)
	return output
end

return "PlayerTags", function(v, player)
	local game = ZE2.Game
	if not player.mo or not player.mo.valid then return end
	if game.ended then return end

	local orderedPlayers = getPlayersByDist(player)
	local pointpatch = v.cachePatch("Z_POINTTEAM")
	for i = 1, #orderedPlayers do
		local plr = orderedPlayers[i]
		local sameteam = (plr.mo.team == player.mo.team)
		if not sameteam then
			if not P_CheckSight(plr.mo, player.mo) then continue end

			local dist = R_PointToDist2(player.mo.x, player.mo.y, plr.mo.x, plr.mo.y)
			if (dist > (1024 * FU)) then continue end
		end

		local result = xS_GetScreenCoords(v, player, camera, {
			x = plr.mo.x,
			y = plr.mo.y,
			z = plr.mo.z + plr.mo.height,
			eflags = plr.mo.eflags
		})

		if not result or not result.onscreen then continue end

		local ppsize = FU * 2
		local ppwidth = pointpatch.width*ppsize
		local ppheight = pointpatch.height*ppsize
		local fonttype = "thin-fixed-center"
		local offset1 = -ppwidth/2
		local offset2 = -(ppheight * 2)
		local healthmap = V_GREENMAP

		local translucency = 0
		local dist = R_PointToDist2(player.mo.x, player.mo.y, plr.mo.x, plr.mo.y)
		if (dist > (1024 * FU)) then
			translucency = V_TRANSLUCENT
		end

		do -- half size
			ppsize = ppsize / 2 -- when no blaze
			fonttype = "small-thin-fixed-center"
			offset1 = offset1 / 2
			offset2 = offset2 / 4
		end

		if (plr.mo.maxhealth ~= nil) and (plr.mo.health <= (plr.mo.maxhealth / 2)) then
			healthmap = V_REDMAP
		end

		if sameteam then
			v.drawScaled(result.x + offset1, result.y, ppsize, pointpatch)
		end

		local namecolor = sameteam and V_AQUAMAP or V_REDMAP
		v.drawString(result.x, result.y + offset2, plr.name, namecolor|V_ALLOWLOWERCASE|translucency, fonttype)
		if sameteam then
			v.drawString(result.x, result.y + (offset2 * 2), "+" .. (plr.mo.health + plr.mo.shield_health), healthmap|translucency, fonttype)
		end
	end
end, "game", 1