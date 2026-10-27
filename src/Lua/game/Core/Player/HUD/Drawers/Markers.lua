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

        local patch = v.cachePatch("Z_PMARKER")
        v.drawScaled(result.x, result.y, FU / 2, patch, 0, nil)
        --v.drawString(result.x, result.y, "Marker!", V_ALLOWLOWERCASE, "fixed-center")
    end
end