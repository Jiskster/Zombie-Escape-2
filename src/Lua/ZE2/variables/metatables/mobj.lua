local mobj_mt = userdataMetatable("mobj_t")
local mobj_mt_oldindex = mobj_mt.__index -- save old __index

local ze2_funcs_path = "ZE2/variables/metatables/mobj_functions/"

local ze2_funcs = {
	["ChangeHealth"] = ZE2.Require(ze2_funcs_path + "ChangeHealth");
	["speedCapXY"]   = ZE2.Require(ze2_funcs_path + "speedCapXY");
}

mobj_mt.__index = function(mobj, key)
	if ze2_funcs[key] then
		return ze2_funcs[key]
    else
        return mobj_mt_oldindex(mobj, key)
    end
end