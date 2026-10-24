---@param v videolib
---@param player player_t
return "DamageText", function(v, player)
	if not player.ze2.damage_text then return end

	local position = ZE2.cv_damageindicator_position.value
    for index, indicator in ipairs(player.ze2.damage_text) do
		local cang = R_PointToAngle(indicator.x, indicator.y)
		local dist = R_PointToDist(indicator.x, indicator.y)

		local x = indicator.x
		local y = indicator.y
		local z = indicator.z
		if (position == 0) then
			z = z + (48 * FU)
		elseif (position == 1) then
			x = x - cos(cang - ANGLE_90) * 48
			y = y - sin(cang - ANGLE_90) * 48
			z = z - (4 * FU)
		elseif (position == 2) then
			x = x + cos(cang - ANGLE_90) * 48
			y = y + sin(cang - ANGLE_90) * 48
			z = z - (4 * FU)
		end

        local result = xS_GetScreenCoords(v, player, camera, {x = x, y = y, z = z})
		if not result or not result.onscreen then continue end

        local alpha = FU
		local font = ({[0] = "thin-fixed-center", "thin-fixed-right", "thin-fixed"})[position]
        if (indicator.time <= TICRATE) then
            alpha = FixedDiv(indicator.time * FU, TICRATE * FU)
        end

		if (dist > (1024 * FU)) and (v.width() >= 400) then
			font = ({[0] = "small-thin-fixed-center", "small-thin-fixed-right", "small-thin-fixed"})[position]
		end

        local realalpha = L_FadeAmount(alpha)
        v.drawString(result.x, result.y, indicator.damage, realalpha, font)
    end
end