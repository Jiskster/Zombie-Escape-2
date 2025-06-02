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
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.sourcemovement = CV_RegisterVar({
	name = "z_sourcemovement",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.cv_debug = CV_RegisterVar({
	name = "z_debug",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

COM_AddCommand("z_giveitem", function(player, item_id, slot, count)
	if player.mo and player.mo.valid and ZE2:FetchInventory(player) then
		if not item_id then
			CONS_Printf(player, "z_giveitem <item_id> <slot> <count>: gives an item to yourself.")
			return
		else
			print(item_id)
		end

		if slot then 
			slot = tonumber($)
		end
		
		if count then
			count = tonumber($)
		end

		ZE2:GiveItem(player,item_id,count,slot)
	end
end, COM_ADMIN)

COM_AddCommand("z_changeztype", function(player, new_ztype)
	if not (player.mo and player.mo.valid) then return end
	if player.ze2.team ~= 2 then
		print("You must be a zombie to run this command.")
		return
	end
	
	if not new_ztype then
		print("z_changeztype <ztype>: changes your zombie type.")
		return
	end
	
	local zc = ZE2.ZombieConfig
	
	if zc[new_ztype] then
		player.ze2.zombie_type = new_ztype
		ZE2.ResetPlayer(player)
	else
		print("Invalid ztype. "..'"'..new_ztype..'"')
	end
end, 1)

COM_AddCommand("z_giveshield", function(player, shieldtype)
	if not (player.mo and player.mo.valid) then return end
	if (shieldtype == nil or tonumber(shieldtype) == nil) then return end
	
	if tonumber(shieldtype) <= 0 then
		CONS_Printf(player, "\x82\Cleared shield!")
		ZE2:RemoveShieldFromMobj(player.mo)
		return
	end
	
	ZE2:RemoveShieldFromMobj(player.mo)
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