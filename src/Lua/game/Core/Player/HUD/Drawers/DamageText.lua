---@param v videolib
---@param player player_t
return "DamageText", function(v, player)
	if not player.ze2.damage_text then return end

    for index, indicator in ipairs(player.ze2.damage_text) do
        local result = xS_GetScreenCoords(v, player, camera, {
			x = indicator.x,
			y = indicator.y,
			z = indicator.z
		})
		if not result or not result.onscreen then continue end

        local alpha = FU
        if (indicator.time <= TICRATE) then
            alpha = FixedDiv(indicator.time * FU, TICRATE * FU)
        end

        local realalpha = L_FadeAmount(alpha)
        v.drawString(result.x, result.y, indicator.damage, realalpha, "fixed-center")
    end
end