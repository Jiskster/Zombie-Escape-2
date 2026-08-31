local STAMINA_RAMP = {135, 134, 133, 132, 131, 130, 129, 128}
local STAMINA_LOW_RAMP = {79, 78, 77, 76, 75, 74, 73, 72, 83, 82, 81, 80}
local STAMINA_OUT_RAMP = {39, 38, 37, 36, 35, 34, 33, 32}

local stamina = 0
local button_to_tooltip = {
    [BT_CUSTOM1] = "C1",
    [BT_CUSTOM2] = "C2",
    [BT_CUSTOM3] = "C3",
    [BT_SPIN] = "S",
    [BT_JUMP] = "J",
    [BT_ATTACK] = "RT",
    [BT_FIRENORMAL] = "RN",
    [BT_TOSSFLAG] = "TF",
}

local function TableReverse(target)
	local start, length = 1, #target
    if (type(target) == "userdata") then
        start, length = 0, 15
    end

	local result = {}
	for index = length, start, -1 do
		result[length - index + 1] = target[index]
	end
	return result
end

local function FadeAmount(amount)
    local value = ease.linear(amount, 10, 0)
    if (value > 0) and (value < 10) then
        return value << FF_TRANSSHIFT
    end
    return 0
end

---@param v videolib
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param offset integer
---@param amount fixed_t
---@param color integer|skincolor_t|table
---@param flags integer
---@param alpha fixed_t
local function DrawBar(v, x, y, width, height, offset, amount, color, flags, alpha)
	local vertical
	local reverse
	local distorsion
	local nofading
    local colortable
    local colortable_index, colortable_length = 1, 1
    if (type(color) == "userdata") then
        colortable = color
        colortable_index, colortable_length = 0, 15
    elseif (type(color) == "table") then
        colortable = color
        colortable_index, colortable_length = 1, #colortable
    end

    if (flags & V_FLIP) then
        if (colortable ~= nil) then
            colortable = TableReverse(colortable)
            colortable_index, colortable_length = 1, #colortable
        end
        flags = flags & ~(V_FLIP)
    end

	if (flags & V_MONOSPACE) then
		nofading = true
		flags = flags & ~(V_MONOSPACE)
	end

	if (flags & V_MAGENTAMAP) then
		vertical = true
		flags = flags & ~(V_MAGENTAMAP)
	end

	if (flags & V_YELLOWMAP) then
		reverse = true
		flags = flags & ~(V_YELLOWMAP)
	end

	local fraction
	local start
	local finish
	local step
	local goal = width
	if vertical then
		goal = height
	end

	if reverse then
		start = goal
		finish = 0
		step = -1
		fraction = min(FixedDiv(FU - amount, FU) * goal, goal * FU)
	else
		fraction = min(FixedDiv(amount, FU) * goal, goal * FU)
		start = 0
		finish = goal
		step = 1
	end

    for index = start, finish, step do
		--print(string.format("%s: index = %.1f; fraction = %.1f", index, index * FU, fraction))
		if reverse then
			if ((index * FU) < fraction) then break end
		else
			if ((index * FU) >= fraction) then break end
		end

        local fade = min(FixedMul(alpha, max(fraction - (index * FU), 0)), alpha)
		if nofading then
			fade = alpha
		end

        local transparency = FadeAmount(fade)
        local truecolor
        if (colortable ~= nil) then
			local colorindex = index
			local colormax = width
			if vertical then
				colormax = height
			end

            local colorfraction = max(min(FixedInt(FixedRound(FixedDiv(colorindex * FU, colormax * FU) * colortable_length)), colortable_length), colortable_index)
            truecolor = colortable[colorfraction]
        else
            truecolor = color
        end

		if vertical then
			v.drawFill(x, y + ((offset + 1) * index), width, 1, truecolor|flags|transparency)
		else
			v.drawFill(x + ((offset + 1) * index), y, 1, height, truecolor|flags|transparency)
		end
    end
end

---@param v videolib
---@param player player_t
---@param x fixed_t
---@param y fixed_t
---@param flags integer
local function DrawHealthAndStamina(v, player, x, y, flags)
	local game = ZE2.Game

	if (game.ended) then
		return end;

    local mo = player.mo --[[@as mobj_t]]

    local xs = player.xSlinger
    local team = mo.team

    local ze2 = player.ze2

    local zombieconfig = ZE2.ZombieConfig[ze2.zombie_type or ""]
    local special = zombieconfig.special

    local maxhealth = mo.maxhealth or 0

    local staminamax = 100 * FU
    if (team == 2) and special and special and special.button then
        staminamax = special.cooldown * FU
        stamina = ease.inquart(FU / 2, stamina, staminamax - (ze2.special_cooldown * FU))
    elseif (team == 1) then
        stamina = ease.inquart(FU / 2, stamina, ze2.sprintmeter)
    end

    local bar_visible = false
    if (team == 1) or (special and special.button) then
        bar_visible = true
    end

    local bg_height = 20
    if not bar_visible then
        bg_height = 12
        y = y + (8 * FU)
    end
    v.drawFill(FixedInt(x) - 2, FixedInt(y) - 2, 64, bg_height, 31|flags|V_TRANSLUCENT)

    local health_icon = v.cachePatch("Z_HP_ICON2")
    local health_color = SKINCOLOR_GREEN
    if player.mo and player.mo.valid then
        health_color = player.mo.color
    end

    v.drawScaled(x, y, FU / 2, health_icon, flags, v.getColormap(nil, health_color, nil))
    if (mo.health <= (maxhealth / 2)) then
        local amount = FU - cos(leveltime * ANG10)
        local transparency = FadeAmount(amount)
        v.drawScaled(x, y, FU / 2, health_icon, flags|transparency, v.getColormap(nil, SKINCOLOR_RED, nil))
    end

    local health_text = 0
    if (mo.health <= (maxhealth / 2)) then
        health_text = V_YELLOWMAP
    end
    v.drawString(x + (10 * FU), y, mo.health, flags|health_text, "fixed")

    if bar_visible then
        local fillx = FixedInt(x) + 11
        local filly = FixedInt(y) + 11
        local filltotal = 40
        local filltotalfrac = filltotal * FU
        local fillamount = FixedMul(FixedDiv(stamina, staminamax), filltotalfrac)
        if (team == 1) then
            fillx = FixedInt(x) + 1
        end

        v.drawFill(fillx - 1, filly - 1, filltotal + 2, 6, 31|flags|V_TRANSLUCENT)
        if (team == 2) then
            local color = skincolors[SKINCOLOR_ALPHAZOMBIE].ramp
            if (ze2.special_cooldown > 0) then
                color = 71
            end
            DrawBar(v, fillx, filly, filltotal, 4, 0, FixedDiv(fillamount, filltotalfrac), color, flags|V_FLIP, FU)
        elseif ze2.sprintdelay then
            local alpha = FU - sin((leveltime * 2) * ANG10)
            DrawBar(v, fillx, filly, filltotal, 4, 0, FU, STAMINA_OUT_RAMP, flags, alpha)
        else
            DrawBar(v, fillx, filly, filltotal, 4, 0, FixedDiv(fillamount, filltotalfrac), STAMINA_RAMP, flags, FU)
            if (stamina < (30 * FU)) then
                local alpha = FU - sin(leveltime * (ANG10 / 2))
                DrawBar(v, fillx, filly, filltotal, 4, 0, FixedDiv(fillamount, filltotalfrac), STAMINA_LOW_RAMP, flags, alpha)
            end
        end

        if ze2.sprintdelay then
            v.drawString((fillx * FU) + (filltotalfrac / 2), filly * FU, "Exhausted", flags|V_YELLOWMAP|V_20TRANS|V_ALLOWLOWERCASE, "small-fixed-center")
        else
            local percent = FixedInt(FixedCeil(FixedDiv(fillamount, filltotalfrac) * 100))
            v.drawString(((fillx * FU) + filltotalfrac) - FU, filly * FU, percent .. "%", flags|V_20TRANS, "small-fixed-right")
        end
    end

    if special and special.button then
        local buttonpatch = "Z_TT_" .. (button_to_tooltip[special.button])
        if v.patchExists(buttonpatch) then
            local transparency = 0
            if (ze2.special_cooldown > 0) then
                transparency = V_TRANSLUCENT
            end
            v.drawScaled(x, y + (9 * FU), FU / 2, v.cachePatch(buttonpatch), flags|transparency, nil)
        end
    end

    if (team == 1) then
        local shield_icon = v.cachePatch("Z_SHIELDSICO")
        local shield_x, shield_y = x + (52 * FU), y + (8 * FU)
        if (mo.shield_def ~= nil) then
            local shield = mo.shield_def
            local shield_color = (shield.color or SKINCOLOR_WHITE)
            local shield_percentage = FixedDiv(mo.shield_health, shield.health)

            local shield_y_text = y + (5 * FU)
            if (mo.shield_efficiency > 0) then
                shield_y = shield_y - (2 * FU)
                shield_y_text = shield_y_text - (2 * FU)
            end

            local crop_height = (shield_icon.height * FU) - FixedMul(shield_icon.height * FU, shield_percentage)
            crop_height = max(crop_height, 0)

            if (shield_percentage ~= FU) then
                v.drawCropped(shield_x, shield_y, FU / 2, FU / 2, shield_icon, flags|V_REVERSESUBTRACT, v.getColormap(nil, SKINCOLOR_CARBON, "Grayscale"), 0, 0, shield_icon.width * FU, crop_height)
            end

            v.drawCropped(shield_x, shield_y + (crop_height / 2), FU / 2, FU / 2, shield_icon, flags|V_ADD|V_30TRANS, v.getColormap(nil, shield_color, nil), 0, crop_height, shield_icon.width * FU, shield_icon.height * FU)

            v.drawString(x + (52 * FU), shield_y_text, mo.shield_health, flags|V_10TRANS, "thin-fixed-center")
            if (mo.shield_efficiency > 0) then
                v.drawString(x + (52 * FU), y + (11 * FU), FixedInt(FixedDiv(mo.shield_efficiency, FU) * 100) .. "%", flags|V_10TRANS, "small-fixed-center")
            end
        else
            v.drawScaled(shield_x, shield_y, FU - (FU / 4), shield_icon, flags|V_REVERSESUBTRACT, v.getColormap(nil, SKINCOLOR_CARBON, "Grayscale"))
        end
    end
end

---@param v videolib
---@param player player_t
local function Drawer(v, player)
    if not player.mo or not player.mo.valid then return end
    DrawHealthAndStamina(v, player, 8 * FU, (BASEVIDHEIGHT - 24) * FU, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
end
return "HealthAndStamina", Drawer
