if player.ze2.damage_fade and player.ze2.damage_fade_max then
	player.ze2.damage_fade = $ - 1
	
	if not player.ze2.damage_fade then
		player.ze2.damage_fade_max = 0
	end
else
	player.ze2.damage_fade = 0
	player.ze2.damage_fade_max = 0
end