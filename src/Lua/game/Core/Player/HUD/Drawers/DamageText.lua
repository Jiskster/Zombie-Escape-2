---@param v videolib
---@param player player_t
return "DamageText", function(v, player)
	if not player.ze2.damage_text then return end

    for index, indicator in ipairs(player.ze2.damage_text) do
		local cang = R_PointToAngle(indicator.x, indicator.y)
		local dist = R_PointToDist(indicator.x, indicator.y)
        local result = xS_GetScreenCoords(v, player, camera, {
			x = indicator.x + cos(cang - ANGLE_90)*48 ,
			y = indicator.y + sin(cang - ANGLE_90)*48 ,
			z = indicator.z
		})
		if not result or not result.onscreen then continue end

        local alpha = FU
		local font = "thin-fixed"
        if (indicator.time <= TICRATE) then
            alpha = FixedDiv(indicator.time * FU, TICRATE * FU)
        end
		
		if (dist > 1024*FU) and v.width() >= 400 then
			font = "small-thin-fixed"
		end

        local realalpha = L_FadeAmount(alpha)
        v.drawString(result.x, result.y - 4*FU, indicator.damage, realalpha, font)
    end
end