---@param v videolib
---@param player player_t
return "Markers", function(v, player)
    if player.spectator then return end

    for other in players.iterate do
        if other.spectator then continue end
        if (other.mo.team ~= player.mo.team) then continue end
        if (other.ze2.marker_tics <= 0) then continue end

        local result = xS_GetScreenCoords(v, player, camera, {
			x = other.ze2.marker_x,
			y = other.ze2.marker_y,
			z = other.ze2.marker_z
		})

		if not result or not result.onscreen then continue end

        local patch = v.cachePatch("Z_POINTTEAMC")
		local colormap = v.getColormap(nil, SKINCOLOR_WHITE)
		local scale = FU/2
		local xoffset = FixedMul(-(patch.width*FU/2), scale) 
		local ystringoffset = FixedMul(-8*FU, scale)
        --
        v.drawString(result.x, result.y + ystringoffset, "Defend Here!", V_ALLOWLOWERCASE|V_50TRANS, "small-thin-fixed-center")
		v.drawScaled(result.x + xoffset, result.y, scale, patch, V_50TRANS, colormap)
    end
end