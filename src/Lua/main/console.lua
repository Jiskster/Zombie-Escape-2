-- super specialized cvars wont show here.

ZE2.survinvtics = CV_RegisterVar({
	name = "z_survinvtics",
	defaultvalue = "30",
	PossibleValue = {MIN = 0, MAX = 350},
	flags = CV_NETVAR,
})

ZE2.instantinfection = CV_RegisterVar({
	name = "z_instantinfection",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.server_intermissionmusic = CV_RegisterVar({
	name = "server_intermissionmusic",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.server_showteamchat = CV_RegisterVar({
	name = "server_showteamchat",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.repeatshopitems = CV_RegisterVar({
	name = "z_repeatshopitems",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killwhenchosen = CV_RegisterVar({
	name = "z_killwhenchosen",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.choosenotice = CV_RegisterVar({
	name = "z_choosenotice",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killenemiesonwin = CV_RegisterVar({
	name = "z_killenemiessonwin",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killzombiesonwin = CV_RegisterVar({
	name = "z_killzombiesonwin",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.landingfatigue = CV_RegisterVar({
	name = "z_landingfatigue",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

COM_AddCommand("z_giveitem", function(player, item_id, count, slot)
	if player.mo and player.mo.valid and player["ze2_info"] and ZE2:FetchInventory(player) then
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

		ZE2:GiveItem(player,item_id,count,slot)
	end
end, COM_ADMIN)

COM_AddCommand("z_sellinventory", function(player)
	for i=1,player["ze2_info"].survivor_inventory_limit do
		if player["ze2_info"].survivor_inventory[i] and player["ze2_info"].survivor_inventory[i].price then
			local item_name = player["ze2_info"].survivor_inventory[i].displayname
			local item_cost = player["ze2_info"].survivor_inventory[i].price
			local item_count 
			local item_maxcount
			if player["ze2_info"].survivor_inventory[i].count then
				item_count = player["ze2_info"].survivor_inventory[i].count
				item_maxcount = player["ze2_info"].survivor_inventory[i].max_count
			end
			if item_count and item_maxcount then
				item_cost = (item_cost*item_count)/item_maxcount
			end
			item_cost = ($*3)/4 -- Give only 75% back.
			
			local toprint = string.format("%s sold for \x85%s Rubies. (75 percent given back)",item_name,tostring(item_cost))
			
			CONS_Printf(player,toprint)
			
			player["ze2_info"].cash = $ + item_cost
		end
	end
	player["ze2_info"].survivor_inventory = {
		ZE2:CopyItemFromID(ITEM_RED_RING)
	}
	player["ze2_info"].zombie_inventory = {
		ZE2:CopyItemFromID(ITEM_INSTA_BURST)
	}
	CONS_Printf(player, "\x85".."Cleared inventory!")
end)

COM_AddCommand("z_sellhand", function(player)
	local inventory 
	if player["ze2_info"].team == 1 then
		inventory = player["ze2_info"].survivor_inventory
	elseif player["ze2_info"].team == 2 then
		inventory = player["ze2_info"].zombie_inventory
	end
	local inventory_slot = inventory[player["ze2_info"].inventory_selection]
	if inventory_slot and inventory_slot.price then -- Sellable
		local item_name = inventory[player["ze2_info"].inventory_selection].displayname
		local item_cost = inventory[player["ze2_info"].inventory_selection].price
		local item_count 
		local item_maxcount
		if inventory[player["ze2_info"].inventory_selection].count then
			item_count = inventory[player["ze2_info"].inventory_selection].count
			item_maxcount = inventory[player["ze2_info"].inventory_selection].max_count
		end
		if item_count and item_maxcount then
			item_cost = (item_cost*item_count)/item_maxcount
		end
		
		item_cost = ($*3)/4 -- Give only 75% back.
		
		local toprint = string.format("%s sold for \x85\%s Cash. (75 percent given back)",item_name,tostring(item_cost))
		
		CONS_Printf(player,toprint)
		
		table.remove(inventory, player["ze2_info"].inventory_selection)
		
		player["ze2_info"].cash = $ + item_cost
		
	elseif inventory_slot and not inventory_slot.price then -- Unsellable but has slot
		CONS_Printf(player, "\x85\This item is unsellable!")
	else -- Nothing in slot at all
		CONS_Printf(player, "\x85\Blank inventory slot!")
	end
end)

COM_AddCommand("z_giveshield", function(player, shieldtype)
	if not (player.mo and player.mo.valid) then return end
	if (shieldtype == nil or tonumber(shieldtype) == nil) then return end
	
	if tonumber(shieldtype) <= 0 then
		CONS_Printf(player, "\x82\Cleared shield!")
		ZE2:RemoveShieldFromMobj(player.mo)
		return
	end
	
	if not ZE2:GiveShieldToMobj(player.mo, tonumber(shieldtype)) then
		CONS_Printf(player, "\x85\Invalid shieldtype!")
		return
	end
end, COM_ADMIN)

COM_AddCommand("z_swapitem", function(player, slot1, slot2)
	local help = "z_swapitem <slot1> <slot2>"
	
	local slot1_item
	local slot2_item

	if not (slot1) or not (slot2) then
		CONS_Printf(player, help)
		return
	elseif not tonumber(slot1) or not tonumber(slot2) then
		CONS_Printf(player, help)
		return
	end
	
	slot1 = tonumber($)
	slot2 = tonumber($)
	
	if slot1 > ZE2:FetchInventoryLimit(player) or slot1 <= 0 then
		CONS_Printf(player, "Slot 1 is not a valid number in range.")
		return
	end
	
	if slot2 > ZE2:FetchInventoryLimit(player) or slot2 <= 0 then
		CONS_Printf(player, "Slot 2 is not a valid number in range.")
		return
	end
	
	if slot1 == slot2 then
		CONS_Printf(player, "Slot 1 and 2 cannot be the same number")
		return
	end
	
	slot1_item = ZE2:Copy(ZE2:FetchInventorySlot(player, slot1))
	slot2_item = ZE2:Copy(ZE2:FetchInventorySlot(player, slot2))

	ZE2:ClearInventorySlot(player, slot1)
	ZE2:ClearInventorySlot(player, slot2)
	
	if slot2_item then
		ZE2:GiveItem(player, slot2_item, nil, slot1)
	else
		ZE2:ClearInventorySlot(player, slot1)
	end
	
	if slot1_item then
		ZE2:GiveItem(player, slot1_item, nil, slot2)
	else
		ZE2:ClearInventorySlot(player, slot2)
	end
end)