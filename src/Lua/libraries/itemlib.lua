ZE2.ItemPresets = {

}

function ZE2:CreateItem(name,table)
	local temp_table
	if not name then
		error("Name not included.")
	end
	if type(name) ~= "string" then
		error("Arg1 is not a string.")
	end
	if not table then
		error("Table not found.")
	end
	if type(table) ~= "table" then
		error("Arg2 is not a table.")
	end
	temp_table = ZE2:Copy(table) -- temp_table is supposed to add extra info before shipping.

	temp_table.item_id = #self.ItemPresets + 1
	temp_table.displayname = name
	if temp_table.count then
		temp_table.maxcount = temp_table.count
	end
	
	if temp_table.ammo then
		temp_table.max_ammo = temp_table.ammo
	end
	
	local idname = ("ITEM_"..name:upper()):gsub(" ","_"):gsub("'","")
	local idglobal = rawset(_G, idname, #self.ItemPresets + 1)
	self.ItemPresets[#self.ItemPresets + 1] = temp_table
	
	print("\x84ZE2:".."\x82 Weapon ".."\""..name.." ("..idname..")".."\" included ["..(#self.ItemPresets).."]")
	return idglobal
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

function ZE2:CopyInventorySlot(player, slot)
	if player and player.valid and player.mo and player.mo.valid then
		if player["ze2_info"] and player["ze2_info"].inventory_selection then
			return ZE2:CopyItemInfo(ZE2:FetchInventory(player)[slot or player["ze2_info"].inventory_selection], player.mo.skin)
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

-- To support skin item overwrites.
-- Makes a copy of the iteminfo (hopefully i dont regret using this)

function ZE2:CopyItemInfo(iteminfo, skin)
	if iteminfo then
		if not (iteminfo.skin_overwrite and iteminfo.skin_overwrite[skin]) or not skin then
			return ZE2:Copy(iteminfo)
		else
			local modified = ZE2:Copy(iteminfo)
			local skin_overwrite = iteminfo.skin_overwrite[skin]
			
			for i,v in pairs(skin_overwrite) do
				modified[i] = v
			end
			
			modified.skin_overwrite = nil -- no trailing
			
			return modified
		end
	end
end

function ZE2:CopyItemFromID(item_id)
	local item = ZE2:Copy(ZE2.ItemPresets[item_id]) or error("Invalid item_id.")
	item.ontrigger = nil
	item.onspawn = nil
	item.onhit = nil

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