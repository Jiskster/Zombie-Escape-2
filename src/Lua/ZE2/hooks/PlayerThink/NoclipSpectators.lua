---@param player player_t
return function(player)
    if not player.realmo or not player.realmo.valid then return end
	if not player.spectator then return end
	if (player.playerstate ~= PST_LIVE) then return end

    player.realmo.flags = player.realmo.flags | (MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING)
end