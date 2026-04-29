freeslot("SKINCOLOR_CHROMA")

local original_ramp = {97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,31}
local anim_speed = 8

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

skincolors[SKINCOLOR_CHROMA] = {
	name = "Chroma",
	ramp = shallowcopy(original_ramp),
	invcolor = SKINCOLOR_SKY,
	invshade = 0,
	chatcolor = V_BLUEMAP,
	accessible = false
}

addHook("ThinkFrame", function()
    local realhue = (leveltime*anim_speed % 256)

    for i,v in ipairs(original_ramp) do
        local index = original_ramp[i]
        local r, g, b = color.paletteToRgb(index)
        local h, s, l = color.rgbToHsl(r, g, b)

        h = realhue

        l = min($ * 2, 255)

        r, g, b = color.hslToRgb(h, s, l)
        index = color.rgbToPalette(r, g, b)

        skincolors[SKINCOLOR_CHROMA].ramp[i-1] = index
    end
end)