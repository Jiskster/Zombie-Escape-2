for i,v in pairs(player.ze2.effects) do
	if v.normalspeed then
		player.normalspeed = v.normalspeed
	elseif v.normalspeed_multiplier then
		player.normalspeed = FixedMul($, v.normalspeed_multiplier)
	end
	
	if v.actionspd then
		player.actionspd = v.actionspd
	elseif v.actionspd_multiplier then
		player.actionspd = FixedMul($, v.actionspd_multiplier)
	end
	
	if v.charability then
		player.charability = v.charability
	end
	
	if v.time_left then
		if ZE2.Effects[i].thinker then
			ZE2.Effects[i].thinker(player, v.time_left)
		end
		
		v.time_left = $ - 1
		
		if not v.time_left then
			if ZE2.Effects[i].on_end then
				ZE2.Effects[i].on_end (player)
			end
			
			player.ze2.effects[i] = nil
			continue
		end
	end
end