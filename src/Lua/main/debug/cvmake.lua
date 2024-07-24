local function bind(object, key, varname, options)
    CV_RegisterVar({
        varname,
        object[key],
        CV_NETVAR | CV_CALL,
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
end
