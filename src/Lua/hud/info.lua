ZE2.infohud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	if ZE2.game_ended then return end
	if player["ze2_info"].zombie_shop_open then return end
	if not player.realmo then return end
	--if player and not player.realmo then return end
	
	local skinpatch = v.getSprite2Patch(player.realmo.skin, SPR2_XTRA)
	local hppatch = v.cachePatch("ZE2HPBAR1")
	local timeemb = v.cachePatch("NGRTIMER")
	local the_time 
	local colormap = v.getColormap(skinname, player.realmo.color)
	
	local health = player.realmo.health
	local maxhealth = player.realmo.maxhealth
	
	if ZE2.round_active then
		if ZE2.time_limit then
			the_time = G_TicsToMTIME(ZE2.time_limit - ZE2.game_time)
		else
			the_time = G_TicsToMTIME(ZE2.game_time)
		end
	else
		the_time = G_TicsToMTIME(ZE2.pregame_timeleft)
	end
	
	local lower_hud_offset = player["ze2_info"].lower_hud_offset or 0
	
	if not player["ze2_info"].pregamemenu_active then
		if not player["ze2_info"].ghostmode then
		
			if not player.spectator then
				-- [Player Icon] --
			
				v.drawScaled(0, (176-lower_hud_offset)*FRACUNIT, FixedDiv(3*FRACUNIT, 4*FRACUNIT),
				skinpatch, (V_SNAPTOBOTTOM|V_SNAPTOLEFT), colormap)
				-- [Player Name] --
				local display_name = (player["ze2_info"].zombie_type and player["ze2_info"].team == 2) 
				and (player["ze2_info"].zombie_type + " Zombie") or skins[player.realmo.skin].realname

				customhud.CustomFontString(v, 25, 192-lower_hud_offset,
				display_name, "TNYFC", 
				(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, player.realmo.color)
				
				-- [Rubies] --
				if player["ze2_info"].rubies ~= nil then
					customhud.CustomFontString(v, 25, 184-lower_hud_offset, "Rubies: "..player["ze2_info"].rubies, "TNYFC", 
					(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, SKINCOLOR_RED)
				end
				
				-- [Sprint Meter] --
				local sprintmeter_color = SKINCOLOR_SKY
				
				-- flicker when no sprint energy left
				if (leveltime/4) % 2 == 0 then
					if not player["ze2_info"].sprintmeter then
						sprintmeter_color = SKINCOLOR_RED
					end
				end
				
				if player["ze2_info"].sprintmeter ~= nil and player["ze2_info"].team == 1 then
					local y = 168-lower_hud_offset
					
					local sprintmeter = L_FixedDecimal(player["ze2_info"].sprintmeter, 1).."%"
					customhud.CustomFontString(v, 0, y, "Run: "..sprintmeter, "TNYFC",
					(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, sprintmeter_color)
				end
				
				if health and maxhealth then
					local healthstring = "+ "..health.."/"..maxhealth
					customhud.CustomFontString(v, 25, 176-lower_hud_offset, healthstring, "TNYFC", 
					(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, SKINCOLOR_GREEN)
				end
				
				if player.realmo.shield_health and player.realmo.shield_def then
					local healthstring_width = customhud.CustomFontStringWidth(v, healthstring, "TNYFC", FRACUNIT)
					local shield_color = player.realmo.shield_def.color or SKINCOLOR_WHITE
					
					local shield_health = tostring(player.realmo.shield_health)
					customhud.CustomFontString(v, 29+(healthstring_width/FU), 176-lower_hud_offset, "@ "..shield_health, "TNYFC",
					(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, shield_color)
				end
			else
				customhud.CustomFontString(v, 0, 192-lower_hud_offset, "SPECTATOR MODE", "TNYFC",
				(V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_50TRANS), nil , nil, SKINCOLOR_WHITE)
			end
			
			-- Hardcoded display at the moment
			if player["ze2_info"].team == 2 then
				local y = 168-lower_hud_offset
				local text = "Blood: "..player["ze2_info"].blood_currency
				
				customhud.CustomFontString(v, 0, y, text, "TNYFC",
				(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, SKINCOLOR_CRIMSON)
				
				--
				if player["ze2_info"].zombie_type == "alpha" then
					local special_cooldown = player["ze2_info"].special_cooldown
					local y = 160-lower_hud_offset
					local text = "Press C1 to Rage"
					
					if special_cooldown then
						text = "Cooldown "..G_TicsToSeconds(special_cooldown).."."..G_TicsToCentiseconds(special_cooldown).." secs"
					end
					
					customhud.CustomFontString(v, 0, y, text, "TNYFC",
					(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, SKINCOLOR_KETCHUP)
				end
			end
			
			/*
			-- [Checkpoint Number] --
			local checkpoint_number = player["ze2_info"].checkpoint_number
			customhud.CustomFontString(v, 0, 160, "Checkpoint: "..checkpoint_number, "TNYFC", 
			(V_SNAPTOBOTTOM|V_SNAPTOLEFT), nil , nil, SKINCOLOR_YELLOW)
			*/
			
			-- [Checkpoint Catch Up Timer] --
			if player["ze2_info"].checkpoint_catchuptics then
				local catchup_tics = player["ze2_info"].checkpoint_catchuptics
				
				customhud.CustomFontString(v, 160, 142, "Catching up in:", "TNYFC", 
				(V_SNAPTOBOTTOM|V_50TRANS), "center", nil, SKINCOLOR_CHERRY)
				
				customhud.CustomFontString(v, 160, 150, tostring(catchup_tics/TICRATE), "TNYFC", 
				(V_SNAPTOBOTTOM|V_50TRANS), "center" , nil, SKINCOLOR_CHERRY)
			end
			
			-- [Health] --
			--local healthfont = player.realmo.shield_health and "TNYFC" or "STCFC"
			
						
			-- [Survivor Count] --			
			v.drawStretched((138-28-7)*FU, 2*FU, 16*FU, 6*FU, v.cachePatch("Z_BG_BLUE"), 
			V_SNAPTOTOP)
			
			customhud.CustomFontString(v, 138-28, 1, tostring(ZE2.SurvivorCount()), "STCFC", 
			(V_SNAPTOTOP), "center" , nil, SKINCOLOR_BLUE)
			

			
			-- [Zombie Count] --
			
			v.drawStretched((138+64-7)*FU, 2*FU, 16*FU, 6*FU, v.cachePatch("Z_BG_RED"), 
			V_SNAPTOTOP)
			
			customhud.CustomFontString(v, 138+64, 1, tostring(ZE2.ZombieCount()), "STCFC", 
			(V_SNAPTOTOP), "center" , nil, SKINCOLOR_RED)
		end
		
		-- [Timer] --
		if the_time ~= nil then
			-- Time
			customhud.CustomFontString(v, 150, 1, the_time, "STCFC", 
			(V_SNAPTOTOP), nil , nil, SKINCOLOR_BEIGE)
			
			-- Clock Icon
			v.drawScaled(138*FRACUNIT, 0, FRACUNIT,
			timeemb, (V_SNAPTOTOP))
		end
		-- [Event Timer HUD] --
		
		for i,timer in ipairs(ZE2:GetActiveTimers()) do 
			local event_name_string = ("# "..timer.name.." #") or "Event Name Error"
			local event_time_string = ("* "..G_TicsToMTIME(timer.time).." *") or "Failed To Get Event Time"
			local event_color
			if timer.extrainfo then
				event_color = timer.extrainfo.color or SKINCOLOR_TEAL
			else
				event_color = SKINCOLOR_TEAL
			end
			
			customhud.CustomFontString(v, 160, 10+((i-1)*16), (event_name_string), "STCFC", 
			(V_SNAPTOTOP), "center" , nil, event_color)
			
			-- Time
			customhud.CustomFontString(v, 160, 18+((i-1)*16), (event_time_string), "STCFC", 
			(V_SNAPTOTOP), "center" , nil, event_color)
		end
	else
		if the_time ~= nil then
			-- Time
			customhud.CustomFontString(v, 300, 6, the_time, "STCFC", 
			(V_SNAPTOTOP|V_SNAPTORIGHT), "right" , nil, SKINCOLOR_BEIGE)
			
			-- Clock Icon
			v.drawScaled(300*FRACUNIT, 5*FRACUNIT, FRACUNIT,
			timeemb, (V_SNAPTOTOP|V_SNAPTORIGHT))
		end
	end
end
