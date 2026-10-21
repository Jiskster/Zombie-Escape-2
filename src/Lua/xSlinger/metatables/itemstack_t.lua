local getLambdaObject = xSlinger.getLambdaObject

-- obj.xSlinger.func(a,b,c)
local funcs = {
	["getIndex"] = function(self, index, skin)
		if not index then
			return nil
		end

		if skin and self.skin_override and self.skin_override[skin]
		and self.skin_override[skin][index] ~= nil then
			return self.skin_override[skin][index]
		end

		return self[index]
	end;
	["setIndex"] = function(self, index, value, skin)
		if not index then
			return nil
		end

		if skin and self.skin_override and self.skin_override[skin] then
			self.skin_override[skin][index] = value

			return self.skin_override[skin][index]
		end

		self[index] = value

		return self[index]
	end;
	["changeIndex"] = function(self, index, value, skin)
		if not index then
			return nil
		end

		if skin and self.skin_override and self.skin_override[skin]
		and self.skin_override[skin][index] ~= nil then
			self.skin_override[skin][index] = $ + value

			return self.skin_override[skin][index]
		end

		if self[index] ~= nil then
			self[index] = $ + value

			return self[index]
		end
	end;
}

-- alias
funcs["get"] = funcs["getIndex"]
funcs["set"] = funcs["setIndex"]
funcs["change"] = funcs["changeIndex"]

local mt = {
	__index = function(a,k)
		if funcs[k] then
			return funcs[k]
		end

		-- Can get functions that were deleted on xSlinger.new.
		if rawget(xSlinger.registered_items[a.id], k) then
			return rawget(xSlinger.registered_items[a.id], k)
		end
	end
}

registerMetatable(mt)

xSlinger.METATABLES.ITEMINFO = mt

