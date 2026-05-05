local drawString

local Tools_HUD = function(v, p)
	if not (ZE2.cv_debug.value and (IsPlayerAdmin(p) or p == server)) then return end
    if drawString == nil then drawString = v.drawString end

	local spacing=5
	local bx, by, bflags = 320, 15, V_SNAPTORIGHT|V_SNAPTOTOP|V_ADD|V_ALLOWLOWERCASE|V_PERPLAYER

	-- Draw ZE2 Tools information
	drawString(bx, by, "\130ZE2 Tools Enabled", bflags, "thin-right")

	-- Teleport commands
	local tp_x = 6
	local tp_y = 105
	local tp_flags = V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM
	local align = "small"

	if #ZE2.Checkpoints then
		drawString(tp_x, tp_y, "\130Teleport to checkpoints with:", tp_flags, align)
		drawString(tp_x, tp_y+spacing, "zd_nextcheckpoint", tp_flags, align)
		drawString(tp_x, tp_y+(spacing*2), "zd_prevcheckpoint", tp_flags, align)
	else
		drawString(tp_x, tp_y, "No checkpoints to teleport", tp_flags|V_REDMAP, align)
	end
end

return "ZE2Tools", Tools_HUD, "game", 2