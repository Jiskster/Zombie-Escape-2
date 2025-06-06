ZE2.debug_x = CV_RegisterVar({name = "z_debug_x", defaultvalue = 0, flags = CV_FLOAT})
ZE2.debug_y = CV_RegisterVar({name = "z_debug_y", defaultvalue = 0, flags = CV_FLOAT})

local function drawSkewFill(v, x,y, w,h, flags, c)
	x = $ + (FixedDiv(h, 2*FU) - FU)
	while h >= 0
		
		v.drawStretched(x, y, w, 2*FU, v.cachePatch("ZE2_C"), flags, v.getColormap(TC_DEFAULT, c))
		--v.drawFixedFill(x,y, w,2*FU, c)
		h = $ - 2*FU
		y = $ + 2*FU
		x = $ - FU
		
	end
end

local old_info = {}
local fake_info = {}
local store_info = {}
local old_disp = nil

local function ResetInfos()
	old_info = {
		health = -1,
		stamina = -1,
		shield = -1,
		shielddef = -1,
		rage = -1,
	}
	fake_info = {
		health = -1,
		stamina = -1,
		shield = -1,
		shielddef = -1,
		rage = -1,
	}
	store_info = {
		health = -1,
		stamina = -1,
		shield = -1,
		shielddef = -1,
		rage = -1,
	}
end
ResetInfos()

addHook("MapLoad",ResetInfos)

local function intlerp(frac,to,from)
	return from + (to - from)/frac
end

local function health(v,p,me,ze)
	local health = me.health
	local maxhealth = me.maxhealth
	
	if (health == nil) or (maxhealth == nil) then ResetInfos(); return end
	if ZE2.pregame_timeleft then ResetInfos(); return end
	
	if old_disp == nil
		old_disp = p
	elseif old_disp ~= p
		old_info.health = me.health
		fake_info.health = me.health
		
		old_info.stamina = ze.sprintmeter
		fake_info.stamina = ze.sprintmeter
		
		old_info.shield = me.shield_health
		fake_info.shield = me.shield_health
	end
	
	if old_info.health == -1
		old_info.health = me.health
		fake_info.health = me.health
	end
	if old_info.stamina == -1
	and ze.sprintmeter ~= nil
		old_info.stamina = ze.sprintmeter
		fake_info.stamina = ze.sprintmeter
	end
	if old_info.shield == -1
		old_info.shield = me.shield_health
		fake_info.shield = me.shield_health
	end
	/*
	if old_info.rage == -1
	and ze.ragemeter ~= nil
		old_info.rage = ze.ragemeter
		fake_info.rage = ze.ragemeter
	end
	*/

	health = intlerp(2,fake_info.health,health)
	fake_info.health = health
	
	local max_width = 65*FU
	local height = 8*FU
	
	local pad = 6*FU
	local shadow = 2*FU
	local textspace = shadow*3
	local fade_sin = abs(sin(leveltime * 4 * ANG2))
	
	local x = 10*FU - (ze.lower_hud_offset or 0)
	local y = BASEVIDHEIGHT*FU - (height*2) - shadow + FU
	local flags = V_SNAPTOLEFT|V_SNAPTOBOTTOM
	
	--health
	do
		local x = x
		local y = y
		if store_info.health ~= -1
			local diff = (store_info.health - health)/2
			if diff > 0
				local shake = (abs(diff or 1)*FU)/4 * (leveltime & 1 and 1 or -1)
				shake = $/2
				if ze.team == 2 then shake = $/6 end
				y = $ + shake
				x = $ + shake
			end
		end
		
		local width = FixedMul(max_width, FixedDiv(health,maxhealth))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags, SKINCOLOR__31) -- 31
		if old_info.health > health
			if store_info.health == -1
				store_info.health = old_info.health
			end
			local s_width = FixedMul(max_width, FixedDiv(store_info.health,maxhealth))
			drawSkewFill(v, x,y, s_width,height, flags|V_20TRANS, SKINCOLOR__35) -- 35
		else
			if store_info.health ~= -1
				local diff = max(abs(store_info.health - health)/5, 1)
				if diff == 1 and (leveltime & 1) then diff = 0; end
				if store_info.health < health
					store_info.health = $ + diff
				else
					store_info.health = $ - diff
				end
			end
			if store_info.health == health
			or store_info.health == -1
				store_info.health = -1
			else
				local s_width = FixedMul(max_width, FixedDiv(store_info.health,maxhealth))
				drawSkewFill(v, x,y, s_width,height, flags|V_20TRANS, SKINCOLOR__35) --35		
			end
		end
		drawSkewFill(v, x,y, width,height, flags, SKINCOLOR__96) -- 96
		if me.health <= maxhealth/2
			local fade = FixedMul(10*FU, fade_sin)/FU
			
			if fade ~= 10
				drawSkewFill(v, x,y, width,height, flags|(fade << V_ALPHASHIFT), SKINCOLOR__35) -- 35
			end
		end
		v.drawString(x + textspace, y + shadow,
			string.format("%d | %d", health, maxhealth),
			flags, "thin-fixed"
		)
	end
	
	--stamina
	if ze.team == 1
	and ze.sprintmeter ~= nil
		local sprint = ze.sprintmeter
		
		sprint = intlerp(2, fake_info.stamina, $)
		fake_info.stamina = sprint
		
		local maxsprint = 100*FU
		local y = y - (height + pad)
		local width = FixedMul(max_width, FixedDiv(sprint,maxsprint))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags, SKINCOLOR__31) --31
		drawSkewFill(v, x,y, width,height, flags, SKINCOLOR__149)
		if sprint <= maxsprint/2
			local fade = FixedMul(10*FU, fade_sin)/FU
			
			if fade ~= 10
				drawSkewFill(v, x,y, width,height, flags|(fade << V_ALPHASHIFT), SKINCOLOR__35) -- 35
			end
		end
		local sprint_text = string.format("%.0f%%", FixedDiv(sprint, maxsprint)*100)

		if ze.sprintdelay then
			sprint_text = "EXHAUSTED!"

			if (leveltime % 2) == 0 then
				x = $ - FU
			end

			if (leveltime % 2)/4 == 0 then
				sprint_text = "\x85"..$
			end
		end

		v.drawString(x + textspace, y + shadow,
			sprint_text,
			flags, "thin-fixed"
		)
	--rage meter
	/*
	elseif (ze.team == 2)
		local rage = ze.sprintmeter --rage variable
		sprint = intlerp(2, fake_info.rage, $)
		fake_info.rage = rage
		
		local maxsprint = 100*FU
		local y = y - (height + pad)
		local width = FixedMul(max_width, FixedDiv(rage,maxsprint))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags, SKINCOLOR__31) --31
		drawSkewFill(v, x,y, width,height, flags, SKINCOLOR__45)

		v.drawString(x + textspace, y + shadow,
			string.format("RAGE: %.0f%%", FixedDiv(rage, maxsprint)*100),
			flags, "thin-fixed"
		)
	*/
	end
	
	--shield
	local shields = me.shield_health or (store_info.shield == -1 and -1 or 0)
	shields = intlerp(2, fake_info.shield, $)
	fake_info.shield = shields
	
	local drawshields = false
	if shields ~= -1
		drawshields = (me.shield_def or (fake_info.shielddef ~= -1))
	elseif store_info.shield ~= -1
		drawshields = true
	end
	
	if drawshields
		if me.shield_def
			if fake_info.shielddef ~= me.shield_def
				old_info.shield = shields
			end
			fake_info.shielddef = me.shield_def
		end
		local def = fake_info.shielddef
		local color = (def.color or SKINCOLOR_WHITE)
		
		local maxshields = def.health
		local percentage = FixedDiv(shields, maxshields)
		
		local x = x + max_width + 20*FU
		local y = y
		local shield_icon = v.cachePatch("Z_SHIELDSICO")
		
		local crop_height = shield_icon.height*FU - FixedMul(shield_icon.height*FU, percentage)
		crop_height = max($, 0)
		
		--BG
		if percentage ~= FU
			v.drawCropped(x,y,
				FU,FU,
				shield_icon,
				flags|V_REVERSESUBTRACT,
				v.getColormap(nil,SKINCOLOR_CARBON, "Grayscale"),
				0, 0,
				shield_icon.width*FU,
				crop_height
			)
		end
		
		v.drawCropped(x,
			y + crop_height, --move down by what we cropped
			FU,FU,
			shield_icon,
			flags|V_ADD|V_30TRANS,
			v.getColormap(nil,color),
			0, crop_height,
			shield_icon.width*FU,
			shield_icon.height*FU
		)
		
		v.drawString(x,y - (FU * 7/2),
			string.format("%.0f%%", percentage*100),
			flags,
			"thin-fixed-center"
		)
	else
		fake_info.shielddef = -1
		store_info.shield = -1
	end
	
	old_info.health = me.health
	old_info.stamina = ze.sprintmeter
	old_info.shield = me.shield_health
	-- old_info.rage = ze.ragemeter
	old_disp = p
end

local function roundinfo(v,p,me,ze)
	local timeemb = v.cachePatch("NGRTIMER")
	local the_time 
	
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
	
	if ZE2.round_active then
		if ZE2.time_limit then
			the_time = G_TicsToMTIME(ZE2.time_limit - ZE2.game_time)
		else
			the_time = G_TicsToMTIME(ZE2.game_time)
		end
	else
		the_time = G_TicsToMTIME(ZE2.pregame_timeleft)
	end

	if the_time ~= nil
		customhud.CustomFontString(v, 150, 1, the_time, "STCFC", 
		(V_SNAPTOTOP), nil , nil, SKINCOLOR_BEIGE)
		
		v.drawScaled(138*FRACUNIT, 0, FRACUNIT,
		timeemb, (V_SNAPTOTOP))
	end

	if ze.cash ~= nil then
		customhud.CustomFontString(v, 320-10, 0+5, "$ "..ze.cash, "STCFC", 
		(V_SNAPTOTOP|V_SNAPTORIGHT), "right" , nil, SKINCOLOR_FOREST)
	end
end

local function eventtimers(v,p,me,ze)
	local x = 5
	local y = 12
	local flags = V_SNAPTOLEFT|V_SNAPTOTOP
	
	if ze.checkpoint_catchuptics
		local catchup_tics = ze.checkpoint_catchuptics
		
		customhud.CustomFontString(v, 160, 142, "Catching up in:", "TNYFC", 
		(V_SNAPTOBOTTOM|V_50TRANS), "center", nil, SKINCOLOR_CHERRY)
		
		customhud.CustomFontString(v, 160, 150, tostring(catchup_tics/TICRATE), "TNYFC", 
		(V_SNAPTOBOTTOM|V_50TRANS), "center" , nil, SKINCOLOR_CHERRY)		
	end
	
	for i,timer in pairs(ZE2:GetActiveTimers()) do
		local name = "* "..(timer.text or "Event "..i)
		local time = "  ("..G_TicsToMTIME(timer.time)..")"
		local color = timer.textcolor or SKINCOLOR_TEAL

		customhud.CustomFontString(v, x, y, name, "STCFC", 
			flags, "left" , nil, color
		)
		customhud.CustomFontString(v, x, y + 8, time, "STCFC", 
			flags, "left" , nil, color
		)
		
		y = $ + 16
	end
end

local function wrapper(v,p)
	if ZE2.game_ended then return end
	if p.ze2.zombie_shop_open then return end
	if not p.realmo then return end
	
	local me = p.realmo
	local ze = p.ze2
	
	health(v,p,me,ze)
	roundinfo(v,p,me,ze)
	eventtimers(v,p,me,ze)
end

return "GameInfo", wrapper
