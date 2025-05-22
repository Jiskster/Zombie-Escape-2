-- http://lua-users.org/wiki/CopyTable
function ZE2:Copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ZE2:Copy(orig_key)] = ZE2:Copy(orig_value)
        end
        setmetatable(copy, ZE2:Copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
