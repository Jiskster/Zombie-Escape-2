return function(self, tics)
	local player = self.player
	
	player.ze2.damage_fade = tics
	player.ze2.damage_fade_max = tics
end