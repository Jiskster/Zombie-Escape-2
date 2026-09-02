local drawString

local function Tools_HUD(v, player)
	if not ZE2.cv_debug.value then return end
	if not IsPlayerAdmin(player) and (player ~= server) then return end
    if (drawString == nil) then drawString = v.drawString end

	drawString(320, 25, "\x82" .. "Debug Enabled", V_SNAPTORIGHT|V_SNAPTOTOP|V_ADD|V_ALLOWLOWERCASE|V_PERPLAYER, "thin-right")

	local spacing = 5
	local text_x = 6
	local text_y = 105
	local text_flags = V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE
	local text_align = "small"
	if (#ZE2.Checkpoints > 0) then
		drawString(text_x, text_y, "\x82" .. "Teleport to checkpoints with:", text_flags, text_align)
		drawString(text_x, text_y + spacing, "zd_nextcheckpoint", text_flags, text_align)
		drawString(text_x, text_y + (spacing * 2), "zd_prevcheckpoint", text_flags, text_align)
		drawString(text_x, text_y + (spacing * 4), "\x82" .. "Checkpoint " .. (player.ze2.checkpoint_number or "0") .. " of " .. #ZE2.Checkpoints, text_flags, text_align)
	else
		drawString(text_x, text_y, "No checkpoints to teleport", text_flags|V_REDMAP, text_align)
	end
end

return "ZE2Tools", Tools_HUD, "game", 2