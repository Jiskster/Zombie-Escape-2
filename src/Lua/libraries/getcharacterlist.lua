ZE2.blacklisted_characters = {"zzombie"} -- blacklisted characters from showing
ZE2.registered_skins = {}

ZE2.getSkinNames = function(player, getunlockables, timesrepeated)
    local list = {}
	local tr_real = 1
	if timesrepeated and timesrepeated > 0 then
		tr_real = timesrepeated
	end
	for tr=1,tr_real do
		for i=0,31 do -- for each skin slot
			local foundskin = false -- if the game finds the skin in ZE2.registered_skins
		
			if not skins[i] then
				continue
			end
			
			for _,v in ipairs(ZE2.registered_skins) do
				if v == skins[i].name then
					foundskin = true
					break
				end
			end
			
			-- you failure.
			if not foundskin then 
				continue
			end
			
			local isblacklisted = false
			for _,v in ipairs(ZE2.blacklisted_characters) do
				if v == skins[i].name then
					isblacklisted = true
					break
				end
			end
			
			if isblacklisted then
				continue
			end
			
			if getunlockables then
				table.insert(list, skins[i].name)
			else -- Default 
				if R_SkinUsable(player, skins[i].name) then
					table.insert(list, skins[i].name)
				end
			end
		end
	end
    return list
end

ZE2.getSkinNums = function(player, getunlockables, timesrepeated)
    local list = {}
	local tr_real = 1
	if timesrepeated and timesrepeated > 0 then
		tr_real = timesrepeated
	end
	for tr=1,tr_real do
		for i=0,31 do
			local foundskin = false -- if the game finds the skin in ZE2.registered_skins
			
			if not skins[i] then
				continue
			end
			
			for _,v in ipairs(ZE2.registered_skins) do
				if v == skins[i].name then
					foundskin = true
					break
				end
			end
			
			-- you failure.
			if not foundskin then 
				continue
			end
			
			local isblacklisted = false
			for _,v in ipairs(ZE2.blacklisted_characters) do
				if v == skins[i].name then
					isblacklisted = true
				end
			end
			
			if isblacklisted then
				continue
			end
			
			if getunlockables then
				table.insert(list, i)
			else -- Default 
				if R_SkinUsable(player, skins[i].name) then
					table.insert(list, i)
				end
			end
		end
	end
    return list
end