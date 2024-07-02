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
	if temp_table.count and temp_table.max_count == nil then
		temp_table.max_count = temp_table.count
	end
	
	if temp_table.ammo and temp_table.max_ammo == nil then
		temp_table.max_ammo = temp_table.ammo
	end
	
	temp_table.firerate_left = 0
	
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

-- returns number
function ZE2:FetchEmptySlot(player)
	for i=1,ZE2:FetchInventoryLimit(player) do
		if not ZE2:FetchInventory(player)[i] then
			return i
		end	
	end
	
	return false
end

function ZE2:GetInventoryItemFromId(player, item_id)
	local found
	local found_slot
	
	for i=1,ZE2:FetchInventoryLimit(player) do
		if ZE2:FetchInventory(player)[i] and ZE2:FetchInventory(player)[i].item_id
		and ZE2:FetchInventory(player)[i].item_id == item_id then
			found = ZE2:FetchInventory(player)[i]
			found_slot = i
			
			return found, found_slot
		end
	end
		
	return false
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

-- iteminfo can be number or table
function ZE2:GiveItem(player, item_input, count, slot) 
	local datatype = type(item_input)
	local isTable = datatype == "table"
	local isNumber = datatype == "number"
	
	if player and player.valid then
		if not item_input or (isTable and item_input and not item_input.item_id) 
		or (isNumber and item_input and not ZE2.ItemPresets[item_input]) then
			return false
		elseif player["ze2_info"] and ZE2:FetchInventory(player) then
			local item
	
			if isNumber then
				item = ZE2:Copy(ZE2.ItemPresets[item_input])
			elseif isTable then
				item = ZE2:Copy(item_input)
			else
				error("Invalid Type")
			end
			
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
				return true
			else
				local real_count = count or item.count
			
				if not ZE2:IsInventoryFull(player) then
					local item_id
					
					if isNumber then
						item_id = item_input
					elseif isTable then
						item_id = item_input.item_id
					end
					
					local fitem,fslot = ZE2:GetInventoryItemFromId(player, item_id) --print(fitem,fslot)

					if fitem and fitem.count and fitem.count + real_count <= fitem.max_count then
						ZE2:FetchInventory(player)[fslot].count = $ + real_count
						--print("Added apon exiting item")
					elseif ZE2:FetchEmptySlot(player) then
						local emptyslot = ZE2:FetchEmptySlot(player) 
						
						if emptyslot then
							ZE2:FetchInventory(player)[emptyslot] = item
							--print("Went to empty slot")
						end
					end
					
					return true
				else
					CONS_Printf(player, "\x85\Inventory full!")
					return false
				end
			end
		elseif not ZE2:FetchInventory(player) then
			CONS_Printf(player, "\x85\Invalid inventory!")
			return false
		end
		
		return false
	end
end