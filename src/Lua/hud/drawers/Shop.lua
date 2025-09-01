return "Shop", function(v, player)
	if not player.ze2.pregamemenu_active then
		return
	end
	
	if player.ze2.pregamemenu_type ~= 3 then return end
	if not #ZE2.Survivor_ShopList then return end

    local w = 100
    local h = 30

    local x = 320 - w - 10
    local y = 16

    local spacing = 5

    local selection = 1

    -- Black Background (Transparent)
    v.drawFill(200, -120, 640, 640, 31 + V_SNAPTORIGHT + V_50TRANS)

    -- "Shop" Text
    v.drawString(x + (w/2), y - 12, "Shop", V_SNAPTORIGHT, "center")

    for i=1,5 do
        local o = ((i-1)*(h)) + ((i-1)*(spacing))
        local patch = v.cachePatch("RINGIND")
        local blankpatch = v.cachePatch("BLANKIND")
        local displayname = "Red Ring"
        local stock = 1
        
        -- Dark Blue Background
        v.drawFill(x, y + o, w, h, 159 + V_SNAPTORIGHT)

        -- Price Background
        local small_width = w/2
        local small_height = h/4
        v.drawFill(x + (w/2) - ((small_width)/2), y + o + (h - 4), small_width, small_height, 157 + V_SNAPTORIGHT)

        -- Price
        v.drawString(x + (w/2), y + o + (h - 4) + 1, "$9999", V_SNAPTORIGHT|V_GREENMAP, "thin-center")

        -- Stock
        v.drawString(x + (w), y + o - 4, "x1", V_SNAPTORIGHT|V_SKYMAP|V_ALLOWLOWERCASE, "thin-center")

        -- White Bar - Separater
        v.drawFill(x + 1, y + o + 16, w - 2, 1, 0 + V_SNAPTORIGHT)

        -- Shop Selection
        if i == selection then
            v.drawFill(x - 4, y + o, 1, h, 0 + V_SNAPTORIGHT)
        end

        -- Item Name (16 character limit)
        v.drawString(x + 20, y + o + 4, displayname:sub(1,16), V_SNAPTORIGHT|V_ALLOWLOWERCASE, "thin")


        -- Item Icon + Blank Background
        v.draw(x, y + o, blankpatch, V_SNAPTORIGHT) -- bg

        v.draw(x, y + o, patch, V_SNAPTORIGHT)
    end
end