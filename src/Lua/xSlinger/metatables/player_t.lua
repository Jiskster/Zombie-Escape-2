local mt = userdataMetatable("player_t")
local old_index = mt.__index

local itername = "xSlinger[]"

mt.__index = function(player, key)
	if key == "xSlinger" then
		local internal_table = old_index(player, itername)

		if not internal_table then
			player[itername] = xSlinger.init()
		end
		
		player[itername].player = player

		if player.mo then
			player[itername].mo = player.mo
		end

		return player[itername]
	else
		return old_index(player, key)
	end
end


