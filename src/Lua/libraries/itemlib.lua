ZE2.ItemPresets = {

}

function ZE2:CreateItem(name,input_table)
	local temp_table
	if not name then
		error("Name not included.")
	end
	if type(name) ~= "string" then
		error("Arg1 is not a string.")
	end
	if not input_table then
		error("Table not found.")
	end
	if type(input_table) ~= "table" then
		error("Arg2 is not a table.")
	end
	temp_table = ZE2:Copy(input_table) -- temp_table is supposed to add extra info before shipping.

	temp_table.item_id = #self.ItemPresets + 1
	temp_table.displayname = name
	if temp_table.count then
		temp_table.maxcount = temp_table.count
	end
	
	if temp_table.ammo then
		temp_table.max_ammo = temp_table.ammo
	end
	
	local idname = ("ITEM_"..name:upper()):gsub(" ","_"):gsub("'","")
	local idglobal 
	table.insert(self.ItemPresets, temp_table) -- Push new item
	rawset(_G, idname, #self.ItemPresets) -- Define Item Global
	
	print("\x84ZE2:".."\x82 Item ".."\""..name.." ("..idname..")".."\" included ["..(#self.ItemPresets).."]")
	return #self.ItemPresets -- Item ID
end


function ZE2:FetchInventory(player)
	if player and player.valid then
		if player["ze2_info"] then
			if player["ze2_info"].survivor_inventory and player["ze2_info"].team == 1 then
				return player["ze2_info"].survivor_inventory
			elseif player["ze2_info"].zombie_inventory and player["ze2_info"].team == 2 then
				return player["ze2_info"].zombie_inventory
			else
				return player["ze2_info"].survivor_inventory
			end
		end
	end
end

function ZE2:FetchInventoryLimit(player)
	if player and player.valid then
		if player["ze2_info"] then
			if player["ze2_info"].team == 1 then
				return player["ze2_info"].survivor_inventory_limit
			elseif player["ze2_info"].team == 2 then
				return player["ze2_info"].zombie_inventory_limit
			end
		end
	end
	return 1
end

function ZE2:FetchInventorySlot(player, slot)
	if player and player.valid then
		if player["ze2_info"] and player["ze2_info"].inventory_selection then
			return ZE2:FetchInventory(player)[slot or player["ze2_info"].inventory_selection] 
		end
	end
end

function ZE2:IsInventoryFull(player)
	if player and player.valid then
		if player["ze2_info"] and ZE2:FetchInventory(player) then
			if #ZE2:FetchInventory(player) >= ZE2:FetchInventoryLimit(player) then
				return true
			else
				return false
			end
		else
			return true
		end
	end
end

function ZE2:GetItemInfoIndex(iteminfo, index, skin, real)
	if iteminfo then
		if not (iteminfo.skin_overwrite and iteminfo.skin_overwrite[skin]) or not skin and index then -- no overwrite or no skin, has index
			if iteminfo[index] ~= nil then
				return iteminfo[index]
			else
				return nil
			end
		elseif index then
			if skin and iteminfo.skin_overwrite[skin][index] ~= nil and not real then
				return iteminfo.skin_overwrite[skin][index]
			elseif iteminfo[index] ~= nil then
				return iteminfo[index]
			else
				return nil
			end
		end
	else
		return nil
	end
end

function ZE2:SetItemInfoIndex(iteminfo, index, value, skin, real)
	if iteminfo then
		if value ~= nil then
			if not (iteminfo.skin_overwrite and iteminfo.skin_overwrite[skin]) or not skin and index then -- no overwrite or no skin, has index
				if iteminfo[index] ~= nil then
					iteminfo[index] = value
				end
			elseif index then
				if skin and iteminfo.skin_overwrite[skin][index] ~= nil and not real then
					iteminfo.skin_overwrite[skin][index] = value
				elseif iteminfo[index] ~= nil then
					iteminfo[index] = value
				end
			end
		end
	else
		return nil
	end
end

function ZE2:CopyItemFromID(item_id)
	local item = ZE2:Copy(ZE2.ItemPresets[item_id]) or error("Invalid item_id.")
	item.ontrigger = nil
	item.onspawn = nil
	item.onhit = nil
	item.thinker = nil

	return item
end

function ZE2:GiveItem(player, item_id, count, slot) 
	if player and player.valid then
		if not item_id or not ZE2.ItemPresets[item_id] then
			CONS_Printf(player, "\x85\Invalid item! ["..item_id.."]")
		elseif player["ze2_info"] and ZE2:FetchInventory(player) then
			local item = ZE2:Copy(ZE2.ItemPresets[item_id])

			--destroy functions
			item.ontrigger = nil
			item.onspawn = nil
			item.onhit = nil
			item.thinker = nil
			
			if count ~= nil then
				item.count = count
				item.limited = true
			end
			if slot then
				ZE2:FetchInventory(player)[slot] = item
			else
				if not ZE2:IsInventoryFull(player) then
					table.insert(ZE2:FetchInventory(player), item)
				else
					CONS_Printf(player, "\x85\Inventory full!")
				end
			end
		elseif not ZE2:FetchInventory(player) then
			CONS_Printf(player, "\x85\Invalid inventory!")
		end
	end
end