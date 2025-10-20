return function(player, nextplayer, forced)
	if player.spectator then
		return
	end

	if nextplayer.ze2.team ~= player.ze2.team then
		return false
	end
end