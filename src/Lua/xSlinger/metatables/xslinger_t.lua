local getLambdaObject = xSlinger.getLambdaObject

-- obj.xSlinger.func(a,b,c)
local funcs = {
	["inv_add"] = function(self, name, size)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local list = {}
		
		list.size = tonumber(size)
		
		for i=1,list.size do
			list[i] = xSlinger.new("")
		end
		
		xS.inventory[name] = list
	end;
	["inv_remove"] = function(self, name)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		
		if name ~= "main" then
			xS.inventory[name] = nil
		end
	end;
	["inv_clear"] = function(self, name)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(name)
		
		for i=1,#inv do
			inv[i] = xSlinger.new("")
		end
	end;
	["inv_get"] = function(self, name, strict)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local current_inventory = name or xS.current_inventory
		
		if xS.inventory[current_inventory] then
			return xS.inventory[current_inventory]
		else
			if strict then
				error("Invalid Inventory: "..current_inventory)
			end
			
			return nil
		end
	end;
	["inv_set"] = function(self, name, strict)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		
		if xS.inventory[name] then
			xS.current_inventory = name
			xS.slot = 1
			
			return xS.inventory[name]
		else
			if strict then
				error("Invalid Inventory: "..tostring(name))
			end
			
			return nil
		end
	end;
	["inv_resize"] = function(self, name, size)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(name)

		if #inv > size then
			for i=#inv, size+1, -1 do
				inv[i] = nil
			end
		elseif #inv < size then
			for i=#inv+1,size do
				inv[i] = xSlinger.new("")
			end
		end
		
		inv.size = tonumber(size)
	end;
	["hand"] = function(self)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local slotnum = xS.slot
		local inv = xS:inv_get()
		
		return inv[slotnum]
	end;
	["hand_clear"] = function(self)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local slotnum = xS.slot
		local inv = xS:inv_get()
		
		inv[slotnum] = xSlinger.new("")
	end;
	["hand_drop"] = function(self)
	
	end;
	["slot_clear"] = function(self, slotnum, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		
		inv[slotnum] = xSlinger.new("")
	end;
	["slot_get"] = function(self, slotnum, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		
		return inv[slotnum]
	end;
	["slot_set"] = function(self, slotnum, item_name, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		
		inv[slotnum] = xSlinger.new(item_name)
	end;
	["slot_drop"] = function(self, slotnum, target_inv)
	
	end;
	
	-- other
	
	["find_empty_slot_number"] = function(self, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		
		for i=1,inv.size do
			if inv[i].id == "" then
				return i
			end
		end
	end;
	["give_item"] = function(self, item_name, count, slotnum, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		local itemref = xSlinger.new(item_name)
		local remainder = 0
		local ranout = false

		count = tonumber($)
		
		if count ~= nil and count < 0 then
			return
		end

		if item_name == "" then
			return
		end

		if itemref.count ~= -1 and not count then
			count = itemref.count
		end
		
		remainder = count
		
		if itemref.count ~= -1 then
			local newitems = {}
			-- fill existing slots
			for i,slot in ipairs(inv) do
				if (slot.id == itemref.id) and (slot.id ~= "") then
					local slotcountleft = slot.maxcount - slot.count
					
					if remainder <= slotcountleft then
						slot.count = $ + remainder
						remainder = 0
						break
					else
						remainder = $ - slotcountleft
						slot.count = slot.maxcount
					end
				end
			end
			
			-- fill empty slots
			local empty_slot_num = xS:find_empty_slot_number(target_inv)
			while empty_slot_num and remainder > 0 do
				local slot
				inv[empty_slot_num] = xSlinger.new(item_name)
				
				slot = inv[empty_slot_num] -- set ref
				
				newitems[#newitems + 1] = slot
				
				slot.count = 0
				
				if remainder > slot.maxcount then
					remainder = $ - slot.maxcount
					slot.count = slot.maxcount
				else
					slot.count = remainder
					remainder = 0
					break
				end
			
				empty_slot_num = xS:find_empty_slot_number(target_inv)
			end
			
			return newitems, remainder
		else
		
			local empty_slot_num = xS:find_empty_slot_number(target_inv)
			if empty_slot_num then
				inv[empty_slot_num] = xSlinger.new(item_name)
				return inv[new_slot_num]
			else
				return false
			end
		end
		
		--print(remainder)
	end;
}

xSlinger.METATABLES.add("MAIN", {
	__index = function(a,k)
		if funcs[k] then
			return funcs[k]
		end
	end
})