freeslot("SKINCOLOR_ZOMBIE", "SKINCOLOR_ALPHAZOMBIE")

local function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local zombie_ramp = {35,36,37,38,39,40,41,46,47,47,30,30,30,30,31,31}
skincolors[SKINCOLOR_ZOMBIE] = {
	name = "Zombie",
	ramp = shallowcopy(zombie_ramp),
	invcolor = SKINCOLOR_SKY,
	invshade = 0,
	chatcolor = V_REDMAP,
	accessible = false
}

local alpha_ramp = {82,50,51,52,52,53,55,35,35,37,46,47,47,30,31,31}
skincolors[SKINCOLOR_ALPHAZOMBIE] = {
    name = "Alpha Zombie",
    ramp = shallowcopy(alpha_ramp),
    invcolor = SKINCOLOR_GREEN,
    invshade = 9,
    chatcolor = V_GREENMAP,
    accessible = false
}

local cos = cos
local sin = sin
local abs = abs
local min = min
local max = max
local color = color
local FU = FU
local anim_speed = 1024

addHook("ThinkFrame", function()
    local percent = cos(leveltime*FU*anim_speed)

    for i=1,16 do
        local index = zombie_ramp[i]
        local alpha_index = alpha_ramp[i]

        local r, g, b = color.paletteToRgb(index)

        local ar, ag, ab = color.paletteToRgb(alpha_index)

        ar = ease.linear(percent, r, ar)
        ag = ease.linear(percent, g, ag)
        ab = ease.linear(percent, b, ab)

        alpha_index = color.rgbToPalette(max(0,min(ar,255)), 
                                        max(0,min(ag,255)), 
                                        max(0,min(ab,255)))
        skincolors[SKINCOLOR_ALPHAZOMBIE].ramp[i-1] = alpha_index
    end
end)