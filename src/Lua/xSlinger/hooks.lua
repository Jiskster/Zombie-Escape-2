--bHooks (Bastardized Hooks), a takis hook clone for accessibility.

--this file is completely reusable
--used in 'epic! murder mystery', 'spice runners', 'soap/takis', and 'xSlinger'
--coders: Unmatched Bracket, Luigi Budd, Jisk

-- EDITED FOR XSLINGER

-- This can go inside your global table in your mod (as long as its not synched)

xSlinger.events = {}
xSlinger.internal_name = "BHooks/xSlinger"

/*
	return value: Boolean (override default behavior?)
	true = override, otherwise hook is ran then the default function after
*/
local handler_snaptrue = {
	func = function(current, ...)
		local arg = {...}
		return (#arg and true or false) or current
	end,
	initial = false
}

/*
	if true, then the default func will run
	if false, then the default func will be forced to not run
	if nil, use the default behavior
	...generally
*/
local handler_snapany = {
	func = function(current, ...)
		local arg = {...}
		if #arg then
			return unpack(arg)
		else
			return current ~= nil and unpack(current) or nil
		end
	end,
	initial = nil
}

local handler_default = handler_snaptrue -- If no handler is given.

local typefor_mobj = function(this_mobj, ...)
	local arg = {...}
	local type = (#arg and arg[1] or nil)
	if (type == nil) then
		return true
	end
	return this_mobj.type == type
end

local events = {}

-- EXAMPLE HOOK! You can remove this!
/*
events["MyHook"] = {
    handler = handler_snapany;
    --typefor = typefor_mobj   ;
}
*/

events["OnPlayerDamage"] = {
    handler = handler_snapany;
    --typefor = typefor_mobj   ;
}

events["ShouldDamage"] = {
    handler = handler_snapany;
    --typefor = typefor_mobj   ;
}

events["MobjDamage"] = {
    handler = handler_snapany;
    --typefor = typefor_mobj   ;
}

local deprecated = {
    /* EXAMPLE
    ["MyHook"] = {
        correct = "MyNewHook";
        seen = false; -- Always define as false.
    }
    */
}

--check for new events...
for event_name, event_t in pairs(events) do
	if (xSlinger.events[event_name] == nil) then
		xSlinger.events[event_name] = event_t
		print("\x83"..xSlinger.internal_name..":\x80 Adding new hookevent... (\""..event_name..'")')
	else
		print("\x83"..xSlinger.internal_name..":\x80 Hooklib found an existing hookevent, not adding. (\""..event_name..'")')
	end
end

xSlinger.addHook = function(hooktype, func, typefor)
	local hook_okay = xSlinger.events[hooktype] ~= nil
	local dep_t = nil
	if not hook_okay then
		hook_okay = deprecated[hooktype] ~= nil
		dep_t = deprecated[hooktype]
	end

	if hook_okay then
		if dep_t ~= nil then
			if not dep_t.seen then
                xSlinger.bwarn("Hook type \""..hooktype.."\" has been deprecated and will be removed. Use \""..dep_t.correct.."\" instead.", sfx_skid)
			end
			hooktype = dep_t.correct
		end

		table.insert(xSlinger.events[hooktype], {
			func = func,
			typedef = typefor,
			errored = false,
			id = #xSlinger.events[hooktype]
		})
	else
        xSlinger.berror("Hook type \""..hooktype.."\" does not exist.")
	end
end

xSlinger.tryRunHook = function(hooktype, v, ...)
	local handler = xSlinger.events[hooktype].handler or handler_default
	local override = handler.initial

	local results = {pcall(v.func, ...)}
	local status = results[1] or nil
	table.remove(results,1)

	if status then
		override = {handler.func(
			override,
			unpack(results)
		)}
	elseif (not v.errored) then
		v.errored = true
		
		v.func(...) -- Force an error
		
        --xSlinger.berror("Hook " .. hooktype .. " handler #" .. v.id .. " error:", sfx_lose)
		--print(unpack(results))
	end

	if override == nil then return nil; end
	if type(override) == "table" then return unpack(override)
	else return override; end
end

local notvalid = {}
xSlinger.findEvent = function(hooktype)
	local name = hooktype
	local events = xSlinger.events[name]

	if events == nil
	and deprecated[hooktype] ~= nil then
		name = deprecated[hooktype].correct
		events = xSlinger[name]
	end

	if events == nil
	and not (notvalid[name]) then
	notvalid[name] = true
        xSlinger.bwarn("could not find hookevent \""..hooktype.."\"")
	end

	--can still return nil!
	return events, name
end

xSlinger.bwarn = function(text, sound)
    if sound and sound > 0 then
        S_StartSound(nil, sound)
    end

    print("\x83"..xSlinger.internal_name..":\x82 WARNING:\x80 "..text)
end

xSlinger.berror = function(text, sound)
    if sound and sound > 0 then
        S_StartSound(nil, sound)
    elseif sound ~= nil then
        S_StartSound(nil, sfx_skid)
    end

    error("\x83"..xSlinger.internal_name..":\x85 ERROR:\x80 "..text, 2)
end

/* EXAMPLE CODE
addHook("ThinkFrame", do
    local ev, ev_name = xSlinger.findEvent("MyHook")

    for i,v in ipairs(ev) do
        local result = xSlinger.tryRunHook(ev_name, v)

        print(tostring(result).." : "..leveltime)
    end
end)

xSlinger.addHook("MyHook", function()
    return true
end)

xSlinger.addHook("MyHook", function()
    return false
end)

xSlinger.addHook("MyHook", function()
    return "What a robo blast!"
end)
*/