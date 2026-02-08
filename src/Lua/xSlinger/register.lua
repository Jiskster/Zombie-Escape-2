function xSlinger.registerItem(itemid, itemtable)
	if (type(itemid) ~= "string") then
		return error("itemid (arg1) is not a string. Got: "..type(itemid))
	end
	
	if (type(itemtable) ~= "table") then
		return error("itemid (arg2) is not a table. Got: "..type(itemtable))
	end
	
	if xSlinger.registered_items[itemid] then
		return error("itemid (arg2) alredy exists. Got: "..itemid)
	end
	
	-- Automatically set max variables
	if not itemtable.maxammo and itemtable.ammo then
		itemtable.maxammo = itemtable.ammo
	elseif not itemtable.maxcount and itemtable.count then
		itemtable.maxcount = itemtable.count
	end

	-- Add missing fallback iteminfo variables.
	local fallback_item = xSlinger.registered_items[-1]

	for entry,value in pairs(fallback_item) do
		if itemtable[entry] == nil then -- if entry in fallback_item but not in itemtable
			itemtable[entry] = xSlinger.deepcopy(value) -- place default value
		end
	end
	
	itemtable.id = itemid
	
	xSlinger.registered_items[itemid] = itemtable
	table.insert(xSlinger.registered_items_ordered, itemtable)
	
	return itemid, itemtable
end

function xSlinger.new(itemid)
	local item
	
	if (type(itemid) ~= "string") then
		return error("itemid (arg1) is not a string. Got: "..type(itemid))
	end
	
	if not xSlinger.registered_items[itemid] then
		item = xSlinger.deepcopy(xSlinger.registered_items[-1])
		setmetatable(item, xSlinger.METATABLES.ITEMINFO)
		
		print("Invalid item: "..itemid)
		return item
		--return error("itemid (arg1) doesn't exist. Got: "..tostring(itemid))
	end
	
	item = xSlinger.deepcopy(xSlinger.registered_items[itemid])
	
	for i,v in pairs(item) do
		if type(v) == "function" then
			item[i] = nil
		end
	end
	
	setmetatable(item, xSlinger.METATABLES.ITEMINFO)
	
	return item
end

function xSlinger.clearRegisteredItems()
	xSlinger.registered_items = {}
end