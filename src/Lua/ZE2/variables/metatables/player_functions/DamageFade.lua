return function(self, tics)
	local player = self.player
	
	if not (player and player.valid and player.mo and player.mo.valid) then
		return
	end
	
	player.ze2.damage_fade = tics
	player.ze2.damage_fade_max = tics
end