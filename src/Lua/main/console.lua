-- super specialized cvars wont show here.

SRBZ.survinvtics = CV_RegisterVar({
	name = "z_survinvtics",
	defaultvalue = "25",
	PossibleValue = {MIN = 0, MAX = 350},
	flags = CV_NETVAR,
})

SRBZ.server_intermissionmusic = CV_RegisterVar({
	name = "server_intermissionmusic",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

COM_AddCommand("z_giveitem", function(player, item_id, count, slot)
	if player.mo and player.mo.valid and player["srbz_info"] and SRBZ:FetchInventory(player) then
		if item_id then
			item_id = tonumber($)
		else
			CONS_Printf(player, "z_giveitem <item_id> <count> <slot>: gives an item to yourself.")
			return
		end

		if count then
			count = tonumber($)
		end

		if slot then 
			slot = tonumber($)
		end

		SRBZ:GiveItem(player,item_id,count,slot)
	end
end, COM_ADMIN)

COM_AddCommand("z_sellinventory", function(player)
	for i=1,player["srbz_info"].survivor_inventory_limit do
		if player["srbz_info"].survivor_inventory[i] and player["srbz_info"].survivor_inventory[i].price then
			local item_name = player["srbz_info"].survivor_inventory[i].displayname
			local item_cost = player["srbz_info"].survivor_inventory[i].price
			local item_count 
			local item_maxcount
			if player["srbz_info"].survivor_inventory[i].count then
				item_count = player["srbz_info"].survivor_inventory[i].count
				item_maxcount = player["srbz_info"].survivor_inventory[i].maxcount
			end
			if item_count and item_maxcount then
				item_cost = (item_cost*item_count)/item_maxcount
			end
			item_cost = ($*3)/4 -- Give only 75% back.
			
			local toprint = string.format("%s sold for \x85%s Rubies. (75 percent given back)",item_name,tostring(item_cost))
			
			CONS_Printf(player,toprint)
			
			player.rubies = $ + item_cost
		end
	end
	player["srbz_info"].survivor_inventory = {
		SRBZ:CopyItemFromID(ITEM_RED_RING)
	}
	player["srbz_info"].zombie_inventory = {
		SRBZ:CopyItemFromID(ITEM_INSTA_BURST)
	}
	CONS_Printf(player, "\x85".."Cleared inventory!")
end)

COM_AddCommand("z_sellhand", function(player)
	local inventory 
	if player.zteam == 1 then
		inventory = player["srbz_info"].survivor_inventory
	elseif player.zteam == 2 then
		inventory = player["srbz_info"].zombie_inventory
	end
	local inventory_slot = inventory[player["srbz_info"].inventory_selection]
	if inventory_slot and inventory_slot.price then -- Sellable
		local item_name = inventory[player["srbz_info"].inventory_selection].displayname
		local item_cost = inventory[player["srbz_info"].inventory_selection].price
		local item_count 
		local item_maxcount
		if inventory[player["srbz_info"].inventory_selection].count then
			item_count = inventory[player["srbz_info"].inventory_selection].count
			item_maxcount = inventory[player["srbz_info"].inventory_selection].maxcount
		end
		if item_count and item_maxcount then
			item_cost = (item_cost*item_count)/item_maxcount
		end
		
		item_cost = ($*3)/4 -- Give only 75% back.
		
		local toprint = string.format("%s sold for \x85\%s Rubies. (75 percent given back)",item_name,tostring(item_cost))
		
		CONS_Printf(player,toprint)
		
		table.remove(inventory, player["srbz_info"].inventory_selection)
		
		player.rubies = $ + item_cost
		
	elseif inventory_slot and not inventory_slot.price then -- Unsellable but has slot
		CONS_Printf(player, "\x85\This item is unsellable!")
	else -- Nothing in slot at all
		CONS_Printf(player, "\x85\Blank inventory slot!")
	end
end)
