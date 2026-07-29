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
local function DrawHealth(v, player, x, y, flags)
    stamina = ease.inquart(FU / 2, stamina, player.ze2.sprintmeter)

    v.drawFill(FixedInt(x) - 2, FixedInt(y) - 2, 64, 20, 31|flags|V_TRANSLUCENT)

    local patch = v.cachePatch("Z_HP_ICON")
    v.drawScaled(x, y, FU, patch, flags, nil)

    v.drawString(x + (20 * FU), y + (1 * FU), player.mo.health, flags, "fixed")

    local fillx = FixedInt(x) + 20
    local filly = FixedInt(y) + 11
    local filltotal = 20
    local filltotalfrac = filltotal * FU
    local fillamount = FixedMul(FixedDiv(stamina, 100 * FU), filltotalfrac)
    if player.ze2.sprintdelay then
        fillamount = ((leveltime / 4) & 1) and filltotalfrac or 0
    end

    v.drawFill(fillx - 1, filly - 1, (filltotal + 1) * 2, 6, 31|flags|V_TRANSLUCENT)
    for index = 0, filltotal, 1 do
        if ((index * FU) >= fillamount) then break end

        local amount = min(FixedMul(FU, max(fillamount - (index * FU), 0)), FU)
        local transparency = FadeAmount(amount)
        local color = 132
        if player.ze2.sprintdelay then
            color = 35
        elseif (stamina < (30 * FU)) then
            color = 73
        end
        v.drawFill(fillx + (2 * index) + 1, filly, 1, 2, color|flags|transparency)
        v.drawFill(fillx + (2 * index), filly + 2, 1, 2, (color + 1)|flags|transparency)
    end
end

---@param v videolib
---@param player player_t
local function Drawer(v, player)
    if not player.mo or not player.mo.valid then return end
    DrawHealth(v, player, 16 * FU, (BASEVIDHEIGHT - 32) * FU, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
end
return "Health", Drawer