return function(player)
	for dmo,t in pairs(player.ze2.damage_indicator_table) do
		if t.tics_left then
			if (dmo and dmo.valid) then
				t.real_position = {
					x = dmo.x,
					y = dmo.y,
					z = dmo.z,
					scale = dmo.scale,
					height = dmo.height,
					radius = dmo.radius,
					tics = t.tics_left,
					animation = t.animation,
				}
			end
			
			if (t.damagenumbers) then
				player.ze2:UpdateDamageNumbers(t.damagenumbers, t.real_position, t.number)
			end
			
			if t.tics_left & 1
				t.animation = $ + 1
			end
			
			t.tics_left = $ - 1
			if t.tics_left <= 0 then
				player.ze2.damage_indicator_table[dmo] = nil
				continue
			end
		else
			player.ze2.damage_indicator_table[dmo] = nil
			continue
		end
	end
end