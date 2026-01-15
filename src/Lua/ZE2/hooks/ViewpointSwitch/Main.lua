return function(player, nextplayer, forced)
	if player.spectator then
		return
	end

	if nextplayer.xSlinger.team ~= player.xSlinger.team then
		return false
	end
end