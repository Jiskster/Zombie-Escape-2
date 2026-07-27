-- Custom timers for maps

ZE2.maptimerdebug = CV_RegisterVar({
	name = "z_maptimerdebug",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
})

ZE2.MapTimers = {} -- has functions; dont sync
ZE2.ActiveMapTimers = {} -- sync this instead

-- we hate functions
local function stripTable(tb)
    local output = {}
    
    for key, value in pairs(tb) do
        local t = type(value)
        
        -- no funcs
        if t == "table" then
            output[key] = stripTable(value)
        elseif t ~= "function" then
            output[key] = value
        end
    end
    
    return output
end

function ZE2:AddTimer(_id, _table)
	if _id == nil then
		error("Timer: Arg1 is required (Arg1 _id)")
	elseif type(_id) ~= "string" then
		error("Timer: Arg1 must be string (Arg1 _id)")
	end

	if _table == nil then
		error("Timer: Table is required (Arg2 _table)")
	elseif type(_table) ~= "table" then
		error("Timer: Arg2 must be table (Arg2 _table)")
	end

	if ZE2.MapTimers[_id] then
		local errortext = string.format('Timer: TimerID "%s" has already been defined.', _id)

		error(errortext)
	end

	-- Macro to save mapper's time.
	if _table.lua_linedef_exec then
		local exec_name = _table.lua_linedef_exec
		addHook("LinedefExecute", function()
			ZE2:StartTimer(_id)
		end, exec_name)
	end

	local _table_recieve = _table

	_table_recieve.id = _id
	_table_recieve.active = false
	_table_recieve.time = $ or 15*TICRATE
	_table_recieve.original_time = _table_recieve.time

	ZE2.MapTimers[_id] = _table_recieve
	ZE2.ActiveMapTimers[_id] = stripTable(_table_recieve)

	return ZE2.MapTimers[_id]
end

-- This fully resets the timer so dont use this midgame, only on init
function ZE2:OverrideTimer(_id, _new)
	local _timer

	if not ZE2.MapTimers[_id] then
		local errortext = string.format('Timer: TimerID "%s" does not exist.', _id)

		error(errortext)
	end

	_timer = ZE2.MapTimers[_id]

	local banned_attributes = {
		["id"] = true,
		["active"] = true,
	}

	for i,v in pairs(_new) do
		if banned_attributes[i] then -- ILLLEGALLLLLLL
			continue
		end

		_timer[i] = v -- replace
		_timer.active = false

		if i == "time" then
			_timer.original_time = v
		end
	end
	
	ZE2.ActiveMapTimers[_id] = stripTable(_timer)
end

function ZE2:ResetTimer(_timer)
	_timer.active = false
	_timer.time = _timer.original_time
end

function ZE2:StartTimer(timer_id)
	ZE2:ResetTimer(ZE2.ActiveMapTimers[timer_id])
	ZE2.ActiveMapTimers[timer_id].active = true
end

function ZE2:GetActiveTimers()
	local activetimers = {}
	for i,timer in pairs(ZE2.ActiveMapTimers) do
		if timer.active then
			table.insert(activetimers, timer)
		end
	end

	table.sort(activetimers, function(a, b)
		return a.time > b.time
	end)

	return activetimers
end

addHook("MapChange", function()
	for i,timer in pairs(ZE2.ActiveMapTimers) do
		ZE2:ResetTimer(timer)
	end
end)

addHook("ThinkFrame", function()
	if ZE2.game_ended then return end

	for i,timer in pairs(ZE2.ActiveMapTimers) do
		local realtimer = ZE2.MapTimers[i] -- 'timer' has no functions, so we use this
		
		if (timer.active) then
			if (ZE2.maptimerdebug.value) then
				print(timer.name..": "..(timer.time/35)) end

			timer.time = $ - 1

			if realtimer.extrainfo then
				for _,info in ipairs(realtimer.extrainfo) do
					if (info.event_time) and (info.event_func) then
						if (timer.time == info.event_time) then
							info.event_func(i, timer.name)
						end
					end
				end

				/*
					extrainfo::
					{
						[1] = {
							event_time = 5*TICRATE, -- This event activates when theres exactly 5 seconds left on a timer.
							event_func = function(i, timer.name) -- Same parameters as onend
								chatprint("\x86\Stone Platform \x80will leave in\x85 5 \x80seconds")
								-- Prints "Stone Platform will leave in 5 seconds"
							end
						}
					}
				*/

			end

			if timer.time <= 0 then
				if (realtimer.on_end) then
					realtimer.on_end(i, timer.name)
				end

				if (timer.on_end_tag) then
					P_LinedefExecute(timer.on_end_tag)
				end

				timer.active = false
			end
		end
	end
end)

addHook("NetVars", function(net)
	ZE2.ActiveMapTimers = net($)
end)
