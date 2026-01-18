local hudtype = "game"

local function DrawTooltips(v, player)
	local textflags = V_SNAPTOBOTTOM|V_SNAPTORIGHT|V_ALLOWLOWERCASE
	local x = 316
	local y = 189
	
	if CV_FindVar("showfps").value then
		y = $ - 8
	end
	
	local scalex = 11
	local scaley = 11
	local yoffset = -2
	v.drawFill(x-scalex, y+yoffset, scalex, scaley, 253+(V_SNAPTOBOTTOM|V_SNAPTORIGHT))
	v.drawString(x, y, "Run: C1", textflags, "thin-right")
end

return "Tooltips", DrawTooltips, (hudtype)