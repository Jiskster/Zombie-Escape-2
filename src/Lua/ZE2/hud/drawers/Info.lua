--if skincolor is TRUE, itll be assumed that 'c' is a valid skincolor,
--and the function will draw ramp gradient
--TODO?: accept a custom ramp? we could draw gradients or scrolling colors
--		 without having to make a new skincolor freeslot
local function drawSkewFill(v, x,y, w,h, flags, c, skincolor)
	if (w == nil or w <= 0) then return end
	if skincolor
		w = FixedDiv($,16*FU)
	end
	
	x = $ + (FixedDiv(h, 2*FU) - FU)
	while h >= 0
		if (not skincolor)
			v.drawStretched(x, y, w, 2*FU, v.cachePatch("ZE2_C"), flags, v.getColormap(TC_DEFAULT, c))
		else
			local ramp = skincolors[c].ramp
			local new_x = x
			for i = 0,15
				local newcolor = ZE2.paletteToColor[ramp[i]]
				v.drawStretched(new_x, y, w, 2*FU, v.cachePatch("ZE2_C"), flags, v.getColormap(TC_DEFAULT, newcolor))
				new_x = $ + w
			end
		end
		
		--v.drawFixedFill(x,y, w,2*FU, c)
		h = $ - 2*FU
		y = $ + 2*FU
		x = $ - FU
	end
end

-- `skincolor` can be a table with palette indicies, or a skincolornum_t
-- if `skincolor` isnt nil, `c` wont be used
local function drawSkewFill(v, x,y, w,h, flags, c, skincolor)
	if (w == nil or w <= 0) then return end
	local table_clr = type(skincolor) == "table"
	local clr_len = 16
	if skincolor ~= nil
		if table_clr
			clr_len = #skincolor
		end
		w = FixedDiv($, clr_len*FU)
	end
	if not table_clr then clr_len = $ - 1; end
	
	x = $ + (FixedDiv(h, 2*FU) - FU)
	while h >= 0
		if (not skincolor)
			v.drawStretched(x, y, w, 2*FU, v.cachePatch("ZE2_C"), flags, v.getColormap(TC_DEFAULT, c))
		else
			local ramp = table_clr and skincolor or skincolors[skincolor].ramp
			local new_x = x
			for i = (table_clr and 1 or 0), clr_len
				local newcolor = ZE2.paletteToColor[ramp[i]]
				v.drawStretched(new_x, y, w, 2*FU, v.cachePatch("ZE2_C"), flags, v.getColormap(TC_DEFAULT, newcolor))
				new_x = $ + w
			end
		end
		
		--v.drawFixedFill(x,y, w,2*FU, c)
		h = $ - 2*FU
		y = $ + 2*FU
		x = $ - FU
	end
end

local old_info = {}
local fake_info = {}
local store_info = {}
local health_shake = 0
local old_disp = nil

local button_to_tooltip = {
	[BT_CUSTOM1] =		"C1",
	[BT_CUSTOM2] =		"C2",
	[BT_CUSTOM3] =		"C3",
	[BT_SPIN] =			"S",
	[BT_JUMP] =			"J",
	[BT_ATTACK] =		"RT",
	[BT_FIRENORMAL] =	"RN",
	[BT_TOSSFLAG] =		"TF",
}

local AlreadyReset = false
local function ResetInfos()
	if AlreadyReset then return end
	health_shake = 0
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
	AlreadyReset = true
end
ResetInfos()

addHook("MapLoad",ResetInfos)

local function intlerp(frac,from,to)
	if abs(to - from) < frac then return to; end
	return from + (to - from)/frac
end
local function flerp(frac,from,to)
	return from + FixedMul(to - from, frac)
end

local hud_fires = {}
local flame_colors = {
	SKINCOLOR_FLAME, SKINCOLOR_KETCHUP, SKINCOLOR_GARNET, SKINCOLOR_ORANGE, --SKINCOLOR_RUST, SKINCOLOR_COPPER
}
local function makefire(v, x,y, width,height)
	table.insert(hud_fires, {
		x = x + v.RandomRange(0,width)*FU,
		y = y + v.RandomRange(0,height)*FU,
		scale = v.RandomRange(FU/4, tofixed(".7")),
		tics = v.RandomRange(12, 30),
		momy = v.RandomRange(FU/4, FU),
		color = flame_colors[v.RandomRange(1,#flame_colors)],
		lifetime = 0,
	})
end

local function health(v,p,me,ze)
	local health = me.health
	local maxhealth = me.maxhealth
	local zc = ZE2.ZombieConfig[p.ze2.zombie_type or ""]
	
	if (health == nil) or (maxhealth == nil) then ResetInfos(); return end
	if ZE2.pregame_timeleft then ResetInfos(); return end
	maxhealth = $*FU
	AlreadyReset = false
	
	if old_disp == nil
		old_disp = p
	elseif old_disp ~= p
		old_info.health = me.health*FU
		fake_info.health = me.health*FU
		
		old_info.stamina = ze.sprintmeter
		fake_info.stamina = ze.sprintmeter
		
		old_info.shield = me.shield_health
		fake_info.shield = me.shield_health
	end
	
	if old_info.health == -1
		old_info.health = me.health*FU
		fake_info.health = me.health*FU
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
	if old_info.rage == -1
	and ze.special_cooldown ~= nil
		old_info.rage = ze.special_cooldown
		fake_info.rage = ze.special_cooldown
	end

	health = flerp(FU/5, fake_info.health, health*FU)
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
		local real_x,real_y = x,y
		local x = x
		local y = y
		local drawRed = false
		local redWidth = 0
		
		health_shake = flerp(FU/8, $, 0)
		do
			local shake = (health_shake)
			if (ze.team == 2) then shake = $/16; end
			-- if (#hud_fires) then shake = max($,FU); end
			shake = min($, 8*FU) * (leveltime & 1 and 1 or -1)
			y = $ + shake
			x = $ - shake/2
		end
		
		local width = FixedMul(max_width, FixedDiv(health,maxhealth))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags|V_50TRANS, SKINCOLOR__31) -- 31
		if (old_info.health > me.health*FU)
			health_shake = $ + abs(old_info.health - health)
		end
		if old_info.health > health --we lost health!
			if store_info.health == -1
				store_info.health = old_info.health
			end
			redWidth = FixedMul(max_width, FixedDiv(store_info.health,maxhealth))
			drawRed = true
		else
			if store_info.health ~= -1
			and (abs(me.health*FU - health) <= FU)
			and (health_shake <= FU/10)
				local diff = max(abs(store_info.health - health)/15, 1)
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
				drawRed = true
				redWidth = FixedMul(max_width, FixedDiv(store_info.health,maxhealth))
			end
		end
		if drawRed
			drawSkewFill(v, x,y, redWidth,height, flags|V_20TRANS, SKINCOLOR__35) --35
		end
		drawSkewFill(v, x,y, width,height, flags, SKINCOLOR__96) -- 96
		if me.health*FU <= maxhealth/2
			local fade = FixedMul(10*FU, fade_sin)/FU
			
			if fade ~= 10
				drawSkewFill(v, x,y, width,height, flags|(fade << V_ALPHASHIFT), SKINCOLOR__35) -- 35
			end
		end
		v.drawString(x + textspace, y + shadow,
			string.format("%.0f | %.0f", health, maxhealth),
			flags, "thin-fixed"
		)

		-- hardcoded...
		if (ze.effects)
			local hasfire = false
			for name, _ in pairs(ze.effects) do
				if name == "flame_ring.on_fire"
					hasfire = true
					break
				end
			end
			if hasfire
				makefire(v, real_x,real_y+height, width/FU, -(height/FU))
			end
		end
	end

	--stamina
	if ze.team == 1
	and ze.sprintmeter ~= nil
		--sprint is fixed here, Yay!!
		local sprint = ze.sprintmeter
		
		sprint = flerp(FU/5, fake_info.stamina, $)
		fake_info.stamina = sprint
		
		local maxsprint = 100*FU
		local x = x
		local y = y - (height + pad)
		local width = FixedMul(max_width, FixedDiv(sprint,maxsprint))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags|V_50TRANS, SKINCOLOR__31) --31
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
			local ticker = (leveltime % 4)
			
			if (ticker & 1) then
				x = $ - FU
			end
			
			if ticker <= 1 then
				sprint_text = "\x85"..$
			end
		end
		
		v.drawString(x + textspace, y + shadow,
			sprint_text,
			flags, "thin-fixed"
		)
	--rage meter
	elseif (ze.team == 2)
	and (zc and zc.special and zc.special.button)
		local spec = zc.special
		local rage = ze.special_cooldown --rage variable
		rage = intlerp(2, fake_info.rage, $)
		fake_info.rage = rage
		
		local maxsprint = spec.cooldown
		local adjust = 15*FU
		local button_pad = 3*FU
		local max_width = (max_width - adjust)
		local x = x + adjust
		local y = y - (height + pad)
		local width = FixedMul(max_width, FU - FixedDiv(rage,maxsprint))
		drawSkewFill(v, x+shadow,y+shadow, max_width,height, flags|V_50TRANS, SKINCOLOR__31) --31
		
		local color = SKINCOLOR_ALPHAZOMBIE
		local usecolor = true
		if ze.special_cooldown
			color = SKINCOLOR__71
			usecolor = false
		end
		drawSkewFill(v, x,y, width,height, flags, color, usecolor)
		
		local pname = "Z_TT_"..(button_to_tooltip[spec.button])
		if (v.patchExists(pname))
			v.drawScaled(x - adjust - button_pad, y - button_pad, FU,
				v.cachePatch(pname),
				flags|(ze.special_cooldown and V_50TRANS or 0)
			)
		else
			v.drawString(x - adjust, y + shadow,
				button_to_tooltip[spec.button]..":",
				flags, "thin-fixed"
			)
		end
		v.drawString(x + (textspace/2), y + shadow,
			string.format("RAGE: %.0f%%", (FU - FixedDiv(rage, maxsprint))*100),
			flags, "thin-fixed"
		)
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
	
	--fire effect
	if #hud_fires
		for k,fire in ipairs(hud_fires)
			if fire.tics <= 0
				table.remove(hud_fires,k)
			end
		end
		for k,fire in ipairs(hud_fires)
			local frame = (fire.lifetime/2) % 5
			if (frame > 2)
				frame = E - $
			end
			v.drawScaled(fire.x,fire.y, fire.scale/4,
				v.getSpritePatch(SPR_RNGF, frame+1, 0,0), flags|V_ADD|V_10TRANS,
				v.getColormap(TC_DEFAULT, fire.color)
			)

			fire.y = $ - fire.momy
			fire.tics = $ - 1
			fire.lifetime = $ + 1
		end
	end
	
	old_info.health = me.health*FU
	old_info.stamina = ze.sprintmeter
	old_info.shield = me.shield_health
	-- old_info.rage = ze.ragemeter
	old_disp = p
end

local function getTimeString()
	if ZE2.round_active then
		if ZE2.time_limit then
			return G_TicsToMTIME(ZE2.time_limit - ZE2.game_time)
		else
			return G_TicsToMTIME(ZE2.game_time)
		end
	else
		return G_TicsToMTIME(ZE2.pregame_timeleft)
	end
end

local function roundinfo(v,p,me,ze)
	local top = v.cachePatch("Z_TOP")
	local topwidth = top.width
	local topred = v.cachePatch("Z_TOP_RED")
	local topredwidth = topred.width
	local topblue = v.cachePatch("Z_TOP_BLUE")
	local topbluewidth = topblue.width
	local timestring = getTimeString()
	local zombie_count = ZE2.ZombieCount()
	local survivor_count = ZE2.SurvivorCount()
	
	local spread = 40
	
	v.draw(160-(topwidth/2), 0, top, V_SNAPTOTOP|V_20TRANS)
	v.draw(160-(topredwidth/2) -spread, 0, topred , V_SNAPTOTOP|V_20TRANS)
	v.draw(160-(topbluewidth/2) +spread, 0, topblue, V_SNAPTOTOP|V_20TRANS)
	v.drawString(160, 2, timestring, V_SNAPTOTOP, "center")
	
	v.drawString(160-spread, 2, zombie_count, V_REDMAP|V_SNAPTOTOP, "center")
	v.drawString(160+spread, 2, survivor_count, V_BLUEMAP|V_SNAPTOTOP, "center")
end

local function cashinfo(v,p,me,ze)
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
	if not p.realmo then return end
	
	local me = p.realmo
	local ze = p.ze2
	
	health(v,p,me,ze)
	roundinfo(v,p,me,ze)
	cashinfo(v,p,me,ze)
	eventtimers(v,p,me,ze)
end

return "GameInfo", wrapper
