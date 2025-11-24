COM_AddCommand("zd_refreshitems", function ()
    for p in players.iterate do
        if not p.ze2 then continue end
        local inventory = p.ze2.survivor_inventory
        if inventory then
            for i=1,#inventory do
                if inventory[i] then
                    inventory[i] = ZE2:CopyItemFromID(inventory[i].item_id)
                end
            end
        end
    end
end, 1)

--Countdown to zero
COM_AddCommand("zd_nocd", function(p, arg)
	if not ZE2.cv_debug.value then return end
	if arg == "true" or arg == "1" or arg == "on" then
		ZE2.debug.nocd = true
		if ZE2.pregame_timeleft then
			ZE2.pregame_timeleft = 0
		end
	elseif arg == "false" or arg == "0" or arg == "off" then
		ZE2.debug.nocd = false
	elseif ZE2.pregame_timeleft then
		ZE2.pregame_timeleft = 0
	end
end, COM_ADMIN)

addHook("MapLoad", function()
	if not ZE2.cv_debug.value then return end
	if ZE2.debug.nocd and ZE2.pregame_timeleft then ZE2.pregame_timeleft = 0 end
end)

--Show/hide checkpoints
COM_AddCommand("zd_showcheckpoints", function(p)
	if ZE2.debug.checkpoints_show then
		ZE2.debug.checkpoints_show = false
		print("\133Checkpoints visibility has been disabled")
	else
		ZE2.debug.checkpoints_show = true
		print("\131Checkpoints visibility has been enabled")
	end
end, COM_ADMIN)

--Noclip command
COM_AddCommand("zd_noclip", function(p)
	if not ZE2.cv_debug.value then return end
	if p.noclip then
		p.pflags = $ & ~(PF_NOCLIP|PF_GODMODE)
		p.mo.alpha = FRACUNIT
		p.noclip = false
		S_StartSound(p.mo, sfx_s1a2)
		CONS_Printf(p, "\133Noclip disabled")
	else
		p.pflags = $ | (PF_NOCLIP|PF_GODMODE)
		p.mo.alpha = FRACUNIT / 2
		p.noclip = true
		S_StartSound(p.mo, sfx_s3k92)
		CONS_Printf(p, "\131Noclip enabled")
	end
end, COM_ADMIN)

--Skip map timers
COM_AddCommand("zd_skiptimers", function()
	if not ZE2.cv_debug.value then return end
	for i,timer in pairs(ZE2.MapTimers) do
		if timer.time then timer.time = 0 end
	end
	print("\131All map timers have been skipped")
end, COM_ADMIN)

--Load other skin's character configurations for the player
COM_AddCommand("zd_loadconfig", function(p, skinname)
	if not ZE2.cv_debug.value then return end
	if not (p and p.mo and p.mo.valid and p.mo.skin) then return end
	local cc = ZE2.CharacterConfig
	local zc = ZE2.ZombieConfig
	--Copied from ZE2 code since speeds are stored in a	local table
    --make speeds globally accessible mister jisk pls
	local speeds = {
		[1] = 18*FRACUNIT, -- slow
		[2] = 19*FRACUNIT, -- normal
		[3] = 20*FRACUNIT, -- fast
		
		["slow"] = 18*FRACUNIT,
		["normal"] = 19*FRACUNIT,
		["fast"] = 20*FRACUNIT,
	}
	if not skinname or skinname == "" then
		local survivor_skins = {}
		local zombie_skins = {}
		for name, cfg in pairs(cc) do
			if skins[name] and skins[name].name then
				table.insert(survivor_skins, name)
			end
		end
		CONS_Printf(p, "\133Please specify a skin name.")
		if #survivor_skins > 0 then
			CONS_Printf(p, "\130Survivor configs:\128 "..table.concat(survivor_skins, ", "))
		end
		CONS_Printf(p, "\139Zombie configs:\128 normal, ranged, heavy, alpha")
		return
	end

	skinname = string.lower(skinname)
	local skincfg = cc[skinname]
	local zombiecfg = zc[skinname]
	local skindata = skins[skinname]

	if (skinname == "default") then
		p.mo.maxhealth = cc[p.mo.skin].health
		p.mo.health = cc[p.mo.skin].health
		p.newspeed = nil
		p.ze2skinname = nil
		CONS_Printf(p, "\131Loaded default character configuration")
	elseif (skincfg and skindata and skindata.name) or zombiecfg then
		if skincfg then
			p.mo.maxhealth = skincfg.health
			p.mo.health = skincfg.health
			p.newspeed = speeds[skincfg.speed]
			CONS_Printf(p, "\131Loaded character configuration for skin \128"..skinname)
		elseif zombiecfg then
			p.mo.maxhealth = zombiecfg.health
			p.mo.health = zombiecfg.health
			p.newspeed = zombiecfg.normalspeed
			CONS_Printf(p, "\131Loaded \128"..skinname.."\131 zombie configuration")
		end
		p.ze2skinname = skinname
	else
		CONS_Printf(p, "\133Skin or config \128"..skinname.."\133 not found")
	end
end, COM_ADMIN)

--I guess hacky way to modify player speed in real time until ZE2 supports it properly
--for debugging purposes
--make speeds globally accessible mister jisk pls
addHook("PostThinkFrame", function()
	if not ZE2.cv_debug.value then return end
	for p in players.iterate do
		if not (p and p.mo and p.mo.valid) or not p.newspeed then continue end
		if p.newspeed then
			if p.ze2.crouching and P_IsObjectOnGround(p.mo) then
				p.normalspeed = p.newspeed / 2
			else
				p.normalspeed = p.newspeed
			end
		end
	end
end)

