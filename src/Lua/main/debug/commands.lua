COM_AddCommand("zd_refreshitems", function ()
    for p in players.iterate do
        if not p["ze2_info"] then continue end
        local inventory = p["ze2_info"].survivor_inventory
        if inventory then
            for i=1,#inventory do
                if inventory[i] then
                    inventory[i] = ZE2:CopyItemFromID(inventory[i].item_id)
                end
            end
        end
    end
end, 1)