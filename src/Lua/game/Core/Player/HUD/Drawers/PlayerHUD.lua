---@param v videolib
---@param player player_t
---@param x fixed_t
---@param y fixed_t
---@param flags integer
local function DrawHealth(v, player, x, y, flags)
    local mo = player.mo --[[@as mobj_t]]

    local maxhealth = mo.maxhealth or 0

    local bg_width = 44
    local bg_height = 10
    v.drawFill(FixedInt(x), FixedInt(y), bg_width, bg_height, 31|flags|V_TRANSLUCENT)

    local health_icon = v.cachePatch("Z_HP_ICON2")
    local health_color = SKINCOLOR_GREEN
    if player.mo and player.mo.valid then
        health_color = player.mo.color
    end

    local health_x = x + (1 * FU)
    local health_y = y + (1 * FU)
    local health_scale = FU / 2
    v.drawScaled(health_x, health_y, health_scale, health_icon, flags, v.getColormap(nil, health_color, nil))
    if (mo.health <= (maxhealth / 2)) then
        local amount = FU - cos(leveltime * ANG10)
        local transparency = L_FadeAmount(amount)
        v.drawScaled(health_x, health_y, health_scale, health_icon, flags|transparency, v.getColormap(nil, SKINCOLOR_RED, nil))
    end

    local health_text = 0
    if (mo.health <= (maxhealth / 2)) then
        health_text = V_YELLOWMAP
    end
    v.drawString(health_x + (10 * FU), health_y, mo.health, flags|health_text, "fixed")
end

---@param v videolib
---@param player player_t
---@param x fixed_t
---@param y fixed_t
---@param flags integer
local function DrawArmor(v, player, x, y, flags)
    local mo = player.mo --[[@as mobj_t]]
    local team = mo.team
    if (team ~= 1) then return end
	if (mo.shield_def == nil) then return end
	
    local bg_width = 28
    local bg_height = 10
    v.drawFill(FixedInt(x), FixedInt(y), bg_width, bg_height, 31|flags|V_TRANSLUCENT)

    local shield_scale = (FU / 2) - (FU / 8)
    local shield_icon = v.cachePatch("Z_SHIELDSICO")
    local shield_x, shield_y = x + (5 * FU), y + (5 * FU)
	local shield = mo.shield_def
	local shield_color = (shield.color or SKINCOLOR_WHITE)
	local shield_percentage = FixedDiv(mo.shield_health, shield.health)

	local shield_y_text = shield_y - (3 * FU)

	local crop_height = (shield_icon.height * FU) - FixedMul(shield_icon.height * FU, shield_percentage)
	crop_height = max(crop_height, 0)

	if (shield_percentage ~= FU) then
		v.drawCropped(shield_x, shield_y, shield_scale, shield_scale, shield_icon, flags|V_REVERSESUBTRACT, v.getColormap(nil, SKINCOLOR_CARBON, "Grayscale"), 0, 0, shield_icon.width * FU, crop_height)
	end

	v.drawCropped(shield_x, shield_y + FixedMul(crop_height, shield_scale), shield_scale, shield_scale, shield_icon, flags|V_ADD|V_30TRANS, v.getColormap(nil, shield_color, nil), 0, crop_height, shield_icon.width * FU, shield_icon.height * FU)

	v.drawString(shield_x + (6 * FU), shield_y_text, mo.shield_health, flags|V_10TRANS, "thin-fixed")
	if (mo.shield_efficiency > 0) then
		v.drawString(shield_x, shield_y_text + (1 * FU), FixedInt(FixedDiv(mo.shield_efficiency, FU) * 100) .. "%", flags|V_10TRANS, "small-thin-fixed-center")
	end
end


local STAMINA_RAMP = {135, 134, 133, 132, 131, 130, 129, 128}
local STAMINA_LOW_RAMP = {79, 78, 77, 76, 75, 74, 73, 72, 83, 82, 81, 80}
local STAMINA_OUT_RAMP = {39, 38, 37, 36, 35, 34, 33, 32}

local stamina = 0
local ability = 0
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

---@param v videolib
---@param player player_t
---@param x fixed_t
---@param y fixed_t
---@param flags integer
local function DrawStaminaOrAbility(v, player, x, y, flags)
    local mo = player.mo --[[@as mobj_t]]

    local xs = player.xSlinger
    local team = mo.team

    local ze2 = player.ze2

    local zombieconfig = ZE2.ZombieConfig[ze2.zombie_type or ""]
    local special = zombieconfig.special

    local staminamax = 100 * FU
    local abilitymax = (team == 2) and (special.cooldown or 0) * FU or 0
    if (team == 2) and special and special and special.button then
        ability = ease.linear(FU / 2, ability, abilitymax - (ze2.special_cooldown * FU))
    elseif (team == 1) then
        stamina = ease.linear(FU / 2, stamina, ze2.sprintmeter)
    end

    local bar_visible = false
    if (team == 1) or (special and special.button) then
        bar_visible = true
    end

    if bar_visible then
        local bg_width = 44
        local bg_height = 11
        v.drawFill(FixedInt(x), FixedInt(y), bg_width, bg_height, 31|flags|V_TRANSLUCENT)
    end

    local fillx = FixedInt(x) + 1
    local filly = FixedInt(y) + 6
    local fillh = 4
    local filltotal = 42
    local filltotalfrac = filltotal * FU
    if bar_visible then
        local header = "Stamina"
        local fillamount = FixedMul(FixedDiv(stamina, staminamax), filltotalfrac)
        if (team == 2) then
            header = special.effect_name
            fillamount = FixedMul(FixedDiv(ability, abilitymax), filltotalfrac)
        end

        v.drawString(fillx, filly - 5, header, flags|V_ALLOWLOWERCASE, "small")

        v.drawFill(fillx - 1, filly - 1, filltotal + 2, fillh + 2, 31|flags|V_TRANSLUCENT)
        if (team == 2) then
            local color = skincolors[SKINCOLOR_ALPHAZOMBIE].ramp
            if (ze2.special_cooldown > 0) then
                color = 71
            end
            L_DrawBar(v, fillx, filly, filltotal, fillh, 0, FixedDiv(fillamount, filltotalfrac), color, flags|V_FLIP, FU)
        elseif ze2.sprintdelay then
            local alpha = FU - sin((leveltime * 2) * ANG10)
            L_DrawBar(v, fillx, filly, filltotal, fillh, 0, FU, STAMINA_OUT_RAMP, flags, alpha)
        else
            L_DrawBar(v, fillx, filly, filltotal, fillh, 0, FixedDiv(fillamount, filltotalfrac), STAMINA_RAMP, flags, FU)
            if (stamina <= (50 * FU)) then
                local alpha = FU - sin(leveltime * (ANG10 / 2))
                L_DrawBar(v, fillx, filly, filltotal, fillh, 0, FixedDiv(fillamount, filltotalfrac), STAMINA_LOW_RAMP, flags, alpha)
            end
        end

        if ze2.sprintdelay then
            v.drawString((fillx * FU) + (filltotalfrac / 2), filly * FU, "Exhausted", flags|V_YELLOWMAP|V_ALLOWLOWERCASE, "small-fixed-center")
        else
            local percent = FixedInt(FixedCeil(FixedDiv(fillamount, filltotalfrac) * 100))
            v.drawString(fillx + filltotal, filly, percent .. "%", flags, "small-right")
        end
    end

    if special and special.button then
        local buttonpatch = "Z_TT_" .. (button_to_tooltip[special.button])
        if v.patchExists(buttonpatch) then
            local transparency = 0
            if (ze2.special_cooldown > 0) then
                transparency = V_TRANSLUCENT
            end
            v.drawScaled(x + filltotalfrac + (4 * FU), y + (2 * FU), FU / 2, v.cachePatch(buttonpatch), flags|transparency, nil)
        end
    end
end

local HUD_INPUT_POS = -9999

---@param v videolib
---@param player player_t
local function Drawer(v, player)
    if (hudinfo[HUD_INPUT].y ~= HUD_INPUT_POS) then
        hudinfo[HUD_INPUT].y = HUD_INPUT_POS
    end

    local game = ZE2.Game
	if game.ended then return end

    if not player.mo or not player.mo.valid then return end
    DrawHealth(v, player, 4 * FU, (BASEVIDHEIGHT - 14) * FU, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
    DrawArmor(v, player, (4 + 46) * FU, (BASEVIDHEIGHT - 14) * FU, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
    DrawStaminaOrAbility(v, player, 4 * FU, (BASEVIDHEIGHT - 26) * FU, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
end
return "PlayerHUD", Drawer
