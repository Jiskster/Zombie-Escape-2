return "Shop", function(v, player)
	if not player.ze2.pregamemenu_active then
		return
	end
	
	if player.ze2.pregamemenu_type ~= 3 then 
        return 
    end
	if not #ZE2.Survivor_ShopList then 
        return
    end

    local w = 100
    local h = 30

    local x = 320 - w - 10
    local y = 16

    local spacing = 5

    local selection = player.ze2.shop_selection

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
        local shoplist = ZE2.Survivor_ShopList
        local inx = ZE2.Survivor_ShopList[i]
        local shopdefid = inx.shopdefid
        local shop_def = ZE2.NumToShopDef(shopdefid)
        local iteminfo = shop_def.iteminfo
        local price = "$UNKNOWN"
        local price_color = V_GREENMAP
        local scale = FU

        -- Set Display Data
        if shop_def then
            if iteminfo and iteminfo.icon then
                if iteminfo.displayname then
                    displayname = iteminfo.displayname
                end

                if iteminfo.icon then
                    scale = FixedMul($, iteminfo.iconscale or FU)
                    patch = v.cachePatch(iteminfo.icon)
                end
            elseif shop_def.icon then
                scale = FixedMul($, shop_def.iconscale or FU)
                patch = v.cachePatch(shop_def.icon)
            end

            if shop_def.price then
                price = "$"..shop_def.price
            end
        end

        if inx.sold then
            price = "SOLD!"
            price_color = V_REDMAP
        end
        
        -- Dark Blue Background
        v.drawFill(x, y + o, w, h, 159 + V_SNAPTORIGHT)

        -- Price Background
        local small_width = w/2
        local small_height = h/4
        v.drawFill(x + (w/2) - ((small_width)/2), y + o + (h - 4), small_width, small_height, 157 + V_SNAPTORIGHT)

        -- Price
        v.drawString(x + (w/2), y + o + (h - 4) + 1, price, V_SNAPTORIGHT|price_color, "thin-center")

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

        -- Item Icon + Blank Item Background
        v.drawScaled(x*FU, (y*FU) + (o*FU), FU, blankpatch, V_SNAPTORIGHT) -- bg

        v.drawScaled(x*FU, (y*FU) + (o*FU), scale, patch, V_SNAPTORIGHT)
    end
end