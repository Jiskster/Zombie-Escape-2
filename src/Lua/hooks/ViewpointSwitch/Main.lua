local nextplayer = nextviewedplayer

if player.spectator then
	return
end

if nextplayer.ze2.team ~= player.ze2.team then
	return false
end