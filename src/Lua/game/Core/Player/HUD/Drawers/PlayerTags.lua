local function getPlayersByDist(targetplr)
	local output, dists = {}, {}
	for player in players.iterate do
		if not player.realmo or not player.realmo.valid then continue end
		if player.spectator then continue end
		if (player == targetplr) then continue end
		output[#output + 1] = player
	end

	for i = 1, #output do
		local player = output[i]
		dists[output[i]] = R_PointToDist2(targetplr.realmo.x, targetplr.realmo.y, player.realmo.x, player.realmo.y)
	end

	table.sort(output, function(a, b)
		return (dists[a] > dists[b])
	end)
	return output
end

return "PlayerTags", function(v, player)
	local game = ZE2.Game
	if not player.realmo or not player.realmo.valid then return end
	if game.ended then return end

	local orderedPlayers = getPlayersByDist(player)
	local pointpatch = v.cachePatch("Z_POINTTEAMC")
	for i = 1, #orderedPlayers do
		local plr = orderedPlayers[i]
		if plr.spectator then continue end

		local sameteam = player.spectator or (plr.realmo.team == player.realmo.team)
		if not sameteam then
			if not P_CheckSight(plr.mo, player.mo) then continue end

			local dist = R_PointToDist2(player.realmo.x, player.realmo.y, plr.realmo.x, plr.realmo.y)
			if (dist > (1024 * FU)) then continue end
		end

		local result = xS_GetScreenCoords(v, player, camera, {
			x = plr.realmo.x,
			y = plr.realmo.y,
			z = plr.realmo.z + plr.realmo.height,
			eflags = plr.realmo.eflags
		})

		if not result or not result.onscreen then continue end

		local ppsize = FU
		local ppwidth = pointpatch.width*ppsize
		local ppheight = pointpatch.height*ppsize
		local fonttype = "thin-fixed-center"
		local offset1 = -ppwidth/2
		local offset2 = -(ppheight * 2)
		local healthmap = V_GREENMAP

		local translucency = 0
		local dist = R_PointToDist2(player.realmo.x, player.realmo.y, plr.realmo.x, plr.realmo.y)
		if (dist > (1024 * FU)) then
			translucency = V_TRANSLUCENT
		end

		do -- half size
			ppsize = ppsize / 2 -- when no blaze
			fonttype = "small-thin-fixed-center"
			offset1 = offset1 / 2
			offset2 = offset2 / 2
		end

		if (plr.realmo.maxhealth ~= nil) then
			if (plr.realmo.health <= (plr.realmo.maxhealth / 4)) then
				healthmap = V_REDMAP
			elseif (plr.realmo.health <= (plr.realmo.maxhealth / 2)) then
				healthmap = V_YELLOWMAP
			end
		end

		if sameteam then
			local pointcolor = (plr.realmo.team == 1) and SKINCOLOR_BLUE or SKINCOLOR_RED
			v.drawScaled(result.x + offset1, result.y, ppsize, pointpatch, 0, v.getColormap(nil, pointcolor, nil))
		end

		local namecolor = (plr.realmo.team == 1) and V_BLUEMAP or V_REDMAP
		v.drawString(result.x, result.y + offset2, plr.name, namecolor|V_ALLOWLOWERCASE|translucency, fonttype)
		if sameteam then
			local health = plr.realmo.health
			local shield_health = (plr.realmo.shield_health ~= nil) and plr.realmo.shield_health or 0
			v.drawString(result.x, result.y + (offset2 * 2), "+" .. (health + shield_health), healthmap|translucency, fonttype)
		end
	end
end, "game", 1