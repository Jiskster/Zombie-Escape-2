local mt = userdataMetatable("mobj_t")
local old_index = mt.__index

mt.__index = function(mobj, key)
	if key == "team" then
		local team = old_index(mobj, key)
		local player = mobj.player

		if player and player.valid then
			return player.xSlinger.team
		end

		if team == nil then
			return 0
		end
	end

	return old_index(mobj, key)
end


