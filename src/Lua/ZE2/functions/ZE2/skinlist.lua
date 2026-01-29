ZE2.blacklisted_characters = {} -- blacklisted characters from showing
ZE2.registered_skins = {}

-- dont blacklist a registered skin or else the game dies
ZE2.blacklist_skin = function(skinname)
	ZE2.blacklisted_characters[skinname] = true
	table.insert(ZE2.blacklisted_characters, skinname)
end

ZE2.blacklist_skin("zsonic")

ZE2.getSkinNames = function(player, getunlockables)
    local list = {}

	for i=0,#skins do -- for each skin slot
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

    return list
end

ZE2.getSkinNums = function(player, getunlockables)
    local list = {}

	for i=0,#skins do
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
	
    return list
end