return "DamageIndicator", function(v, player)
	if not player.mo then return end
	
	for imo,tbl in pairs(player["ze2_info"].damage_indicator_table)
		local result = SG_ObjectTracking(v, player, camera, {
			x = tbl.draw_x,
			y = tbl.draw_y,
			z = tbl.draw_z,
		}, false, true)
		
		if result.onScreen and tbl.tics_left then
			local flags = 0
			
			if tbl.tics_left <= 10 and tbl.tics_left > 0 then
				flags = (10 - tbl.tics_left)<<V_ALPHASHIFT 
			end
			v.drawString(result.x, result.y, "\x85"..tostring(tbl.number), flags, "small-thin-fixed-center")
		end
	end
end