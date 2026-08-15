return function(player, nextplayer, forced)
	if player.spectator then
		return
	end

	if nextplayer.mo and nextplayer.mo.valid and player.mo and player.mo.valid then
		if nextplayer.mo.team ~= player.mo.team then
			return false
		end
	end
end