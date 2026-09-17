local mobj_mt = userdataMetatable("mobj_t")
local old_index = mobj_mt.__index

local globaleffects = {}

-- effectinfo_t
xSlinger.Effects = {}

function xSlinger.registerEffect(name, data)
	xSlinger.Effects[name] = data or {}
end

-- isolated function
local function set_effect(mobj, name, data, tics, additive, call_startfunc)
	if (mobj.type == MT_XS_MISSILE) or (mobj.flags & MF_MISSILE) then
		return
	end

	local effectinfo = xSlinger.Effects[name]
	if effectinfo and (effectinfo.max_duration ~= nil) and (tics > effectinfo.max_duration) then
		tics = effectinfo.max_duration
	end

	local effects = mobj.effects
	local index = #effects + 1
	effects[index] = data

	local neweffect = effects[index]
	neweffect.name = name
	neweffect.fuse = tics
	neweffect.mobj = mobj
	neweffect.index = index
	
	local global_index = #globaleffects + 1
	globaleffects[global_index] = neweffect
	
	neweffect.global_index = global_index
	
	if effectinfo and call_startfunc then
		if effectinfo.startfunc and mobj and mobj.valid then
			effectinfo.startfunc(neweffect, mobj)
		end
	end
end

-- mobj_t method
local function give_effect(self, name, data, tics, additive, recall_startfunc)
	if not self or not self.valid then -- redo sanity checks by using type()
		return false, "mobj not valid"
	end

	if (self.type == MT_XS_MISSILE) or (self.flags & MF_MISSILE) then
		return false, "mobj is a missile"
	end

	if (name == nil) then
		return false, "no name"
	elseif (data == nil) then
		return false, "no data"
	elseif (tics == nil) then
		return false, "no tics"
	end

	local effectinfo = xSlinger.Effects[name]
	local found = self:search_effect(name)
	if (#found == 0) then
		set_effect(self, name, data, tics, additive, true)
	else
		local found_effect = found[1]
		if (additive == false) then
			self:remove_effect(found_effect) -- delete previous effect
			set_effect(self, name, data, tics, additive, recall_startfunc)
		elseif (additive == true) then
			for index, value in pairs(data) do -- keep most effect data, change those that are different
				if (found_effect[index] ~= value) then
					found_effect[index] = value
				end
			end

			found_effect.fuse = found_effect.fuse + tics
			if effectinfo and (effectinfo.max_duration ~= nil) and (found_effect.fuse > effectinfo.max_duration) then
				found_effect.fuse = effectinfo.max_duration
			end
		end
	end
end

-- mobj_t method
local function remove_effect(self, effect, ignore_global_index_update)
	if (self.type == MT_XS_MISSILE) or (self.flags & MF_MISSILE) then
		return
	end

	local mobj_effects = self.effects
	table.remove(mobj_effects, effect.index)

	for index, effect in ipairs(mobj_effects) do -- update indexes
		effect.index = index
	end
	table.remove(globaleffects, effect.global_index)

	if not ignore_global_index_update then
		for index, effect in ipairs(globaleffects) do
			effect.global_index = index
		end
	end
end

-- mobj_t method
local function search_effect(self, name)
	local mobj_effects = self.effects
	local found = {}
	for index, effect in ipairs(mobj_effects) do
		if (effect.name == name) then
			found[#found + 1] = effect
		end
	end
	return found
end

mobj_mt.__index = function(mobj, key)
	if (key == "give_effect") then
		return give_effect
	end
	if (key == "remove_effect") then
		return remove_effect
	end
	if (key == "search_effect") then
		return search_effect
	end
	return old_index(mobj, key)
end

addHook("MobjSpawn", function(mobj)
	if (mobj.type == MT_XS_MISSILE) or (mobj.flags & MF_MISSILE) then
		return
	end
	mobj.effects = {}
end)

addHook("NetVars", function(net)
	globaleffects = net(globaleffects)
end)

addHook("PreThinkFrame", function()
	local removedelayed = {}
	
	for index = #globaleffects, 1, -1 do
		local effect = globaleffects[index]
		
		if (effect == nil) then
			continue
		end
		
		local mobj = effect.mobj
		local name = effect.name
		if not (type(name) == "string") then
			removedelayed[#removedelayed + 1] = {key = index}
			continue
		end

		local effectinfo = xSlinger.Effects[name]
		if not (type(effectinfo) == "table") then
			removedelayed[#removedelayed + 1] = {key = index}
			continue
		end

		if not mobj or not mobj.valid then
			removedelayed[#removedelayed + 1] = {key = index}
			continue
		end

		local mobj_effects = mobj.effects
		if (effect.fuse > 0) then
			effect.fuse = effect.fuse - 1
			if effectinfo.tick and mobj and mobj.valid then
				effectinfo.tick(effect, mobj, effect.fuse)
				if not mobj or not mobj.valid then
					removedelayed[#removedelayed + 1] = {key = index}
					continue
				end
			end
			if not effect.fuse then
				if effectinfo.endfunc and mobj and mobj.valid then
					effectinfo.endfunc(effect, mobj)
					if not mobj or not mobj.valid then
						removedelayed[#removedelayed + 1] = {key = index}
						continue
					end
				end
				mobj:remove_effect(effect, true)
			end
		else
			mobj:remove_effect(effect, true)
			continue
		end
	end

	if #removedelayed then
		for i = #removedelayed, 1, -1 do
			local todo = removedelayed[i]

			table.remove(globaleffects, todo.key)
		end
	end
	
	for index, effect in ipairs(globaleffects) do
		local mobj = effect.mobj
		local name = effect.name
		
		effect.global_index = index -- update index
	end
end)