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

local stamina = 0

local function FadeAmount(amount)
    local value = ease.linear(amount, 10, 0)
    if (value > 0) and (value < 10) then
        return value << FF_TRANSSHIFT
    end
    return 0
end

---@param v videolib
---@param player player_t
---@param x fixed_t
---@param y fixed_t
---@param flags integer
local function DrawHealthAndStamina(v, player, x, y, flags)
    local mo = player.mo --[[@as mobj_t]]

    local xs = player.xSlinger
    local team = xs.team

    local ze2 = player.ze2

    local zombieconfig = ZE2.ZombieConfig[ze2.zombie_type or ""]
    local special = zombieconfig.special

    local staminamax = 100 * FU
    if (team == 2) and special and special and special.button then
        staminamax = special.cooldown * FU
        stamina = ease.inquart(FU / 2, stamina, staminamax - (ze2.special_cooldown * FU))
    elseif (team == 1) then
        stamina = ease.inquart(FU / 2, stamina, ze2.sprintmeter)
    end

    local bg_height = 20
    if (team == 2) and (not special or not special.button) then
        bg_height = 12
        y = y + (8 * FU)
    end
    v.drawFill(FixedInt(x) - 2, FixedInt(y) - 2, 64, bg_height, 31|flags|V_TRANSLUCENT)

    local health_icon = v.cachePatch("Z_HP_ICON")
    v.drawScaled(x, y, FU / 2, health_icon, flags, v.getColormap(nil, SKINCOLOR_JADE, nil))
    if (mo.health <= (mo.maxhealth / 2)) then
        local amount = FU - cos(leveltime * ANG10)
        local transparency = FadeAmount(amount)
        v.drawScaled(x, y, FU / 2, health_icon, flags|transparency, v.getColormap(nil, SKINCOLOR_RED, nil))
    end

    local health_text = 0
    if (mo.health <= (mo.maxhealth / 2)) then
        health_text = V_YELLOWMAP
    end
    v.drawString(x + (10 * FU), y, mo.health, flags|health_text, "fixed")

    local fillx = FixedInt(x) + 11
    local filly = FixedInt(y) + 11
    local filltotal = 20
    local filltotalfrac = filltotal * FU
    local fillamount = FixedMul(FixedDiv(stamina, staminamax), filltotalfrac)
    if (team == 1) then
        fillx = FixedInt(x) + 1
        if ze2.sprintdelay then
            fillamount = ((leveltime / 4) & 1) and filltotalfrac or 0
        end
    end

    if (team == 1) or ((team == 2) and special and special.button) then
        v.drawFill(fillx - 1, filly - 1, (filltotal + 1) * 2, 6, 31|flags|V_TRANSLUCENT)
        for index = 0, filltotal, 1 do
            if ((index * FU) >= fillamount) then break end

            local amount = min(FixedMul(FU, max(fillamount - (index * FU), 0)), FU)
            local transparency = FadeAmount(amount)
            local color = 132
            if (team == 2) then
                color = 53
            elseif ze2.sprintdelay then
                color = 35
            elseif (stamina < (30 * FU)) then
                color = 73
            end
            v.drawFill(fillx + (2 * index) + 1, filly, 1, 1, color|flags|transparency)
            v.drawFill(fillx + (2 * index) + 1, filly + 1, 1, 1, (color + 1)|flags|transparency)
            v.drawFill(fillx + (2 * index), filly + 2, 1, 1, (color + 2)|flags|transparency)
            v.drawFill(fillx + (2 * index), filly + 3, 1, 1, (color + 3)|flags|transparency)
        end
    end

    if special and special.button then
        local buttonpatch = "Z_TT_" .. (button_to_tooltip[special.button])
        if v.patchExists(buttonpatch) then
            v.drawScaled(x, y + (9 * FU), FU / 2, v.cachePatch(buttonpatch), flags, nil)
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

            v.drawString(x + (52 * FU), shield_y_text, mo.shield_health, flags, "thin-fixed-center")
            if (mo.shield_efficiency > 0) then
                v.drawString(x + (52 * FU), y + (11 * FU), FixedInt(FixedDiv(mo.shield_efficiency, FU) * 100) .. "%", flags, "small-fixed-center")
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
