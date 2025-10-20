local CV_Float = "float!"
local CV_Number = {MIN = -999999999, MAX=999999999}
local function bind(object, key, varname, options)
    local flags = CV_NETVAR | CV_CALL | CV_NOINIT
    local value = object[key]
    if options == CV_Float then
        flags = $ | CV_FLOAT
        options = {MIN = -999999999, MAX=999999999}
        value = string.format("%f", value)
    end
    CV_RegisterVar({
        varname,
        value,
        flags,
        options,
        function(varr)
            --[[@type consvar_t]]
            local var = varr
            if options == CV_OnOff or options == CV_YesNo or options == CV_TrueFalse then
                -- it's a boolean
                object[key] = not not var.value
            else
                object[key] = var.value
            end
        end
    })
end

-- synch test example:
-- local object = {bob = 1}
-- bind(object, "bob", "z_bob", CV_Natural)
--
-- addHook("PlayerThink", function (p)
--     p.pflags = $ | PF_GODMODE | PF_NOCLIP
--     p.mo.momz = 0
--     P_SetOrigin(p.mo, 0, object.bob*FU*4, 0)
-- end)


-- weapons
for k,v in pairs(ZE2.ItemPresets) do
    local name = ("item_"..v.displayname:lower()):gsub(" ","_"):gsub("'","")
    if v.firerate then
        bind(v, "firerate", "zd_" .. name .. "_firerate", CV_Natural)
    end
    if v.damage then
        bind(v, "damage", "zd_" .. name .. "_damage", CV_Natural)
    end
    if v.knockback then
        bind(v, "knockback", "zd_" .. name .. "_knockback", CV_Float)
    end
end

-- float test
-- local o = {f = 0}
-- bind(o, "f", "zd_float", CV_Float)
-- hud.add(function (v)
--     v.drawString(160, 130, tostring(o.f), 0, "center")
-- end)

-- COM_AddCommand("clear", function ()
--     for i=1,50 do
--         print("")
--     end
-- end)