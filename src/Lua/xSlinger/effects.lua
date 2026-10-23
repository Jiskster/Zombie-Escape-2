local globaleffects = {}

-- effectinfo_t
xSlinger.Effects = {}

function xSlinger.registerEffect(id, data)
	xSlinger.Effects[id] = data or {}
end

local function addToGlobalEffects(mobj)
	local has = false
	
	for i=1, #globaleffects do
		local effect_list = globaleffects[i]
		if effect_list == mobj.effects then
			has = true
			break
		end
	end
	
	if not has then
		globaleffects[#globaleffects + 1] = mobj.effects
	end
	
	return has
end

-- mobj_t method
local function give_effect(mobj, id, data, fusetics, additive)
	if not mobj or not mobj.valid then -- redo sanity checks by using type()
		return false, "mobj not valid"
	end

	if (id == nil) then
		return false, "no id"
	elseif (data == nil) then
		return false, "no data"
	elseif (fusetics == nil) then
		return false, "no fusetics"
	end
	
	local info = xSlinger.Effects[id]
	
	if not info then
		return false, "invalid"
	end
	
	local effects = mobj.effects
	local new = false -- its true if there wasnt a mobj.effects before
	
	if not effects then
		mobj.effects = {parent = mobj}
		effects = mobj.effects
		new = true
	end
	
	if (additive and not new) then
		local found
		
		for i=1, #effects do
			local v = effects[i]
			if v.id == id then
				found = v
				break
			end
		end
		
		if found then
			if info.max_duration then
				found.fuse = min($ + fusetics, info.max_duration) 
			else
				found.fuse = ($ + fusetics)
			end
			
			return
		end
	end
	
	effects[#effects + 1] = data
	
	local neweffect = effects[#effects]
	neweffect.id = id
	neweffect.fuse = fusetics
	
	if info.startfunc then
		info.startfunc(info, mobj)
	end
	
	addToGlobalEffects(mobj)
end

local function remove_effect(mobj, id)
	local effects = mobj.effects
	
	if effects then
		for i=#effects, 1, -1 do
			local effect = effects[i]
			
			if effect.id == id then
				table.remove(effects, i)
			end
		end
	end
end

local function search_effect(mobj, id)
	local effects = mobj.effects
	local found = {}
	
	if effects then
		for i=#effects, 1, -1 do
			local effect = effects[i]
			
			if effect.id == id then
				found[#found + 1] = effect
			end
		end
	end
	
	return found
end

local function effectThink(effectKey, effect, parent)
	local awaitremove = {}
	local info = xSlinger.Effects[effect.id]
	local effects = parent.effects
	
	if (effect.fuse > 0) then
		effect.fuse = max(0, $ - 1)
		
		info.tick(info, parent, effect.fuse)
		
		if not (parent and parent.valid) then
			table.remove(effects, effectKey)
			return false
		end
		
		if (effect.fuse <= 0) then
			if parent and parent.valid then
				if info.endfunc then
					info.endfunc(info, parent)
				end
			end
			
			table.remove(effects, effectKey)
			return false
		end
	else
		table.remove(effects, effectKey)
		return false
	end
	
	return true
end

addHook("ThinkFrame", function()
	local awaitremove = {}
	for key = 1, #globaleffects do
		local effects = globaleffects[key]
		local parent = effects.parent
		
		if not (parent and parent.valid) then
			awaitremove[#awaitremove] = key
			continue
		end
		
		for effectKey = #effects, 1, -1 do
			local effect = effects[effectKey]
			
			effectThink(effectKey, effect, parent)
			
			if not #effects then
				awaitremove[#awaitremove] = key
				break 2
			end	
		end
	end
	
	for i = #awaitremove, 1, -1 do
		table.remove(globaleffects, awaitremove[i])
	end
end)

addHook("NetVars", function(net)
	globaleffects = net(globaleffects)
end)

xSlinger.give_effect = give_effect
xSlinger.remove_effect = remove_effect
xSlinger.search_effect = search_effect