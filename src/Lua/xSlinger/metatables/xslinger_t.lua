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
	["hand_drop"] = function(self, force)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local slotnum = xS.slot
		local inv = xS:inv_get()
		local mo = xS.mo
		local iteminfo = inv[slotnum]
		if iteminfo.id ~= "" then
			if iteminfo:getIndex("single_drop", mo.skin) then
				return xS:toss_item()
			end
		end
		return xS:slot_drop(slotnum, force)
	end;
	["toss_item"] = function(self)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local slotnum = xS.slot
		local inv = xS:inv_get()
		local mo = xS.mo
		local iteminfo = inv[slotnum]
		if iteminfo.id ~= "" then
			if iteminfo:getIndex("droppable", mo.skin) then
				iteminfo.count = iteminfo.count - 1
				if (iteminfo.count <= 0) then
					xS:slot_clear(slotnum)
				end

				local mobj, i_obj = xSlinger.SpawnItemDrop(mo, iteminfo.id)
				mobj.iteminfo.count = 1
				
				return mobj, i_obj
			end
		end
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
	["slot_drop"] = function(self, slotnum, force, target_inv)
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		local mo = xS.mo
		local iteminfo = inv[slotnum]

		-- force = 1: If not droppable, then dissapear.
		-- force = 2: Drop even if not droppable.

		if iteminfo.id ~= "" then
			if iteminfo:getIndex("droppable", mo.skin)
			or force == 2 then
				local mobj = xSlinger.SpawnItemDrop(mo, iteminfo)
				xS:slot_clear(slotnum, target_inv)
				return mobj
			elseif force == 1 then
				xS:slot_clear(slotnum, target_inv)
			end
		end
	end;

	["give_item"] = function(self, stack, count, slotnum, target_inv)
		-- stack: itemstack_t / string
		-- count: number
		-- slotnum: number
		-- target_inv: string
		
		-- TODO: Condense some of this code.
	
		local obj = getLambdaObject(self)
		local xS = obj.xSlinger
		local inv = xS:inv_get(target_inv)
		local hand = xS:hand()
		local mo = xS.mo
		
		local remainder = 0
		
		if not stack then
			error("missing argument 1")
		end
		
		local newstack 
		
		if type(stack) == "string" then
			newstack = xSlinger.new(stack)
		elseif type(stack) == "table" then
			newstack = stack
		else
			error("invalid itemstack datatype")
		end
		
		local maxcount = (newstack.maxcount)
		local hasCount = (maxcount > -1)
		if (not hasCount) then
			local itemdrop
			
			-- Look for empty slots
			local foundslot
			local full = true
			for i = 1, #inv do
				if inv[i].id == "" then
					full = false
					foundslot = i
					break
				end
			end
			
			if foundslot and not slotnum then
				inv[foundslot] = newstack
			else
				if not slotnum then
					itemdrop = xSlinger.SpawnItemDrop(mo, newstack)
				else
					if inv[slotnum].id ~= "" then -- not empty
						itemdrop = xSlinger.SpawnItemDrop(mo, inv[slotnum])
					end
					
					inv[slotnum] = newstack
				end
			end
			
			return {newstack, dropped = itemdrop}
		else
			remainder = count or 1
			
			if remainder > 0 then
				for i = 1, #inv do
					if inv[i].id == "" then
						if remainder > maxcount then
							inv[i] = xSlinger.new(newstack.id)
							inv[i]:set("count", maxcount, mo.skin)
							
							remainder = $ - maxcount
						else
							inv[i] = xSlinger.new(newstack.id)
							inv[i]:set("count", remainder, mo.skin)
							
							remainder = 0
							break
						end
					elseif inv[i].id == newstack.id then
						local slotcount = inv[i]:get("count", mo.skin)
						
						if slotcount < maxcount then
							local diff = (maxcount - slotcount) -- how many count left
							
							if remainder > diff then
								inv[i]:set("count", maxcount, mo.skin)
								
								remainder = $ - diff
							else
								inv[i]:change("count", remainder, mo.skin)
								
								remainder = 0
								break
							end
						end
					end
				end
			end
		end
		
		if remainder then
			while remainder > maxcount do
				local thrownstack = xSlinger.new(newstack.id)
				thrownstack:set("count", maxcount, obj.skin)
				
				xSlinger.SpawnItemDrop(mo, newstack.id)
				
				remainder = $ - maxcount
			end
			
			local thrownstack = xSlinger.new(newstack.id)
			thrownstack:set("count", remainder, obj.skin)
			xSlinger.SpawnItemDrop(mo, newstack.id)
		end
	end;
}

local mt = {
	__index = function(a,k)
		if funcs[k] then
			return funcs[k]
		end
	end
}

registerMetatable(mt)

xSlinger.METATABLES.MAIN = mt