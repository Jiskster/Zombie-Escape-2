-- Custom timers for maps

ZE2.maptimerdebug = CV_RegisterVar({
	name = "z_maptimerdebug",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
})

ZE2.MapTimers = {}

function ZE2.AddMapTimer()
	print("ZE2.AddMapTimer is deprecated, try ZE2:AddTimer instead")
end

function ZE2:AddTimer(_id, _name, _table)
	if _id == nil then
		error("Timer: Arg1 is required (Arg1 _id)")
	elseif type(_id) ~= "string" then
		error("Timer: Arg1 must be string (Arg1 _id)")
	end
	
	if _name == nil then
		error("Timer: Arg2 is required (Arg2 _name)")
	elseif type(_name) ~= "string" then
		error("Timer: Arg2 must be string (Arg2 _name)")
	end
	
	if _table == nil then
		error("Timer: Table is required (Arg3 _table)")
	elseif type(_table) ~= "table" then
		error("Timer: Arg3 must be table (Arg3 _table)")
	end
	
	if ZE2.MapTimers[_id] then
		local errortext = string.format('Timer: TimerID "%s" has already been defined.')
		
		error(errortext)
	end
	
	local _table_recieve = _table
	
	_table.recieve.id = _id
	_table_recieve.name = _name
	_table_recieve.active = $ or false
	_table_recieve.time = $ or 15*TICRATE
	_table_recieve.original_time = _table_recieve.time
	
	ZE2.MapTimers[_id] = _table_recieve
	
	return ZE2.MapTimers[_id]
end

function ZE2:ResetTimer(_timer)
	_timer.active = false
	_timer.time = _timer.original_time
end

function ZE2:StartTimer(timer_id)
	ZE2:ResetTimer(ZE2.MapTimers[timer_id])
	ZE2.MapTimers[timer_id].active = true
end

function ZE2:GetActiveTimers()
	local activetimers = {}
	for i,timer in pairs(ZE2.MapTimers) do
		if timer.active then
			table.insert(activetimers, timer)
		end
	end
	return activetimers
end

addHook("MapLoad", function()
	for i,timer in pairs(ZE2.MapTimers) do
		ZE2:ResetTimer(timer)
	end
end)

addHook("ThinkFrame",do
	if ZE2.game_ended then return end
	
	for i,timer in pairs(ZE2.MapTimers) do
		if (timer.active) then
			if (ZE2.maptimerdebug.value) then
				print(timer.name..": "..(timer.time/35)) end

			timer.time = $ - 1

			if timer.extrainfo then
				for _,info in ipairs(timer.extrainfo) do
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
				if (timer.on_end) then
					timer.on_end(i, timer.name)
				end
				timer.active = false
			end
		end
	end
end)
