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
	local effectinfo = xSlinger.Effects[name]

	local effects = mobj.effects

	local index = #effects + 1
	effects[index] = data

	local neweffect = effects[index]

	neweffect.name = name
	neweffect.fuse = tics
	neweffect.mobj = mobj
	neweffect.index = index
	neweffect.global_index = global_index

	local global_index = #globaleffects + 1
	globaleffects[global_index] = neweffect

	if effectinfo and call_startfunc then
		if effectinfo.startfunc and mobj and mobj.valid then
			effectinfo.startfunc(neweffect, mobj)
		end
	end
end

-- mobj_t method
local function give_effect(self, name, data, tics, additive, recall_startfunc)
	-- redo sanity checks by using type()
	if not (self and self.valid) then
		return false, "mobj not valid"
	end

	if (name == nil) then
		return false, "no name"
	elseif (data == nil) then
		return false, "no data"
	elseif (tics == nil) then
		return false, "no tics"
	end

	local found = self:search_effect(name)

	if #found == 0 then
		set_effect(self, name, data, tics, additive, true)
	else
		local found_effect = found[1]

		if (additive == false) then
			self:remove_effect(found_effect) -- delete previous effect

			set_effect(self, name, data, tics, additive, recall_startfunc)
		elseif (additive == true) then
			-- keep most effect data, change those that are different
			for i,v in pairs(data) do
				if found_effect[i] ~= v then
					found_effect[i] = v
				end
			end

			found_effect.fuse = $ + tics
		end
	end

	return neweffect
end

-- mobj_t method
local function remove_effect(self, effect, ignore_global_index_update)
	local mobj_effects = self.effects

	table.remove(mobj_effects, effect.index)

	-- update indexes
	for i,effect in ipairs(mobj_effects) do
		effect.index = i
	end

	table.remove(globaleffects, effect.global_index)

	if not ignore_global_index_update then
		for i,effect in ipairs(globaleffects) do
			effect.global_index = i
		end
	end
end

-- mobj_t method
local function search_effect(self, name)
	local mobj_effects = self.effects
	local found = {}

	for i,effect in ipairs(mobj_effects) do
		if effect.name == name then
			found[#found + 1] = effect
		end
	end

	return found
end

mobj_mt.__index = function(mobj,key)
	if key == "give_effect" then
		return give_effect
	end

	if key == "remove_effect" then
		return remove_effect
	end

	if key == "search_effect" then
		return search_effect
	end

	return old_index(mobj,key)
end

addHook("MobjSpawn", function(mobj)
	mobj.effects = {}
end)

addHook("NetVars", function(net)
	globaleffects = net($)
end)

addHook("ThinkFrame", function()
	for i,effect in ipairs(globaleffects) do
		local mobj = effect.mobj
		local name = effect.name

		if not (type(name) == "string") then
			table.remove(globaleffects, i)
			continue
		end

		local effectinfo = xSlinger.Effects[name]

		if not (type(effectinfo) == "table") then
			table.remove(globaleffects, i)
			continue
		end

		effect.global_index = i -- update index

		if not (mobj and mobj.valid) then
			table.remove(globaleffects, i)
			continue
		end

		local mobj_effects = mobj.effects

		if effect.fuse > 0 then
			effect.fuse = $ - 1

			if effectinfo.tick and mobj and mobj.valid then
				effectinfo.tick(effect, mobj, effect.fuse)
			end

			if not effect.fuse then
				if effectinfo.endfunc and mobj and mobj.valid then
					effectinfo.endfunc(effect, mobj)
				end

				mobj:remove_effect(effect, true)
			end
		else
			mobj:remove_effect(effect, true)
			continue
		end

		effect.global_index = i -- update index again
	end
end)